### Records in Contexts

[Records in Contexts](https://www.ica.org/ica-network/expert-groups/egad/records-in-contexts-ric/]) ("RiC") is the new international descriptive standard for archives. It consists of a conceptual model and an owl ontology. 
While the ontology is itself just one of many possible implementations, RiC assumes implementation as linked data.

Adoption of Records in Contexts by PUL and/or the community will mean significant changes to the data structures and infrastructure involved. 
We don't yet know how all of that will shake out (and in particular the role that ArchivesSpace will play in it), but we can probably anticipate an 
RDF serialization and triplestore or wikibase being involved.

There is no open-source content management application yet that supports Records in Contexts, which has made testing this standard, including by archivists, difficult. 

To address this, I've developed a [wiki-cloud implementation](https://recordsincontexts.wikibase.cloud/wiki/Main_Page) of the 
Records in Contexts conceptual model to explore how the record structure will change and what it would take to get collection-level records out of a 
wikibase and into bibdata. The wikibase currently defines the first- (Wikidata) and second-level (RiC) entities and properties and some minimal sample data. Work completed to date includes:

- make implementation decisions for all RiC-CM entities, attributes, and relations (datatypes, object properties etc.)
- create Item records for all RiC-CM entities, attributes, and relations
- add Wikidata Items to facilitate scoping and constraints
- add subject and object type constraints to all Item records
- identify controlled vocabularies required by certain RiC properties
- create Item records for vocabularies and vocabulary terms
- create Cradle forms to facilitate data entry

### Next Steps

- [ ] Develop SPARQL queries to get records out
- [ ] Investigate transformations needed to make the data conformant for Bibdata
- [ ] Develop an EAD2RiC CSV transformation for import
- [ ] Develop an OpenRefine workflow for import based on the CSV export

### Beyond Princeton

I'm currently working with the SAA Description Section on making this wikibase available to the archives community for test-driving RiC. 
We'll be offering a program in the fall.
