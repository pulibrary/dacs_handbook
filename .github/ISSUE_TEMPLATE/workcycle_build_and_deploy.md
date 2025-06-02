---
name: deployments
about: Run playbooks and deployments for all applications
title: 'Run deployments for the week starting on [INSERT DATE HERE]'
labels: ['deployments', 'playbooks']
assignees: ''

---
## List of applications

### Drupal PHP applications
#### Byzantine Translations

- Playbook
  - [ ] [Production](https://byzantine.lib.princeton.edu/)
  - [ ] [Staging](https://byzantine-staging.lib.princeton.edu/)

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
