---
layout: default
title: Board
---
# Board

Our team tracks our work on our [Zenhub board](https://app.zenhub.com/workspaces/feature-work-cycle-board-571691cab409d8d821b873be/board).

Here are descriptions of some of the columns on the board:

| Column | Meaning  |
|---|---|
| New Issues | Items that have not yet been triaged |
| Icebox | Items that are not currently a high priority and are not actively being considered for a future work cycle |
| Backlog | Items that are designated for a future work cycle but are not an immediate priority |  
| UI/UX | UI items that aren't part of typical work cycles |
| Next Work Cycle | Priority items that are to be included in the upcoming work cycle |
| Ready  | Items that are of a high priority and are ready to be worked on  |
| Stakeholder Review | Items that are blocked awaiting from feedback from colleagues who are not on the DACS team | 
| Review/QA | Issues typically attached to a pull requests that need review or other input from DACS team members before they can be closed |



## Story points

When using Epic tickets do not actually assign points to the ticket itself, Epics are the sum of the points of their assigned individual tickets. 

| Number of points | Meaning |
|---|---|
|1 point|A small amount of time|
|2 points|1/2 day|
|3 points|1 day|
|5 points|2-3 days|
|8 points|1 week|
|13 points|Needs to be broken down into smaller tickets|

## The Board Manager Role
Every sprint a different team member rotates to the role of "board manager". This individual shares the board with the team during stand-ups and planning meetings and leads us through a discussion of the board. The board manager role should be assumed by a Team member who plans to be in the office for entire sprint. The board manager also executes a deployment of all our applications to staging and production during the course of their week as the board manager.

### Deployments as the Board Manager

The runner executes a production and staging deploy of each of our DACS applications. 

1. Go to [Ansible Tower](https://ansible-tower.princeton.edu/).
2. Execute a [Deployment with Capistrano](https://ansible-tower.princeton.edu/#/templates/job_template/13/details) for each [DACS application](https://docs.google.com/spreadsheets/d/1fJZ6CE4yq4EyaoeOE__bjEYPUv5xlZVM0bPKfyVAUQw/edit#gid=0) for those applications that have a staging and production environment.  
