# How to set up continuous deployment pipeline using CircleCI

We have a [self-hosted CircleCI Machine Runner](https://circleci.com/docs/runner-overview/#machine-runner-use-case) deployed using Nomad (see [Prancible PR](https://github.com/pulibrary/princeton_ansible/pull/6136)).

## Set up SSH Keys
In order for this runner to be able to deploy to our infrastructure, you have to create an SSH key to put into the CircleCI Project Settings using the CircleCI UI, and put it on the machines that CircleCI will deploy to using Prancible.

1. Create ssh key pair
Go into your Princeton Ansible directory and set up your environment as usual
```bash
ssh-keygen -t ed25519
> Generating public/private ed25519 key pair.
> Enter file in which to save the key (/Users/your_user/.ssh/id_ed25519):
./keys/circleci/app-name-environment
> Enter passphrase for "./keys/circleci/app-name-environment" (empty for no passphrase):
[use empty passphrase - just hit return]
> Enter same passphrase again:
[hit return]
```

2. Add private ssh key to CircleCI
Go to [list of Princeton University Library projects on CircleCI](https://app.circleci.com/projects/project-dashboard/github/pulibrary). Find your project and click the triple-dots on the right side of the page and got to Project Settings, then click on SSH Keys. Scroll down to "Additional SSH Keys" and click "Add SSH Key". Copy the private key you generated into the pop-up and put in the appropriate hostname. Once you have saved it in CircleCI, *delete the private key from Princeton Ansible*. 

3. Add the public ssh key to the servers
In the group vars for the project, in the appropriate environment, add the `deploy_user_local_keys` variable, pointing to the public key that you generated in step 1. ([example PR for adding the local key to Princeton Ansible](https://github.com/pulibrary/princeton_ansible/commit/43610d45fd2aea888fe185e26413a7e98015c6e9))
```yaml
# group_vars/allsearch_api/staging.yml
deploy_user_local_keys:
  - { name: 'allsearch-api-staging-circleci-key', key: "{{ lookup('file', '../keys/circleci/allsearch-api-staging.pub') }}" }
```

Run the application's playbook with the `update_keys` tag against the servers and environment you will be deploying to:
```bash
ansible-playbook playbooks/allsearch_api.yml --tags update_keys
```

4. Add the deployment to the CircleCI config
In the .circleci/config.yml file, add the deploy job in the `jobs` stanza ([example PR for adding the deployment config](https://github.com/pulibrary/allsearch_api/pull/365/files))

```yaml
jobs:
  staging_deploy:
    machine: true
    resource_class: pulibrary/ruby-deploy
    steps:
      - checkout
      - setup-bundler
      - ruby/install-deps
      - run: bundle exec cap staging deploy
```
And to the workflows:
```yaml
workflows:
  build_and_test:
      - staging_deploy:
          requires:
            - test
          filters:
           branches:
             only:
               - main
```


## Troubleshooting nomad

To troubleshoot the container in nomad that runs this:

1. cd into the `nomad` directory of princeton_ansible
1. `bin/login`
1. Your browser will open with a list of jobs
1. Select the circleci-runner job
1. Find a recent allocation and click on its id
1. Press the Exec button to open a terminal
1. Press enter to accept the default shell
1. Run any commands that will help you with your troubleshooting
