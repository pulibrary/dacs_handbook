### DACS responses to Claude MARCAO draft

1. Design choices 

- **Instance per AO, not a module of class methods.** `MarcAOMapper.to_marc(json)`
  became `ArchivalObjectRecord.new(json).to_marc`, matching the conventions of
  the existing `Aspace2alma::Resource` / `Aspace2alma::TopContainer` (an object
  wrapping a JSON payload, with memoized accessors). `.resolves` and
  `.collection_to_marc` remain class-level, since they aren't per-record.

  - [RH]
  - [CC]  Good direction and a better fit with Aspace2alma::Resource` / `Aspace2alma::TopContainer conventions. It will be easier to collect logic under this new class. 
  - [JS]  I think this is a good direction!  It will help us to use the class to encapsulate more of the logic, so that you don't have to consider how all the various methods interact with each other (unless you are deep in troubleshooting mode).
  - [RL]
  
- **One method per MARC field (or tightly related group of fields),** each
  memoized the way `Aspace2alma::Resource#tag008` etc. are. The original
  built everything as ~30 local variables inside one 420-line method; this
  makes each field independently readable and independently testable, without
  changing what gets written into the record.

  - [RH] that's an improvement!
  - [CC]  It is definitely an improvement. Agree with JS to move this methods to be private and test the interaction not each method.  
  - [JS]  I agree that this is an improvement!  I would suggest making many of these methods private (to help with encapsulation as mentioned above).  I would not recommend independently testing these methods, but rather testing their behavior by making sure that #to_marc produces good data.  I am also not sure about the naming of these -- is `tags544` the most useful method name (genuine question)?
  - [RL]
  
- **The six near-identical note-extraction blocks** (`accessrestrict`,
  `scopecontent`, `relatedmaterial`, `acqinfo`, `bioghist`, `processinfo` --
  each "select notes of type X, clean up each one's first subnote") collapsed
  into one private `notes_of_type` + `cleaned_subnote_content` pair, called six
  times. Output is identical; there's just one place to fix if note-cleaning
  logic ever needs to change.

  - [RH] that's an improvement
  - [CC] an improvement
  - [JS] nice
  - [RL]
  
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

  - [RH] correct, that bit is literally a copy, so merging makes every bit of sense
  - [CC] per your description RH I agree that it's a better approach
  - [JS] agree with RH
  - [RL]

2. Things worth deciding/fixing for real, flagged in code comments

- **`tag008_date_type` can end up `nil`.** In `MarcAOMapper#to_marc`, when an AO
  has no `dates`, `tag008_date_type` is left `nil` (rather than defaulting to
  `'n'` the way `date_type` does), which makes controlfield 008 one character
  short. This looks like a pre-existing latent bug. The port preserves it
  faithfully (see the comment on `#parsed_dates`) and adds a spec
  (`'when the AO has no dates'`) that documents -- but doesn't yet assert a
  fix for -- the current behavior. Worth deciding whether to fix it as part of
  the migration or file it separately.

  - [RH] oh?? good catch! it shouldn't return `nil`, it should return a blank (i.e. a space).
  - [CC] :bug: it's good that it found it. We should look into fixing it.
  - [JS] agree with RH
  - [RL]
  
- **Every agent gets a 6xx/7xx "added entry," and creators *additionally* get a
  1xx "main entry"** built from the same name/punctuation/dates -- e.g. a
  creator who is an `agent_person` produces both a `100` and a `700` for the
  same name. That's the existing behavior (preserved here, and visible in the
  spec's fixture/assertions); flagging it because it reads like an oversight
  rather than a deliberate cataloging choice, and is the kind of thing that's
  much easier to question once the code lives somewhere with test coverage.

  - [RH] no, that one is intentional
  - [CC] Agree with JS. It's a good example for Claude's training.
  - [JS] This terminology (main entry vs added entry) seems like a good thing to educate Claude about (in a repo-specific file or in your global CLAUDE.md?)
  - [RL]
  
- **`main_term` (datafield 6xx/7xx subfield `$a` for subjects) is not run
  through `xml_escape`**, unlike titles and notes. Possibly intentional
  (subject terms are unlikely to contain markup), but inconsistent with the
  rest of the mapper -- worth a second look.

  - [RH] also intentional
  - [CC] thanks for documenting it RH
  - [JS]
  - [RL]

3. Finding flagged resources and modified AOs over plain REST

`MarcAOExporter` answers two questions with direct Sequel/DB access that --
because it runs *inside* the ArchivesSpace backend -- it never had to think
twice about. Both turn out to be answerable from outside, over plain REST, with
**no new plugin endpoint required**:

a. **"Which resources are flagged for AO-level export?"** The plugin asks
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

  - [RH] Nice! I had a notion that was there, but finding it would potentially have cost me a lot of time/sweat&tears.
  - [CC] nice
  - [JS] cool
  - [RL]
   
