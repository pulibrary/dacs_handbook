---
layout: default
title: Aspace 4 Docker
---
# ArchivesSpace
ArchivesSpace is our Archival Content Management System. It contains our archival data of record.## Setting up local development

1. Starting from v4.x, ArchivesSpace supports Docker images. Follow steps [here](https://f68ffde9.archivesspace-tech-docs.pages.dev/administration/docker/). This promises to be a straightforward path to local installation.

To run any of the setup scripts from inside docker:

- `docker exec -it archivesspace bash` # this gives you a shell on the archivesspace container and access to the distribution files
- `archivesspace@9ed453c46a9f:/$ cd archivesspace/scripts/`
- `archivesspace@9ed453c46a9f:/archivesspace/scripts$ ls` #to see what's there, returns
  `backup.bat  backup.sh  ead_export.bat  ead_export.sh  find-base.sh  initialize-plugin.bat  initialize-plugin.sh  password-reset.bat  password-reset.sh  rb  setup-database.bat  setup-database.sh`
- `archivesspace@9ed453c46a9f:/archivesspace/scripts$ ./setup-database.sh`

The Docker Compose sets up an nginx proxy server that forwards the standard API ports to various endpoints as seen in `proxy-config/default.conf`.

The PUI will be at localhost and the SUI will be at localhost/staff

The REST API will be at localhost/staff/api

The OAI API will be at localhost/oai

### Installing a plugin in your local development

1. Stop aspace if it is running. `docker compose stop`
2. Copy or clone the plugin to the `plugins/` folder of ArchivesSpace, this can not be a symlink to the plugin repo.
3. Edit the plugin array in `config/config.rb` to add your plugin. The plugins listed will load in order.
4. The as_marcao plugin requires the [user_defined_in_basic plugin](https://github.com/hudmol/user_defined_in_basic) and it should be loaded before the as_marcao plugin.

Example config for user_defined_in_basic
```
AppConfig[:user_defined_in_basic] = {
  "accessions" => ["date_1", "text_1", "text_2", "text_3", "boolean_1", "boolean_2", "boolean_3", "date_2", "string_1", "string_2", "string_3", "string_4", "real_1", "real_2", "enum_2"],
  "digital_objects" => [],
  "resources" => ["boolean_1"],
  "hide_user_defined_section" => true
}
```
5. Example config for as_marcao
```
AppConfig[:marcao_schedule] = '22 2 * * *'
AppConfig[:marcao_flag_field] = 'boolean_1'
AppConfig[:marcao_sftp_host] = '127.0.0.1'
AppConfig[:marcao_sftp_user] = 'a_user'
AppConfig[:marcao_sftp_password] = 'secret password'
AppConfig[:marcao_sftp_path] = '/remote/path'
AppConfig[:marcao_sftp_timeout] = 30
```
6. Add any required configuration to `config/config.rb`
7. Restart aspace `docker compose up --detach`, logs can be followed in the logs tab for the archivesspace container in docker desktop.
8. To test the as_marcao plugin first login to the user interface at `localhost/staff`. The default username is `admin` and the default password is `admin`
9. Click `Browse` and select `Resources`
10. Edit a Resource you want to export and select the checkbox for `Boolean 1` as defined in the example config. This is what tells as_marcao to export this Resource. If the `Boolean 1` checkbox is not visible the `user_defined_in_basic` plugin is not loading or is incorrectly configured.
11. Login to aspace to get a session token.
```
curl -s -F  password="admin" "http://localhost/staff/api/users/admin/login"  
```
12. The response should be JSON with a session property. Set it as an environment variable for future use.
```
export SESSION="yoursessiontoken"
```
11. Send a GET request to `/staff/api/marcao/last_report`
```
curl -H "X-ArchivesSpace-Session: $SESSION" "http://localhost/staff/api/marcao/last_report"
```
12. You should this response if there have been no exports
```
{"error":"no report"}
```
or a message with details of the latest export.
```
{
  "status":"sftp_fail",
  "last_success_at":null,
  "export_started_at":"2025-10-21 20:32:13 +0000",
  "export_completed_at":"2025-10-21 20:36:44 +0000",
  "export_file":"/archivesspace/data/shared/marcao/marcao_export.xml",
  "sftp_host":"127.0.0.1",
  "resource_ids_selected":[1],
  "archival_objects_exported":10,
  "error":"#<Java::JavaNet::ConnectException: Connection refused>"
}
```
If you get a 404 then the `as_marcao` plugin is not being loaded successfully.
