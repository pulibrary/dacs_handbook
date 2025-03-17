---
name: deployments
about: Run playbooks and deployments for all applications
title: 'Run deployments for the week starting on [INSERT DATE HERE]'
labels: ['deployments', 'playbooks']
assignees: ''

---
## List of applications
### Ruby applications
#### Allsearch API
- Deploy
  - [ ] [Staging](https://allsearch-api-staging.princeton.edu/)
  - [ ] [Production](https://allsearch-api.princeton.edu/)
#### Approvals
- Deploy
  - [ ] [Staging](https://approvals-staging.princeton.edu/)
  - [ ] [Production](https://approvals.princeton.edu/)
#### Bibdata
- Deploy
  - [ ] [Staging](https://bibdata-staging.lib.princeton.edu/)
  - [ ] [QA](https://bibdata-qa.princeton.edu/)
  - [ ] [Production](https://bibdata.princeton.edu/)
#### DSS
- Deploy
  - [ ] [Staging](https://dss-staging.princeton.edu/catalog)
  - [ ] [Production](https://dss.princeton.edu/catalog)
#### Lib Jobs
- Deploy
  - [ ] [Staging](https://lib-jobs-staging.princeton.edu/)
  - [ ] [Production](https://lib-jobs.princeton.edu/)
##### Aspace Helpers
Shares a server with lib-jobs, no separate playbook
- Deploy
  - [ ] Staging (no front end)
  - [ ] Production (no front end)
#### Lockers
- Deploy
  - [ ] [Staging](https://lockers-and-study-spaces-staging.princeton.edu/)
  - [ ] [Production](https://lockers-and-study-spaces.princeton.edu/)
#### Orangelight
- Deploy
  - [ ] [Staging](https://catalog-staging.princeton.edu/)
  - [ ] [QA](https://catalog-qa.princeton.edu/)
  - [ ] [Production](https://catalog.princeton.edu/)
#### RePec
- Deploy
  - [ ] [Staging](https://repec-staging.princeton.edu/)
  - [ ] [Production](https://repec-prod.princeton.edu/)
### Vue applications
#### Allsearch Frontend
- Deploy
  - [ ] [Staging](https://allsearch-staging.princeton.edu/)
  - [ ] [Production](https://allsearch.princeton.edu/)
#### Static Tables
- Deploy
  - [ ] [Staging](https://static-tables-staging.princeton.edu/)
  - [ ] [Production](https://static-tables-prod.princeton.edu/)
### Drupal PHP applications
#### Byzantine Translations
- Deploy
  - [ ] [Staging](https://byzantine-staging.lib.princeton.edu/)
  - [ ] [Production](https://byzantine.lib.princeton.edu/)
- Playbook
  - [ ] [Production](https://byzantine.lib.princeton.edu/)
  - [ ] [Production](https://byzantine.lib.princeton.edu/)

### Other (non-Drupal) PHP applications
#### Princeton and Slavery
Note: Private repository, cannot use Tower to deploy, must deploy from local environment
- Deploy
  - [ ] [Staging](https://slavery-staging.princeton.edu/)
  - [ ] [Production](https://slavery.princeton.edu/)
- Playbook
  - [ ] [Production](https://slavery.princeton.edu/)
#### Video Reserves
Note: Private repository, cannot use Tower to deploy, must deploy from local environment
- Deploy
  - [ ] [Staging](https://videoreserves-staging.princeton.edu/hrc/vod/clip.php) (forwards to 'days of heaven')
  - [ ] [Production](https://videoreserves-prod.princeton.edu/hrc/vod/clip.php) (forwards to 'days of heaven')
- Playbook
  - [ ] [Staging](https://videoreserves-staging.princeton.edu/hrc/vod/clip.php) (forwards to 'days of heaven')
  - [ ] [Production](https://videoreserves-prod.princeton.edu/hrc/vod/clip.php) (forwards to 'days of heaven')

  

#### Next Work Cycle

- [ ] Create ticket using the Work Cycle Deployment tempate slotted for the next work cycle. 

#### Notes
[Documentation on how to run all the staging playbooks at once using different tags.](https://github.com/pulibrary/dacs_handbook/blob/main/maintenance.md)

[Ansible playbooks](https://github.com/pulibrary/princeton_ansible/tree/main/playbooks)
