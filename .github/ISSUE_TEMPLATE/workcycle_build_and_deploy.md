---
name: deployments
about: Run playbooks and deployments and for all applications
title: 'Run deployments for the week starting on [INSERT DATE HERE]'
labels: ['deployments', 'playbooks']
assignees: ''

---
## List of applications
### Ruby applications
#### Approvals
- [ ] [Production](https://approvals.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
#### DSS
- [ ] [Production](https://dss.princeton.edu/catalog)
  - [ ] Playbook
  - [ ] Deploy
#### Lib Jobs
- [ ] [Production](https://lib-jobs.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
##### Aspace Helpers
Shares a server with lib-jobs, no separate playbook
- [ ] Staging (no front end)
  - [ ] Deploy
- [ ] Production (no front end)
  - [ ] Deploy
#### Lockers
- [ ] [Production](https://lockers-and-study-spaces.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
#### RePec
- [ ] [Staging](https://repec-staging.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
- [ ] [Production](https://repec-prod.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy

### Vue applications
#### Allsearch Frontend
- [ ] [Production](https://allsearch.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
#### Static Tables
- [ ] [Production](https://static-tables-prod.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy

### Drupal PHP applications
#### Byzantine Translations
- [ ] [Staging](https://byzantine-staging.lib.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
- [ ] [Production](https://byzantine.lib.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
#### ReCAP
- [ ] [Staging](https://recap-staging.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
- [ ] [Production](https://recap.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy

### Other (non-Drupal) PHP applications
#### Princeton and Slavery
Note: Private repository, cannot use Tower to deploy, must deploy from local environment
- [ ] [Production](https://slavery.princeton.edu/)
  - [ ] Playbook
  - [ ] Deploy
#### Video Reserves
Note: Private repository, cannot use Tower to deploy, must deploy from local environment
- [ ] [Staging](https://videoreserves-staging.princeton.edu/hrc/vod/clip.php) (forwards to 'days of heaven')
  - [ ] Playbook
  - [ ] Deploy
- [ ] [Production](https://videoreserves-prod.princeton.edu/hrc/vod/clip.php) (forwards to 'days of heaven')
  - [ ] Playbook
  - [ ] Deploy

#### Notes
[Documentation on how to run all the staging playbooks at once using different tags.](https://github.com/pulibrary/dacs_handbook/blob/main/maintenance.md)

[Ansible playbooks](https://github.com/pulibrary/princeton_ansible/tree/main/playbooks)
