---
layout: default
title: Maintenance
---
### Infrastructure

* To run all the DACS playbooks: `ansible-playbook playbooks/dacs_playbooks.yml -e runtime_env=staging`
* To run all the Rails DACS playbooks: `ansible-playbook playbooks/dacs_playbooks.yml -e runtime_env=staging -t rails`
* To run all the PHP DACS playbooks (including Drupal): `ansible-playbook playbooks/dacs_playbooks.yml -e runtime_env=staging -t php`
* To run all the Vue DACS playbooks: `ansible-playbook playbooks/dacs_playbooks.yml -e runtime_env=staging -t vue`
