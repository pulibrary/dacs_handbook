---
layout: default
title: Aspace
---
# ArchivesSpace
ArchivesSpace is our Archival Content Management System. It contains our archival data of record.

## Contacts:
* Product Owner: Will Clements
* Technical Lead: Regine Heberlein
* Governance: ArchivesSpace Operation Group (SC)
* Slack channel: #aspace_help
* github repo tracking our config options: https://github.com/pulibrary/aspace-config

## Active Integrations:
* Alma
  * [aspace2alma](https://github.com/pulibrary/aspace_helpers): 
  This integration is maintained in-house. It runs on lib_jobs (but is not a rails app) from the `aspace_helpers/reports/aspace2alma` directory. It sends collection-level records, holdings, and items to Alma.
  * [as_marcao plugin](https://github.com/hudmol/as_marcao): 
  This integration relies on a plugin made for us by Hudson Molonglo. It sends component records and holdings for select collections.
* [pulfalight](https://github.com/pulibrary/pulfalight): 
  hourly incremental update of the finding aids site
* [figgy](https://github.com/pulibrary/figgy): 
  digital repository persists DAOs to ArchivesSpace
* [abid](https://github.com/pulibrary/abid): 
  generates absolute identifiers and saves them to ArchivesSpace

## Login:
* contact Will Clements for an account
* Prod login: https://aspace.princeton.edu/staff/auth/cas
* Staging login: https://aspace-staging.princeton.edu/staff/auth/cas

## API:
* documentation: https://archivesspace.github.io/archivesspace/api/#introduction
* Prod base URL: https://aspace.princeton.edu/staff/api
* Staging base URL: https://aspace-staging.princeton.edu/staff/api

## Server support:
* Hosting institution: Lyrasis
* Email: support@lyrasis.zendesk.com


## Setting up local development

[Based on this documentation](https://archivesspace.github.io/tech-docs/development/dev.html)

```
git clone git@github.com:archivesspace/archivesspace.git
cd archivesspace
docker-compose -f docker-compose-dev.yml up
cd ./common/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.23/mysql-connector-java-8.0.23.jar && cd -
echo "java openjdk-19.0.2" > .tool-versions
asdf plugin add java
asdf install
./build/run bootstrap (it took 2 minutes and 45 seconds)
gzip -dc ./build/mysql_db_fixtures/accessibility.sql.gz | mysql --host=127.0.0.1 --port=3306  -u root -p123456 archivesspace
brew install supervisord
supervisord -c supervisord/archivesspace.conf
```

* The staff interface will be at http://localhost:3000/ (username is admin, password is admin)
* The PUI will be at http://localhost:3001/
* The API will be at http://localhost:4567/
* You can access the database with `mysql --host=127.0.0.1 --port=3306  -u root -p123456 archivesspace`

### Using Supervisord
#### run all of the services
`supervisord -c supervisord/archivesspace.conf`

#### run in api mode (backend + indexer only)
`supervisord -c supervisord/api.conf`

#### run just the backend (useful for trying out endpoints that don't require Solr)
`supervisord -c supervisord/backend.conf`

### Installing a plugin in your local development

1. `cp common/config/config-example.rb common/config/config.rb`
2. Edit the plugin array in `config/config.rb` to add your plugin.
3. Add the code for your plugin to the `plugins` directory.
4. Ctrl+C your supervisord and start it again.