b. **"Which AOs under a flagged resource changed since the last run?"** The
   plugin asks `ArchivalObject.any_repo.filter(root_record_id: id).filter { system_mtime > since }`.
   Unlike `user_defined`, both halves of this filter *are* indexed in Solr for
   archival_objects -- `indexer_common.rb` populates `doc['resource']` from
   `record['record']['resource']['ref']`, and `system_mtime` is indexed
   generically for every record type -- so the stock, public
   `/repositories/:id/search` endpoint answers it directly:
   `q: resource:"<resource_uri>" AND system_mtime:[<since> TO *]`,
   `type: ['archival_object']`.

  - [RH] ...and we should do this for any record type, not only the ao's
  - [CC] ok
  - [JS]
  - [RL]

This is good news for the migration: it means the *entire* `as_marcao` backend
half (the exporter, the flag-checking, the modified-since query) can move to
`lib_jobs` without leaving anything behind in the plugin.

4. `Aspace2alma::SendComponentMarcxmlToAlmaJob`

The ported orchestration job (`MarcAOExporter` -> `LibJob` subclass, parallel to
`SendMarcxmlToAlmaJob`). Per run, it:
a. logs in (`aspace_login`) and computes `since` from `most_recent_dataset&.report_time`
   (replacing the plugin's `report.json`-based `last_success_at`), with the same
   small overlap buffer the plugin uses (`OVERLAP_BUFFER`, was `WINDOW_SECONDS`);

  - [RH]
  - [CC]
  - [JS]
  - [RL]
   
b. for each repository, finds flagged resource URIs (REST + client-side filter
   on `user_defined`, see above);

  - [RH] add: modified since `since`
  - [CC]
  - [JS]
  - [RL]
   
c. for each flagged resource, finds AO ids modified since `since` via
   `/repositories/:id/search` (see above), then resolves their full JSON via
   `get_resolved_objects_from_ids(..., Aspace2alma::ArchivalObjectRecord.resolves)`
   -- replacing the plugin's `URIResolver.resolve_references`;

  - [RH]
  - [CC]
  - [JS]
  - [RL]
   
d. maps everything in one pass with `ArchivalObjectRecord.collection_to_marc`
   and writes/delivers it with `File.write` + `Aspace2almaHelper`, reusing the
   same defensive rename-before-overwrite dance as `SendMarcxmlToAlmaJob`
   (under a different filename, `MARC_component_out.xml`, so the two exports
   can't collide on the SFTP side);

  - [RH] I like "defensive rename-before-overwrite dance"! I came up with the dance, and now it has a name! :-)
  - [CC] fun!
  - [JS] 💃
  - [RL]
   
e. records a one-line report via `LibJob`/`DataSet`, replacing `report.json`.

  - [RH]
  - [CC] JS, Thanks for providing the location in lib-jobs
  - [JS] It would be nice to also register the job status (Success or Failure) so that it shows up in https://lib-jobs.princeton.edu/status and we get an alert if it fails.  You can do this with `RecentJobStatus.register(job: 'SendComponentMarcxmlToAlmaJob', status: Success())` or `RecentJobStatus.register(job: 'SendComponentMarcxmlToAlmaJob', status: Failure('description of this horrible error'))` (example in lib_jobs/app/models/tmas_gate_counts/job.rb)
  - [RL]

Things worth deciding for real before porting this one:
- **Where `marcao_flag_field` lives.** The draft reads it from
  `Rails.application.config.aspace.marcao_flag_field` (so it'd need adding to
  `config/aspace.yml`, the way `repos` already lives there) rather than from
  `ENV`, since it's a fixed identifier (`boolean_1` etc.) rather than a secret
  -- but either would work.

  - [RH] adding it to aspace.yml sounds fine to me?
  - [CC] I would keep both to be safe and to be able to test easier.
  - [JS] Maybe have an environment variable with a fallback value in config/aspace.yml?  Using an environment variable keeps things more flexible -- we don't have to deploy a change to aspace.yml if we just want to test something out on staging.
  - [RL]
  
- **Whether Alma's import side cares about the filename.** `MARC_component_out.xml`
  is a guess at a name that (a) won't collide with `SendMarcxmlToAlmaJob`'s
  `MARC_out.xml` on the SFTP server and (b) lets Alma's import profile route
  collection-level vs. component-level records differently if it needs to --
  worth confirming against however the Alma side is actually configured.

  - [RH] we tell Alma what filename to expect/accept, so that shouldn't be an issue
  - [CC] nice
  - [JS]
  - [RL]
  
- **Error handling/retries.** `SendMarcxmlToAlmaJob` and `GetEadsJob` both wrap
  their REST calls in `retries`/`rescue Net::ReadTimeout` loops and accumulate
  `@errors` for the report; this draft leaves that out to keep the
  REST-call shape easy to review, but the real port should bring it back.

  - [RH] okey-dokey
  - [CC] nice
  - [JS]
  - [RL]

5. Fixture

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

- [RH] this probably worries me the most--the fact that the fixture Claude used is one it created to fit its code. 
So before we do anything else, we'd need to run the tests over real fixtures.
- [CC] agree
- [JS] agree with RH
- [RL]
