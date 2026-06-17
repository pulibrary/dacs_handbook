# Claude MARCAO -- draft port of as_marcao into lib_jobs

This directory is a **review draft**, written outside both the `lib_jobs` and
`as_marcao` repos so nothing in either gets touched. It drafts the two riskiest
pieces of moving AO-level export out of the `as_marcao` ArchivesSpace plugin and
into `lib_jobs`, alongside the existing collection-level code in
`app/models/aspace2alma/`:

1. **The MARC mapping itself** -- `backend/model/marc_ao_mapper.rb` (a
   466-line module of class methods with no test coverage), ported as
   `Aspace2alma::ArchivalObjectRecord`.
2. **The data-fetching/orchestration job** -- `backend/model/marc_ao_exporter.rb`,
   ported as `Aspace2alma::SendComponentMarcxmlToAlmaJob`. This is the part
   that seemed likeliest to need a new plugin endpoint (it currently relies on
   direct Sequel/DB access); see "Finding flagged resources and modified AOs
   over plain REST" below for why it turns out not to.

## What's here

```
app/models/aspace2alma/archival_object_record.rb              the ported mapper
app/models/aspace2alma/send_component_marcxml_to_alma_job.rb  the ported orchestration job
spec/models/aspace2alma/archival_object_record_spec.rb               specs for the mapper
spec/models/aspace2alma/send_component_marcxml_to_alma_job_spec.rb   specs for the job
spec/fixtures/files/aspace2alma/resolved_archival_object.json        fixture JSON
```

If this looks good, the move into `lib_jobs` is mostly a straight copy:
1. `archival_object_record.rb` and `send_component_marcxml_to_alma_job.rb` -> `lib_jobs/app/models/aspace2alma/`
2. `resolved_archival_object.json` -> `lib_jobs/spec/fixtures/files/aspace2alma/`
3. the two `_spec.rb` files -> `lib_jobs/spec/models/aspace2alma/`
4. add a `marcao_flag_field` key to `lib_jobs/config/aspace.yml` (see below)

## Design choices made while porting

- **Instance per AO, not a module of class methods.** `MarcAOMapper.to_marc(json)`
  became `ArchivalObjectRecord.new(json).to_marc`, matching the conventions of
  the existing `Aspace2alma::Resource` / `Aspace2alma::TopContainer` (an object
  wrapping a JSON payload, with memoized accessors). `.resolves` and
  `.collection_to_marc` remain class-level, since they aren't per-record.
- **One method per MARC field (or tightly related group of fields),** each
  memoized the way `Aspace2alma::Resource#tag008` etc. are. The original
  built everything as ~30 local variables inside one 420-line method; this
  makes each field independently readable and independently testable, without
  changing what gets written into the record.
- **The six near-identical note-extraction blocks** (`accessrestrict`,
  `scopecontent`, `relatedmaterial`, `acqinfo`, `bioghist`, `processinfo` --
  each "select notes of type X, clean up each one's first subnote") collapsed
  into one private `notes_of_type` + `cleaned_subnote_content` pair, called six
  times. Output is identical; there's just one place to fix if note-cleaning
  logic ever needs to change.
- **The 1xx/6xx/7xx agent-field logic stayed as one method** (`agent_fields`,
  feeding `tag1xx_creator` and `tags6xx_agents`). The original computes both
  sets of fields from exactly the same per-agent derived values (tag number,
  name_type, source_code, formatted name, punctuation, dates, relator
  subfields, etc) in a single pass, and splitting that cleanly in two would
  have meant recomputing all of it twice or threading a dozen values between
  methods -- more risk for no real gain in clarity.
- Everything else (the literal MARC field templates, regexes, tag-number and
  indicator logic, the `xml_escape`/`remove_tags` helpers) is intended to be
  **behaviorally unchanged** from `MarcAOMapper`.

## Things worth deciding/fixing for real, flagged in code comments

- **`tag008_date_type` can end up `nil`.** In `MarcAOMapper#to_marc`, when an AO
  has no `dates`, `tag008_date_type` is left `nil` (rather than defaulting to
  `'n'` the way `date_type` does), which makes controlfield 008 one character
  short. This looks like a pre-existing latent bug. The port preserves it
  faithfully (see the comment on `#parsed_dates`) and adds a spec
  (`'when the AO has no dates'`) that documents -- but doesn't yet assert a
  fix for -- the current behavior. Worth deciding whether to fix it as part of
  the migration or file it separately.
- **Every agent gets a 6xx/7xx "added entry," and creators *additionally* get a
  1xx "main entry"** built from the same name/punctuation/dates -- e.g. a
  creator who is an `agent_person` produces both a `100` and a `700` for the
  same name. That's the existing behavior (preserved here, and visible in the
  spec's fixture/assertions); flagging it because it reads like an oversight
  rather than a deliberate cataloging choice, and is the kind of thing that's
  much easier to question once the code lives somewhere with test coverage.
- **`main_term` (datafield 6xx/7xx subfield `$a` for subjects) is not run
  through `xml_escape`**, unlike titles and notes. Possibly intentional
  (subject terms are unlikely to contain markup), but inconsistent with the
  rest of the mapper -- worth a second look.

