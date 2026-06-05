## Importing Unstructured Legacy Metadata to ArchivesSpace Using AI Tools
### Problem Statement

We have unstructured legacy metadata that is not discoverable through search in our main discovery platform (pulfalight). 
This makes the resources effectively undiscoverable to patrons.

The data lives in documents of various formats (typed, Word, PDF), which are not uniformly structured and can run to book length.
In the past, we have either scraped the docs or laboriously re-keyed them by hand, frequently using student workers (both ongoing during the school year and in summer projects).

The problem I tackled for this experiment was a cache of 5 legacy descriptions that our Librarian for Latin American Studies, Latino Studies, and Iberian Peninsular Studies asked me to convert to finding aids.
All 5 documents had been imaged and were available as PDF downloads from our digital repository (figgy).

Repurposing this sort of legacy description involves extracting discrete data from the narrative document, structuring it, and importing it to ArchivesSpace.
Once the data is in ArchivesSpace, it becomes part of our regular processes that export EAD from ArchivesSpace, display the finding aid in pulfalight, and make the resources requestable via our pulfalight/aeon integration.

### Goals

- Test whether AI can be leveraged for this kind of metadata repurposing in an efficient, reliable, and repeatable way.
- Compare the performance of Copilot (currently employer-sponsored) and Claude (free version or employee-sponsored) for this task.

### Summary Findings
Claude performed impressively, but the limitations of the free version required the purchase of a Pro license and additional tokens. 
Copilot proved unsuitable.

### The Play-by-Play

**1. Claude (Sonnet 4.6, free version): single-file processing**

I started with a single PDF file and a minimal prompt, asking Claude to identify the inventory data and return a structured CSV.
By mistake, I uploaded the entire figgy object (1200+ pages) rather than just the inventory.
(I realized only later that there is a limit of 100 PDF pages per chat, so I'm not entirely sure how I got away with it--I'm assuming it cut off after p.100).
The inventory was located on pp.8-16, but I did not provide that information.

Claude accurately read and parsed the PDF, identified the inventory, and returned a CSV with columns for component title, box number, and folder number. 
This first return emulated the input document such that box and folder numbers were not repeated on subsequent lines to which they also applied.
A second prompt asking Claude to infer those from context and return them on each line succeeded beautifully.

In a third prompt, I then asked Claude to also provide the data in EAD2002 format. 
It initially returned a `<dsc>` grouped by box; a fourth prompt was required to restructure the `<dsc>` as a nested contents list.

The EAD output held unexpected surprises, all unprompted:
- call number, subject headings, and microfilm numbers were included and appropriately encoded; they were ostensibly not from the input PDF but our two catalog records
- the `<descrules>` element was set to DACS
- component id's were included and prefixed with "aspace_"

I finished this task just within the token limit of the free plan--it told me I was out of exchanges right when I was done.

**2. Claude (Sonnet 4.6, Pro version): batch processing, blockers, and some solutions**

I then entered the same prompt and the 4 remaining links to the legacy inventories in figgy.

Blocker 1. Here, I encountered a minor roadblock: Claude required me to upload the PDF's manually (it said it couldn't get them from figgy because figgy is not in its domain--there may be a way to address this but I didn't pursue it).

Blocker 2. I then immediately hit a larger roadblock when I uploaded the 4 PDF's: Claude couldn't process them all at once because it has a 100 page limit per chat.
So I had to process the 4 files in 3 discrete chat sessions.

