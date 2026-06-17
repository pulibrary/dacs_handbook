# frozen_string_literal: true
require 'rails_helper'

# This spec is written against the Aspace2alma::ArchivalObjectRecord draft in
# this directory's app/models/aspace2alma/archival_object_record.rb. To run it:
#   1. copy archival_object_record.rb into lib_jobs' app/models/aspace2alma/
#   2. copy resolved_archival_object.json into
#      lib_jobs' spec/fixtures/files/aspace2alma/
#   3. copy this file into lib_jobs' spec/models/aspace2alma/
#
# The fixture is a hand-built (not captured-from-production) resolved
# archival_object JSONModel rendering -- the kind of payload
# Aspace2alma::ArchivalObjectRecord.resolves is meant to produce. Replacing it
# with a real payload captured from ArchivesSpace (the way
# spec/fixtures/files/aspace2alma/single_container.json was) would make this
# spec considerably more valuable as a regression net during the migration.
RSpec.describe Aspace2alma::ArchivalObjectRecord do
  let(:resolved_ao_json) { JSON.parse(file_fixture('aspace2alma/resolved_archival_object.json').read) }
  let(:record) { described_class.new(resolved_ao_json) }
  let(:marc) { Nokogiri::XML(record.to_marc) }

  describe '.resolves' do
    it 'lists the references that must be resolved before mapping' do
      expect(described_class.resolves).to eq(
        %w[subjects linked_agents top_container top_container::container_locations]
      )
    end
  end

  describe '.collection_to_marc' do
    it 'wraps each mapped record in a MARCXML <collection>' do
      collection = Nokogiri::XML(described_class.collection_to_marc([resolved_ao_json, resolved_ao_json]))

      expect(collection.root.name).to eq('collection')
      # the <collection> element declares "marc" as a prefix for the default
      # namespace it's in, so -- as elsewhere in this spec suite, e.g.
      # send_marcxml_to_alma_job_spec.rb -- records must be queried as marc:record
      expect(collection.xpath('//marc:record').size).to eq(2)
    end
  end

  describe '#to_marc' do
    it 'produces a single well-formed <record>' do
      expect(marc.root.name).to eq('record')
    end

    it 'maps the ref_id to controlfield 001 and datafields 035 and 099' do
      expect(marc.at_xpath("//controlfield[@tag='001']").content).to eq('C0140_c00123')
      expect(marc.at_xpath("//datafield[@tag='035']/subfield[@code='a']").content).to eq('(PULFA)C0140_c00123')
      expect(marc.at_xpath("//datafield[@tag='099']/subfield[@code='a']").content).to eq('C0140_c00123')
    end

    it 'derives the date type and date span for controlfield 008 from the first date' do
      tag008 = marc.at_xpath("//controlfield[@tag='008']").content

      expect(tag008[6]).to eq('e')         # tag008_date_type: 'e' because the date has a `begin`
      expect(tag008[7..10]).to eq('1925')  # date1
      expect(tag008[11..14]).to eq('1926') # date2
    end

    it 'derives a 041 language code from the position ArchivesSpace stores it at in controlfield 008' do
      expect(marc.at_xpath("//datafield[@tag='041']/subfield[@code='c']").content).to eq('eng')
    end

    it 'builds a 046 with the begin/end years when controlfield 008 carries 4-digit dates' do
      tag046 = marc.at_xpath("//datafield[@tag='046']")

      expect(tag046.at_xpath("subfield[@code='c']").content).to eq('1925')
      expect(tag046.at_xpath("subfield[@code='e']").content).to eq('1926')
    end

    it 'builds a 245 with the (escaped) title and a $f date span subfield' do
      tag245 = marc.at_xpath("//datafield[@tag='245']")

      expect(tag245.at_xpath("subfield[@code='a']").content).to eq('Letter from Jane Doe to John Smith')
      expect(tag245.at_xpath("subfield[@code='f']").content).to eq('1925-1926')
    end

    it 'builds a 1xx for the creator agent: name, punctuation, dates and an authority identifier' do
      tag100 = marc.at_xpath("//datafield[@tag='100']")

      expect(tag100['ind1']).to eq('1') # agent_person => name_type 1
      expect(tag100['ind2']).to eq('0') # source 'lcnaf' => source_code 0
      expect(tag100.at_xpath("subfield[@code='a']").content).to eq('Doe, Jane,') # trailing ',' because dates follow
      expect(tag100.at_xpath("subfield[@code='d']").content).to eq('1899-1990')
      expect(tag100.at_xpath("subfield[@code='0']").content).to eq('http://id.loc.gov/authorities/names/n12345678')
    end

    it 'builds a 6xx for non-creator agents, adding subfields 2 and 5 for locally-sourced names' do
      tag610 = marc.at_xpath("//datafield[@tag='610']")

      expect(tag610['ind2']).to eq('7') # source 'local' => source_code 7
      expect(tag610.at_xpath("subfield[@code='a']").content).to eq('Spring Letters Press.')
      expect(tag610.at_xpath("subfield[@code='2']").content).to eq('local')
      expect(tag610.at_xpath("subfield[@code='5']").content).to eq('NjP')
    end

    it 'maps lcsh subjects to a 6xx, splitting compound terms into subfields, with no $2' do
      tag650 = marc.at_xpath("//datafield[@tag='650']")

      expect(tag650['ind2']).to eq('0') # lcsh => source_code 0
      expect(tag650.at_xpath("subfield[@code='a']").content).to eq('Poetry')
      expect(tag650.at_xpath("subfield[@code='y']").content).to eq('20th century')
      expect(tag650.at_xpath("subfield[@code='2']")).to be_nil
    end

    it 'maps non-lcsh subjects to a 6xx and records the source vocabulary in $2' do
      tag655 = marc.at_xpath("//datafield[@tag='655']")

      expect(tag655['ind2']).to eq('7')
      expect(tag655.at_xpath("subfield[@code='a']").content).to eq('Correspondence')
      expect(tag655.at_xpath("subfield[@code='2']").content).to eq('aat')
    end

    it 'omits subjects whose term type is not one of the relevant ones (e.g. corporate_body)' do
      expect(marc.xpath("//datafield[@tag='651']")).to be_empty
      expect(marc.xpath('//subfield').map(&:content)).not_to include('Princeton University')
    end

    it 'strips EAD markup from notes, normalizes whitespace, and maps them to MARC fields' do
      expect(marc.at_xpath("//datafield[@tag='520']/subfield[@code='a']").content)
        .to eq('Correspondence concerning the publication of Spring Letters.')
      expect(marc.at_xpath("//datafield[@tag='545']/subfield[@code='a']").content)
        .to eq('Jane Doe (1899-1990) was a poet and editor.')
    end

    it 'maps the accessrestrict note to 506' do
      expect(marc.at_xpath("//datafield[@tag='506']/subfield[@code='a']").content).to eq('Restricted until 2050.')
    end

    it 'builds an 856 linking to the finding aid for this AO' do
      tag856 = marc.at_xpath("//datafield[@tag='856']")

      expect(tag856.at_xpath("subfield[@code='u']").content)
        .to eq('https://findingaids.princeton.edu/catalog/C0140_c00123')
    end

    it 'builds a 982 from the resolved (sub_container) top container location' do
      expect(marc.at_xpath("//datafield[@tag='982']/subfield[@code='c']").content).to eq('scarcpph')
    end

    context 'when there is no accessrestrict note' do
      let(:resolved_ao_json) do
        json = JSON.parse(file_fixture('aspace2alma/resolved_archival_object.json').read)
        json['notes'] = json['notes'].reject { |note| note['type'] == 'accessrestrict' }
        json
      end

      it 'falls back to the default restriction statement' do
        expect(marc.at_xpath("//datafield[@tag='506']/subfield[@code='a']").content).to eq(described_class::DEFAULT_RESTRICTION)
      end
    end

    context 'when the AO has no instances / top containers' do
      let(:resolved_ao_json) do
        JSON.parse(file_fixture('aspace2alma/resolved_archival_object.json').read).merge('instances' => [])
      end

      it 'omits the 982' do
        expect(marc.xpath("//datafield[@tag='982']")).to be_empty
      end

      it 'falls back to leader/06 = "t"' do
        expect(marc.at_xpath('//leader').content).to start_with('00000nt')
      end
    end

    context 'when the AO has no dates' do
      let(:resolved_ao_json) do
        JSON.parse(file_fixture('aspace2alma/resolved_archival_object.json').read).merge('dates' => [])
      end

      it 'omits the 046 and the 245 $f' do
        expect(marc.xpath("//datafield[@tag='046']")).to be_empty
        expect(marc.at_xpath("//datafield[@tag='245']/subfield[@code='f']")).to be_nil
      end
    end
  end
end
