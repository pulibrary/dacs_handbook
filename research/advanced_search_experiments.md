We had a [ticket about complex boolean queries using the advanced search form](https://github.com/pulibrary/orangelight/issues/4806).

The main issue was that the stakeholder thought that the implicit boolean should stay the same, no matter how the query was constructed, whereas the implicit boolean (at least at the time of this writing) shifts from `AND` to `OR` if there is an `OR` anywhere in the query. If you use explicit booleans, they work as expected.

The experiment below was to see whether we could pass user queries to Solr with less parsing for booleans on our side and still have them work.

The experiments were done against [Orangelight commit](https://github.com/pulibrary/orangelight/tree/e4c112085ca47791477c91c3528667b1c071b98c) and [pul_solr commit](https://github.com/pulibrary/pul_solr/tree/dd932db524484242828b1746b5b4b85b4589fafe).

### Goal
Instead of putting advanced search queries into 'bool' within the JSON, we should put the whole phrase into an Edismax and let Solr sort out the booleans. 

Example of what we want an advanced search to look like:

```json
{"query": {"edismax":{"query":"title_display:(apple OR squishy) AND (cantaloupe OR date)"}}}
```
```bash
TEST_JSON='{"query": {"edismax":{"query":"title_display:(apple OR squishy) AND (cantaloupe OR date)"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://127.0.0.1:53863/solr/orangelight-core-small-test/advanced?wt=json'
```

I am trying to use a different search builder, to bypass the accumulated boolean logic cruft from 10 years of development, but since the default_processor_chain gets added to, not created per search, we always hit the old boolean behaviors

```json
{"query": {"edismax":{"query":"banana","spellcheck.dictionary":"title","qf":"${title_qf}","pf":"${title_pf}"}}}
```
```bash
# 
TEST_JSON='{"query": {"edismax":{"query":"title_display:(apple OR squishy) AND all_fields:(cantaloupe OR date)"}}}'

curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

### spec/system/boolean_searching_spec.rb:70
```json
{"query":{"edismax":{"query": "apple"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "apple"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

### spec/system/boolean_searching_spec.rb:78
Expect docs 1 & 2
Note that for this to pass, we had to add the `mm=1` parameter to the url. Also got expected result with `mm=0`
```json
{"query":{"edismax":{"query":"apple OR banana"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "apple OR banana"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json&mm=1'
```

### spec/system/boolean_searching_spec.rb:87
Expect docs 1 & 2
Note that for this to pass, we had to add the `mm=1` parameter to the url. Also got expected result with `mm=0`
```json
{"query":{"edismax":{"query":"(apple) OR title_display:(banana)"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query":"(apple) OR title_display:(banana)"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json&mm=1'
```
#### Can we do this with qf and pf?
Note that for this to pass, we had to add the `mm=1` parameter to the url. Also got expected result with `mm=0`

I think this only works because both apple and banana are in the title field
```json
{"query":{"edismax":{"query":"apple OR banana", "qf":"${title_qf}","pf":"${title_pf}"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query":"apple OR banana", "qf":"${title_qf}","pf":"${title_pf}"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json&mm=1'

### spec/system/boolean_searching_spec.rb:99
Expect no docs.
Manipulating the `mm` parameter had no effect
```json
{"query":{"edismax":{"query": "apple AND banana"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "apple AND banana"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

### spec/system/boolean_searching_spec.rb:105
Expect doc 6 (should exclude doc 5)
```json
{"query":{"edismax":{"query": "potato AND carrot"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "potato AND carrot"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

### spec/system/boolean_searching_spec.rb:114
Expect doc 7 (should exclude doc 8)

The person who put in the initial ticket thought this should be an *implicit* and, that is, the person should not have to enter the word "AND" between "cantaloupe" and "date"; however, I think the edismax parser defaults to "OR" if there's an "OR" anywhere in the query.

```json
{"query":{"edismax":{"query": "(apple OR squishy) AND title_display:(cantaloupe AND date)"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "(apple OR squishy) AND title_display:(cantaloupe AND date)"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```
#### Can we do this with qf and pf?
```json
{"query":{"edismax":{"query": "(apple OR squishy) AND (cantaloupe AND date)", "qf":"${title_qf}","pf":"${title_pf}"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "(apple OR squishy) AND (cantaloupe AND date)", "qf":"${title_qf}","pf":"${title_pf}"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

### spec/system/boolean_searching_spec.rb:128
Expect docs 7 & 8

```json
{"query":{"edismax":{"query": "(apple OR squishy) AND title_display:(cantaloupe OR date)"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "(apple OR squishy) AND title_display:(cantaloupe OR date)"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

#### Can we do this with qf and pf?
```json
{"query":{"edismax":{"query": "(apple OR squishy) AND (cantaloupe OR date)", "qf":"${title_qf}","pf":"${title_pf}"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "(apple OR squishy) AND (cantaloupe OR date)", "qf":"${title_qf}","pf":"${title_pf}"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

## *NOTE* these tests have a different set of documents from the previous tests

### spec/system/boolean_searching_spec.rb:154
Expect doc 1 only

```json
{"query":{"edismax":{"query": "title_display:apple AND author_main_unstem_search:banana"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "title_display:apple AND author_main_unstem_search:banana"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

#### Can we do this with qf and pf?
```json
{"query":{"edismax":{"query": "$title_qf:apple AND $author_pf:banana"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "$title_qf:apple AND $author_pf:banana"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```


### spec/system/boolean_searching_spec.rb:164
Expect doc 2, should exclude doc 1

```json
{"query":{"edismax":{"query": "title_display:apple AND title_display:banana"}}}
```
```bash
TEST_JSON='{"query":{"edismax":{"query": "title_display:apple AND title_display:banana"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```