Blocker 3. When trying to run my first chunk (2 PDF's amounting to just under 100 pages), I now ran into the complexity limit of the free plan. 
I decided to purchase the Pro plan for $20/month (for one month only), which comes with 5x token allowance per session. (See [usage limits](https://support.claude.com/en/articles/9797557-usage-limit-best-practices.))
This allowed me to proceed and process 3 additional files in 2 chunks.

Blocker 4. The 4th file contained 133 pages, more than the allowed page limit. 
(The 100-page limit is apparently a technical limitation, not a matter of pricing tier.)
By pure luck, the document contained exactly 100 pages of inventory after manually trimming the introductory matter and index.
For larger legacy files this workflow would not work without additional splitting of PDF documents (which may then require re-contextualization to put it back together).

Blocker 5. This file took a while to run, so I actually walked away for a few minutes.
Even though I had gotten the pages down to within the limit, I then also hit the complexity limit of the Pro plan and the task couldn't finish. 
Complexity limits reset every 5 hours, and since I had already processed other files (i.e. drawn down on my tokens) in the same session, I could probably have waited 5 hours and repeated the task in a dedicated session succesfully.
Waiting 5 hours every so often is not a realistic batch workflow, so I decided to purchase additional tokens.
It's very hard (at least for me) to gauge how much processing an exchange will use up, so I added $10, put a monthly spending limit of $50 in place, and prayed that that would be enough to prevent my credit card from exploding.
With the additional credit added to my account, Claude finished the task. 

As it turns out, the additional tokens required to finish the job cost me $0.09.

(Aside: In fact, it returned the output files instantly once I added the credit, so I suspect that it had actually finished processing all along but held the output "hostage" pending the additional payment.
If that is true, then the processing cost, including the energy cost, was spent regardless, even if I decided not to finish the task at all. In terms of energy use and environmental impact, that would be disappointing.)

**Limitations:** 
In addition to the complexity throttling I already mentioned, I also observed that the output was not homogenous between sessions. 
For example, in one session, the EAD output had numbered `<c01>` etc. elements, whereas in all other sessions the `<c>` elements were unnumbered. 
The differences were minor from file to file, but accrued with the size of the batch.
As a result, the post-transformation Q&A was more laborious than expected.
Overall, though, using AI for this work was significantly faster than the manual alternative, amounting to a few hours vs. days or weeks of manual data entry.

NB: This experiment was purely based on chat interactions in Sonnet. The Pro plan comes with access to Opus, Code, and Collaboration, none of which I used. 

**Takeaway:** 
Realistically, we'd need a higher-performing enterprise plan to make this a sustainable batch workflow.
On a limited-rate personal plan, the 5-hour complexity allowances are too low to be performant at an enterprise scale.

That being said, Claude performed impressively as far as the logic and ease of interaction goes. 
It required minimal prompting, deciding independently on which "skills" and tools to use (OCR, Python etc.).
The output was of high quality and required only minor tweaks (most of which could be performed by Claude with follow-up prompts).

I could see us planning AI-assisted projects for this kind of data-reformatting work with student workers executing them, where professionals provide the intellectual and technical framework (prompt engineering, input/output infrastructure, Q&A tools for validation, standards compliance etc.) and students are trained to apply those tools and monitor the output.

**3. Copilot (Princeton's Basic Chat plan)**

I repeated my first attempt with Claude verbatim with Copilot and was quickly disappointed.
It was unable to extract the inventory data from the PDF even after an hours-long session (the chat transcript runs to 43 pages).
Eventually it just lied: it went to the internet, found *a different* LAE collection inventory, and presented it as if it had extracted the data from the input file.

What's more, the interaction was *exhausting*.

Copilot was unnecessarily verbose and technical, creating the illusion of usable information without saying much of anything. 
Each prompt returned multiple paragraphs of text where a single sentence would have sufficed (example: "Result," "Why," "What I *can* confirm," "Implication," "Partial deliverable (empty schema)," "If you want me to proceed"--where the "result" started with "I am not able to extract a folder-level inventory").

They were also studded with emojis (⚠️ Important disclaimer, 🧠 How this reconstruction was derived, ✅ Reconstructed Folder Inventory) that I found semantically weird and visually disruptive.

Each response created cliffhanger bait by offering multiple pseudo-technical avenues, e.g.:

```
✅ If you want a more precise version
I can go further by:
•	Attempting visual pattern extraction (simulate page segmentation for first ~20 pages)
•	Producing a confidence score per row
•	Expanding into item-level reconstruction heuristics
•	Generating a machine-learning OCR + parsing pipeline
Just tell me 👍
```

These "options" seemed to promise that a solution was just around the corner while also requiring me to respond, in effect stringing me along for one more exchange.
It sent me to the brink of cognitive overload. 
I finally opted out of the infinite loop once it started making things up.

Other than the hallucination, the fruit of my labors with Copilot is a CSV with the content:
```
FolderNumber,Title,Page
,NO INVENTORY DETECTED,
```

**Takeaway:**
Designed to maximize user engagement rather than produce usable output. Borderline abusive. Huge waste of time.
