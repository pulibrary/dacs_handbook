# Reservoir Experiment

## How to set it up

Follow intstructions [here](https://github.com/pulibrary/dacs_handbook/blob/main/reservoir.md)

## What we did 

1. Set-up locally
2. Successfully indexed randon marcxml data sets from PUL and SCSB. 
3. In progress [setup](https://github.com/pulibrary/princeton_ansible/pull/6180) of a functional staging environment. 
4. Indexed the [sample](https://github.com/pulibrary/dacs_handbook/blob/main/research/helpful_data.md) overlapping marcxml data set locally. The indexing was done using the Gold Rush circa 2021 matching algorithm that ships with reservoir. 
5. Did some basic analysis of the clusters produced from step 4. We found 81,229 records from the sample set became part of a cluster of 2 or more records. 

## Next Steps

1. Try the [gold rush 2024 algorithm](https://github.com/indexdata/reservoir/blob/master/js/matchkeys/goldrush2024/goldrush.mjs) with our sample data set [insert link to set]
2. Produce a report from the gold rush 2024 clustered data set grouped cluster including each individual records local ID values. This will allow for comparison with other tools we’ve looked at in the clustering space. This will likely require spending time to understand the [CQL interface](https://github.com/folio-org/raml-module-builder?tab=readme-ov-file#cql-contextual-query-language) for querying aggregated data 
3. Return to getting the server instance of reservoir fully functional in staging. 
4. Explore the [OAI ingest](https://github.com/indexdata/reservoir/?tab=readme-ov-file#oai-pmh-client) option to begin aggregating POD data in the staging environment. 
5. Explore the [OAI export](https://github.com/indexdata/reservoir/?tab=readme-ov-file#oai-pmh-server) option as a means to experiment with indexing the clustered data set in an test orangelight instance. 
6. Work on aligning Gold Rush 2024 with PUL’s Gold Rush preferences for discovery. 

## References

* [Reservoir repo](https://github.com/indexdata/reservoir)
* [API Docs](https://s3.amazonaws.com/indexdata-docs/api/reservoir/reservoir.html)
* 
