# frozen_string_literal: true
module Aspace2alma
  # Exports MARCXML for archival_object-level ("component") records to Alma --
  # the lib_jobs-side replacement for as_marcao's MarcAOExporter, running
  # entirely outside ArchivesSpace over the REST API the way
  # SendMarcxmlToAlmaJob exports resource-level records.
  #
  # MarcAOExporter answers two questions with direct Sequel/DB access that --
  # it turns out -- are both answerable over plain REST, with no plugin code:
  #
  # 1. "Which resources are flagged for AO-level export?"
  #    The plugin asks: UserDefined.filter(AppConfig[:marcao_flag_field] => true).
  #    Solr does *not* index user_defined booleans -- no
  #    add_document_prepare_hook in indexer_common.rb references user_defined,
  #    and build_fullrecord/extract_string_values only ever collects String
  #    values for the full-text fields, so a /search query can't find them.
  #    But `user_defined` is registered as a nested record on resources (see
  #    the UserDefineds mixin / def_nested_record), so it comes back embedded
  #    in the plain JSONModel rendering of every resource -- a GET of the
  #    resource is enough: resource.dig('user_defined', flag_field).
  #
  # 2. "Which AOs under a flagged resource changed since the last run?"
  #    The plugin asks:
  #      ArchivalObject.any_repo.filter(root_record_id: id)
  #                            .filter { system_mtime > since }
  #    Both `resource` (the parent resource's ref) and `system_mtime` *are*
  #    indexed for archival_objects (indexer_common.rb populates doc['resource']
  #    from record['record']['resource']['ref'], and system_mtime is indexed
  #    generically for every record type), so the equivalent is a stock
  #    /repositories/:id/search query:
  #      q: resource:"<resource_uri>" AND system_mtime:[<since> TO *]
  #      type: ['archival_object']
  #
  # Net result: this job needs no thin plugin endpoint -- everything it does is
  # available through aspace_helper_methods plus the stock /search endpoint.
  class SendComponentMarcxmlToAlmaJob < LibJob
    FILENAME = 'MARC_component_out.xml'
    OLD_FILENAME = 'MARC_component_out_old.xml'

    # ArchivesSpace stores Solr dates in UTC, formatted like 2026-06-01T00:00:00Z
    SOLR_TIME_FORMAT = '%Y-%m-%dT%H:%M:%SZ'

    # mirrors MarcAOExporter::WINDOW_SECONDS: re-check a few seconds before the
    # last reported run time, so an AO saved mid-run on the previous pass can't
    # slip through the gap between "last_success_at" and "the search actually ran"
    OVERLAP_BUFFER = 5.seconds

    # how far back to look on the very first run, when there is no prior DataSet
    DEFAULT_LOOKBACK = 1.day

    def initialize
      super(category: 'Aspace2Alma_component')
    end

    private

    def handle(data_set:)
      aspace_login
      since = last_run_time

      ao_jsons = get_all_repo_uris.flat_map { |repo_uri| modified_archival_objects_for_repo(repo_uri:, since:) }
      deliver(ao_jsons) unless ao_jsons.empty?

      data_set.data = report(since:, count: ao_jsons.size)
      data_set.report_time = Time.zone.now
      data_set
    end

    def modified_archival_objects_for_repo(repo_uri:, since:)
      repo_id = get_repo_id_from_uri(repo_uri)

      flagged_resource_uris(repo_uri:, repo_id:).flat_map do |resource_uri|
        resolved_modified_archival_objects(repo_id:, resource_uri:, since:)
      end
    end

    # see header comment (1): fetch full resource records and filter on the
    # embedded user_defined flag client-side, rather than searching for it
    def flagged_resource_uris(repo_uri:, repo_id:)
      resource_ids = @client.get("#{repo_uri}/resources", query: { all_ids: true }).parsed

      get_resolved_objects_from_ids(repo_id, resource_ids, 'resources', [])
        .flatten
        .select { |resource| resource.dig('user_defined', flag_field) }
        .map { |resource| resource['uri'] }
    end

    # would need adding to config/aspace.yml alongside the existing `repos` key,
    # the way as_marcao documents `marcao_flag_field` in its own README
    def flag_field
      Rails.application.config.aspace.marcao_flag_field
    end

    # see header comment (2): /search stands in for the plugin's
    # `ArchivalObject.any_repo.filter(root_record_id:).filter { system_mtime > since }`
    def resolved_modified_archival_objects(repo_id:, resource_uri:, since:)
      ao_ids = modified_archival_object_ids(repo_id:, resource_uri:, since:)
      return [] if ao_ids.empty?

      get_resolved_objects_from_ids(repo_id, ao_ids, 'archival_objects', Aspace2alma::ArchivalObjectRecord.resolves).flatten
    end

    def modified_archival_object_ids(repo_id:, resource_uri:, since:)
      query = %(resource:"#{resource_uri}" AND system_mtime:[#{since.utc.strftime(SOLR_TIME_FORMAT)} TO *])
      ids = []
      page = 1

      loop do
        response = @client.get("/repositories/#{repo_id}/search",
                               query: { q: query, type: ['archival_object'], page:, page_size: 250 }).parsed
        ids.concat(response['results'].map { |result| result['uri'].split('/').last.to_i })
        break if page >= response['last_page']

        page += 1
      end

      ids
    end

    # mirrors SendMarcxmlToAlmaJob's defensive rename: if a previous run died
    # mid-upload, Alma should never find a stale file waiting under this name
    def deliver(ao_jsons)
      Aspace2almaHelper.remove_file("/alma/aspace/#{OLD_FILENAME}")
      Aspace2almaHelper.rename_file("/alma/aspace/#{FILENAME}", "/alma/aspace/#{OLD_FILENAME}")

      File.write(FILENAME, Aspace2alma::ArchivalObjectRecord.collection_to_marc(ao_jsons))
      Aspace2almaHelper.alma_sftp(FILENAME)
    end

    # mirrors MarcAOExporter's `since = last_success_at - WINDOW_SECONDS`;
    # most_recent_dataset/report_time replace the plugin's report.json bookkeeping
    def last_run_time
      (most_recent_dataset&.report_time || DEFAULT_LOOKBACK.ago) - OVERLAP_BUFFER
    end

    def report(since:, count:)
      "Exported #{count} archival object record(s) modified since #{since}."
    end
  end
end
