# frozen_string_literal: true
require 'rails_helper'

# Companion draft to archival_object_record_spec.rb -- see that file's header
# comment for how to copy drafts into lib_jobs to run them (this one would also
# need `marcao_flag_field` added to config/aspace.yml, per the job's comments).
#
# This stubs aspace_helper_methods' REST helpers (get_all_repo_uris,
# get_resolved_objects_from_ids, etc.) directly, the way
# send_marcxml_to_alma_job_spec.rb stubs get_resource_uris_for_all_repos --
# those helpers carry their own test coverage in aspace_helpers. What's worth
# pinning down here is *which* REST calls this job makes, with what arguments,
# in what order -- i.e. that it actually implements the two REST-only answers
# described in the job's header comment -- not the HTTP mechanics underneath.
RSpec.describe Aspace2alma::SendComponentMarcxmlToAlmaJob do
  subject(:job) { described_class.new }

  let(:frozen_time) { Time.utc(2026, 6, 8, 12, 0, 0) }
  # frozen_time - DEFAULT_LOOKBACK (1.day) - OVERLAP_BUFFER (5.seconds)
  let(:since_in_solr_format) { '2026-06-07T11:59:55Z' }

  let(:flagged_resource) { { 'uri' => '/repositories/3/resources/100', 'user_defined' => { 'boolean_1' => true } } }
  let(:unflagged_resource) { { 'uri' => '/repositories/3/resources/200', 'user_defined' => { 'boolean_1' => false } } }
  let(:resolved_ao_json) { JSON.parse(file_fixture('aspace2alma/resolved_archival_object.json').read) }
  let(:client) { instance_double('ArchivesSpace::Client') }

  let(:search_query) do
    { q: %(resource:"/repositories/3/resources/100" AND system_mtime:[#{since_in_solr_format} TO *]),
      type: ['archival_object'], page: 1, page_size: 250 }
  end
  let(:search_results) { { 'this_page' => 1, 'last_page' => 1, 'results' => [{ 'uri' => '/repositories/3/archival_objects/456' }] } }

  around do |example|
    FileUtils.rm_f(described_class::FILENAME)
    example.run
    FileUtils.rm_f(described_class::FILENAME)
  end
  after { Timecop.return }

  before do
    Timecop.freeze(frozen_time)

    allow(Rails.application.config.aspace).to receive(:marcao_flag_field).and_return('boolean_1')

    # aspace_login normally sets @client as a side effect of logging in;
    # stubbed out here so the spec can hand the job a double directly
    allow(job).to receive(:aspace_login)
    job.instance_variable_set(:@client, client)

    allow(job).to receive(:get_all_repo_uris).and_return(['/repositories/3'])
    allow(job).to receive(:get_repo_id_from_uri).with('/repositories/3').and_return('3')

    # "which resources are flagged?" -- fetch full resource records, filter on
    # the embedded user_defined flag (see job header comment (1))
    allow(client).to receive(:get)
      .with('/repositories/3/resources', query: { all_ids: true })
      .and_return(instance_double('ArchivesSpace::Response', parsed: [100, 200]))
    allow(job).to receive(:get_resolved_objects_from_ids)
      .with('3', [100, 200], 'resources', [])
      .and_return([[flagged_resource, unflagged_resource]])

    # "which AOs changed under a flagged resource since the last run?" --
    # /search stands in for the plugin's Sequel filter (see header comment (2))
    allow(client).to receive(:get)
      .with('/repositories/3/search', query: search_query)
      .and_return(instance_double('ArchivesSpace::Response', parsed: search_results))
    allow(job).to receive(:get_resolved_objects_from_ids)
      .with('3', [456], 'archival_objects', Aspace2alma::ArchivalObjectRecord.resolves)
      .and_return([[resolved_ao_json]])

    allow(Aspace2almaHelper).to receive(:remove_file)
    allow(Aspace2almaHelper).to receive(:rename_file)
    allow(Aspace2almaHelper).to receive(:alma_sftp)
  end

  describe '#run' do
    it 'searches for modified AOs only under flagged resources, scoped to the window since the last run' do
      job.run

      expect(client).to have_received(:get).with('/repositories/3/search', query: search_query)
      # the unflagged resource (200) never gets a search query of its own --
      # the stub above only matches resource 100's query, so a call scoped to
      # 200 would raise "received :get with unexpected arguments" and fail this example
    end

    it 'maps the resolved AOs to MARCXML and writes them into the delivery file as a <collection>' do
      job.run

      collection = Nokogiri::XML(File.read(described_class::FILENAME))
      expect(collection.xpath('//marc:record').size).to eq(1)
      expect(collection.at_xpath('//controlfield[@tag="001"]').content).to eq('C0140_c00123')
    end

    it 'renames any previous delivery file out of the way, then SFTPs the new one (mirrors SendMarcxmlToAlmaJob)' do
      job.run

      expect(Aspace2almaHelper).to have_received(:remove_file).with('/alma/aspace/MARC_component_out_old.xml')
      expect(Aspace2almaHelper).to have_received(:rename_file)
        .with('/alma/aspace/MARC_component_out.xml', '/alma/aspace/MARC_component_out_old.xml')
      expect(Aspace2almaHelper).to have_received(:alma_sftp).with(described_class::FILENAME)
    end

    it 'reports how many archival object records were exported' do
      job.run

      data_set = DataSet.where(category: 'Aspace2Alma_component').order(created_at: :desc).first
      expect(data_set.data).to start_with('Exported 1 archival object record(s) modified since')
    end

    context 'when no AOs changed under any flagged resource' do
      let(:search_results) { { 'this_page' => 1, 'last_page' => 1, 'results' => [] } }

      it 'skips delivery entirely rather than sending an empty file' do
        job.run

        expect(Aspace2almaHelper).not_to have_received(:alma_sftp)
        expect(File).not_to exist(described_class::FILENAME)
      end
    end
  end
end
