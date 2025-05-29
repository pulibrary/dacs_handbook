---
layout: default
title: Reservoir
---
# Reservoir
[Reservoir Repo](https://github.com/indexdata/reservoir)
[API Documentation](https://s3.amazonaws.com/indexdata-docs/api/reservoir/reservoir.html)

## Running Reservoir locally

1. Install the required software
    * Java: openjdk-21.0.2. Can install with asdf
    * Maven: 3.9.9 or latest version. Can install with homebrew
    * Postgres 12 see instructions for running it as a container
2. Start the Postgres container
    ```
    docker run --name postgres-12 -e POSTGRES_PASSWORD=folio -d -p 5432:5432 postgres:12
    ```
3. Compile the jar
    ```
    mvn install
    ```
4. Set the environment variables
    ```
    export DB_HOST=localhost
    export DB_PORT=5432
    export DB_USERNAME=folio
    export DB_PASSWORD=folio
    export DB_DATABASE=folio_modules
    export OKAPI_TENANT=pul
    export OKAPI_URL=http://localhost:8081
    ```
5. Run the jar
    ```
    java -Dport=8081 --module-path=compiler/ \
   --upgrade-module-path=compiler/compiler.jar:compiler/compiler-management.jar \
   -XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI \
   -jar server/target/mod-reservoir-server-fat.jar
    ```
6. If this is the first time starting the application connect to Postgres and create the database
    ```
    psql -h localhost -U postgres

    CREATE DATABASE folio_modules;
    CREATE USER folio WITH CREATEROLE PASSWORD 'folio';
    GRANT ALL PRIVILEGES ON DATABASE folio_modules TO folio;
    ```
7. If this is the first time starting the application run the initialization command with the application running
    ```
    java -jar client/target/mod-reservoir-client-fat.jar --init
    ```

## Working with Reservoir

1. Configure a matchkey
    Create a matchkey config file:
    ```
    cat js/matchkeys/goldrush/goldrush2024-conf.json
    {
    "id": "goldrush2024-matcher",
    "type": "javascript",
    "url": "https://github.com/indexdata/reservoir/blob/master/js/matchkeys/goldrush2024/goldrush.mjs"
    }
    ```
    Post the config to Reservoir:
    ```
    curl -HX-Okapi-Tenant:$OKAPI_TENANT -HContent-type:application/json \
    $OKAPI_URL/reservoir/config/modules -d @js/matchkeys/goldrush/goldrush-conf.json
    ```
2. Create a pool
    Create a pool config file:
    ```
    cat goldrush2024-pool.json
    {
    "id": "goldrush2024",
    "matcher": "goldrush2024-matcher::matchkey",
    "update": "ingest"
    }
    ```
    Post the pool config:
    ```
    curl -HX-Okapi-Tenant:$OKAPI_TENANT -HContent-type:application/json \
    $OKAPI_URL/reservoir/config/matchkeys -d @goldrush2024-pool.json
    ```
3. To upload files using the UI navigate to

    [localhost:8081/reservoir/upload-form/](http://localhost:8081/reservoir/upload-form/)

    Uploaded files need to have a .xml extension

## Working with the Postgres container

### Connecting to Postgres and basic queries

1. Use `psql` to connect to Postgres
    ```
    psql -h localhost -U postgres
    ```
2. Connect to the database
    ```
    \c folio_modules
    ```

#### Common psql commands
| Function           | Command                                           |
|--------------------|---------------------------------------------------|
| View Schemas       | \dn                                               |
| Inspect the tables | \dt pul_mod_reservoir.*                           |
| View all records   | select * from diku_mod_reservoir.cluster_records; |
