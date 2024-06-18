---
layout: default
title: Runner role
---
# Runner role

The runner role switches off between team members each week.  The runner should be somebody who is planning to be in for the whole week. 

## Initial setup

Before serving as a runner, do the following steps to get set up:

1. Make sure that honeybadger email notifications are turned on for the DACS team projects.  It can be helpful to [turn off honeybadger user notifications for projects we don't support](https://app.honeybadger.io/users/edit#notifications). Manage how often you will receive emails [digest email settings](https://app.honeybadger.io/users/edit#digest).
1. In the honeybadger UI, open a project and search for `created.after:"7 days ago" -is:resolved -is:ignored`.
1. Click the bookmark icon to bookmark this search.

## Triaging new honeybadger errors

Go to the honeybadger dashboard daily and look at honeybadger activity for DACS applications.  You can quickly review activity using the bookmarked search.  There is typically no need to review honeybadger activity from previous weeks.

Also triage any new honeybadger errors that come in via email.

Note: for some of the projects, the staging and qa environments are included in honeybadger.

### General categories of errors

#### Errors that need immediate attention

Notify the rest of the team on slack.

#### Small disruptions in database or solr connectivity

This category includes temporary disconnections from postgres (which might display as `ActiveRecord`) or solr (which might display as `RSolr`).  As long as these seem temporary and small in impact, it's generally okay to resolve these.

#### Errors caused by developers

This category includes:

* `SIGHUP` exceptions (from closing your console in certain ways while SSHed into a box)
* mistyped rake commands

It's fine to resolve or ignore these.


#### Potential attack probes

* If the attack probe illustrates a potential vulnerability, create a ticket (if it needs to be private, use the security repo)
* If it is just a naive, run-of-the-mill attack probe, make a ticket in [princeton_ansible](https://github.com/pulibrary/princeton_ansible) so that they can incorporate it into the WAF.

#### All other errors

Don't use the "Create Issue" button in honeybadger, since the history can be purged in honeybadger and we can miss important context.  Instead, follow these steps:

* Create an issue in the github repo.
* Add the honeybadger link in the issue's description
* Copy over the failing code block from honeybadger into the issue, not just the line numbers (since they can change)
* In honeybadger, add a comment with the link to the github issue
* As you troubleshoot, add any updates as a github comment

## Triaging new lib-answers tickets from the Catalog feedback and Website support.

* Login to lib answers using CAS https://princeton.libapps.com/libapps/login.php
* Select the Catalog feedback or the Website support queue. 
* Triage the unassigned tickets.
* Filter tickets with status: 'new' or 'open'.
* Transfer the ticket if needed:
  * If the ticket is a cataloging issue then tranfer it to the Cataloging queue.
  * If the ticket is an Electronic Resource issue then transfer it to the ESupport queue.
  * If the ticket has general reference questions then transfer it to the EReference queue.
  * If the ticket is a circulation/missing book question then transfer it to the EReference queue (circulation does not have its own queue).
  * If the ticket is a request for the library to purchase some material, transfer it to the EReference queue.
  * If the ticket is a request to reset an aeon password, transfer it to the Special Collections queue.
  * If the ticket doesn't fit into one of the categories above, transfer it to the EReference queue for future triage.
* If the ticket is spam, press the circle with a line through it.  Then, go to the Spam tab and delete the ticket (without this second step, libanswers sometimes will move spam messages back into the main queue).
* If the ticket is a coding issue then create a github ticket. Please include the lib answers ticket number in the github ticket.

### Blocking libanswers spam addresses

If you are a libanswers admin, you may follow this procedure to block an email address in libanswers:

1. Go to https://faq.library.princeton.edu/admin/sysset/access
2. Scroll down to "Block List for Email, SMS, and LibChat"
3. Press the "Add Entry to Blocking List" button.
4. Add the email address in the "Address/Number" field.
5. Press the "Add Block" button.

If you are not a libanswers admin, Vickie can block the email address for you.
