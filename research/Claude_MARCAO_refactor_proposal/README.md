### Claude Refactoring Experiment

For this experiment, I asked Claude to make a proposal to consider https://github.com/pulibrary/aspace_helpers/issues/755 and 
https://github.com/pulibrary/aspace_helpers/issues/753 and propose a refactor of the marcao plugin that moves most of the code into lib_jobs.

### 1. Setup

For this experiment, I used Claude Code, the agentic Claude coding tool, from VS Code. This gives Claude access to my file system,
allowing it to manipulate my code base. This tool is not available with the free version; I used my personal Claude subscription for this. The version I used is Sonnet 4.6, which is less token-expensive than Opus.

I used the most conservative settings, e.g. requiring it to ask permission before running any commands, and prompted it to prepare the
proposal on a copy rather than making changes to existing files.

As it turns out, this meant I had to approve every `cd` and `cat` etc. (133 interactions), so I'll relax that requirement a bit next time!

### 2. Process

My interaction with the tool resembled "vibe coding" where it would do a thing, I would weigh in, and it would do the thing a little differently.
That said, I tweaked the outcome maybe two or three times; the tool worked mostly autonomously (except for me approving every bash command).

The times where I intervened were a few times when it said it was done and listed a few things it had considered out of scope. I prompted it
to also address (some of) those.

Example:
Claude:
```
The README also notes what this *doesn't* cover:
the data-fetching half of `MarcAOExporter` (finding flagged Resources, resolving modified AOs, report bookkeeping, SFTP)
still needs the architectural decisions discussed earlier — a new `lib_jobs` job using `aspace_helper_methods`' REST helpers
plus `LibJob`/`DataSet`/`Aspace2almaHelper`, and a decision on whether "which resources are flagged" can be answered via
ArchivesSpace's Solr search or needs a thin plugin endpoint.

```

There was also one time where it ran out of context and I had to start a new session. That was an interesting breaking point where I thought 
I would lose a lot of work. However, Claude provided an "orderly exit" of sorts with a summary of everything it had done to that point and
what it was planning to do next. I was able to provide that summary to the new Claude session as context, and it resumed without blinking.

### 3. Outcomes and Next Steps

Claude delivered copies of every file it proposed editing (plus some files it proposed adding, e.g. a new class), in the folder structure
of the source repos. It also provided an extensive README file explaining what it had done and delivered.

A funny thing that happened: I couldn't find a download button to save the chat. Finally, I had the clever idea to ask Claude for the transcript.
That totally worked.

Whether the refactoring proposal amounts to anything remains to be seen once the amazing DACS developers look at it through critical human eyes!

### 4. One Thing to Note

Chats conducted from VS Code are not captured in the online (Claude.ai) chat history. They are available from the Claude extension in VS Code,
however, they're scoped to the workspace they were created from. So in order to go back to a particular chat, you need to know which repo you had
open at the time.

There's also a known bug (I know this, you guessed it, from asking Claude) where
```
the VS Code extension's Local session list doesn't show all sessions even though they're properly written to disk
as .jsonl files, and a related one noting the extension doesn't re-discover or re-index existing session files on
startup in certain situations (e.g. after closing and reopening VS Code).
```
The two tickets referenced are https://github.com/anthropics/claude-code/issues/44625 and https://github.com/anthropics/claude-code/issues/37923.