## Finding flagged resources and modified AOs over plain REST

`MarcAOExporter` answers two questions with direct Sequel/DB access that --
because it runs *inside* the ArchivesSpace backend -- it never had to think
twice about. Both turn out to be answerable from outside, over plain REST, with
**no new plugin endpoint required**:

1. **"Which resources are flagged for AO-level export?"** The plugin asks
   `UserDefined.filter(AppConfig[:marcao_flag_field] => true)`. I checked
   whether Solr could answer the same question (it would have been the
   natural way to ask "outside" ArchivesSpace) and it can't: nothing in
   `indexer/app/lib/indexer_common.rb`'s `add_document_prepare_hook` blocks
   reads `user_defined`/`boolean_1` data, and the generic full-text indexing
   path (`extract_string_values`/`build_fullrecord`) only ever collects
   *String* values, so a `true`/`false` flag would never make it into Solr even
   incidentally. *However* -- `user_defined` is registered as a nested record
   on resources (`UserDefineds` mixin -> `def_nested_record`), which means it's
   embedded directly in the plain JSONModel rendering of every resource. A
   batch `GET .../resources?id_set=...` (exactly what `get_resolved_objects_from_ids`
   already does) returns it for free: `resource.dig('user_defined', 'boolean_1')`.
   So the job fetches full resource records and filters client-side.
2. **"Which AOs under a flagged resource changed since the last run?"** The
   plugin asks `ArchivalObject.any_repo.filter(root_record_id: id).filter { system_mtime > since }`.
   Unlike `user_defined`, both halves of this filter *are* indexed in Solr for
   archival_objects -- `indexer_common.rb` populates `doc['resource']` from
   `record['record']['resource']['ref']`, and `system_mtime` is indexed
   generically for every record type -- so the stock, public
   `/repositories/:id/search` endpoint answers it directly:
   `q: resource:"<resource_uri>" AND system_mtime:[<since> TO *]`,
   `type: ['archival_object']`.

This is good news for the migration: it means the *entire* `as_marcao` backend
half (the exporter, the flag-checking, the modified-since query) can move to
`lib_jobs` without leaving anything behind in the plugin.

## `Aspace2alma::SendComponentMarcxmlToAlmaJob`

The ported orchestration job (`MarcAOExporter` -> `LibJob` subclass, parallel to
`SendMarcxmlToAlmaJob`). Per run, it:
1. logs in (`aspace_login`) and computes `since` from `most_recent_dataset&.report_time`
   (replacing the plugin's `report.json`-based `last_success_at`), with the same
   small overlap buffer the plugin uses (`OVERLAP_BUFFER`, was `WINDOW_SECONDS`);
2. for each repository, finds flagged resource URIs (REST + client-side filter
   on `user_defined`, see above);
3. for each flagged resource, finds AO ids modified since `since` via
   `/repositories/:id/search` (see above), then resolves their full JSON via
   `get_resolved_objects_from_ids(..., Aspace2alma::ArchivalObjectRecord.resolves)`
   -- replacing the plugin's `URIResolver.resolve_references`;
4. maps everything in one pass with `ArchivalObjectRecord.collection_to_marc`
   and writes/delivers it with `File.write` + `Aspace2almaHelper`, reusing the
   same defensive rename-before-overwrite dance as `SendMarcxmlToAlmaJob`
   (under a different filename, `MARC_component_out.xml`, so the two exports
   can't collide on the SFTP side);
5. records a one-line report via `LibJob`/`DataSet`, replacing `report.json`.

Things worth deciding for real before porting this one:
- **Where `marcao_flag_field` lives.** The draft reads it from
  `Rails.application.config.aspace.marcao_flag_field` (so it'd need adding to
  `config/aspace.yml`, the way `repos` already lives there) rather than from
  `ENV`, since it's a fixed identifier (`boolean_1` etc.) rather than a secret
  -- but either would work.
- **Whether Alma's import side cares about the filename.** `MARC_component_out.xml`
  is a guess at a name that (a) won't collide with `SendMarcxmlToAlmaJob`'s
  `MARC_out.xml` on the SFTP server and (b) lets Alma's import profile route
  collection-level vs. component-level records differently if it needs to --
  worth confirming against however the Alma side is actually configured.
- **Error handling/retries.** `SendMarcxmlToAlmaJob` and `GetEadsJob` both wrap
  their REST calls in `retries`/`rescue Net::ReadTimeout` loops and accumulate
  `@errors` for the report; this draft leaves that out to keep the
  REST-call shape easy to review, but the real port should bring it back.

## Fixture

`resolved_archival_object.json` is **hand-built**, not captured from a real
ArchivesSpace instance -- it's shaped to exercise each branch in the mapper
(a creator `agent_person` with an LCNAF identifier and dates; a locally-sourced
`agent_corporate_entity` subject agent; an `lcsh` subject with a compound term
that gets split into subfields; a non-`lcsh` `genre_form` subject; a subject
whose term type is filtered out; markup in notes; a `sub_container`-resolved
top container; etc). Swapping in one or more JSON payloads captured from
production (the way `spec/fixtures/files/aspace2alma/single_container.json`
was captured for the collection-level specs) would make this a much stronger
regression net once the real port begins.
