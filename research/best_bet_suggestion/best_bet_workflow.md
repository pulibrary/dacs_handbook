```mermaid
sequenceDiagram
	participant DB as BEST BET DATABASE
	participant API as ALLSEARCH API
	participant UI as ALLSEARCH UI
	participant AI as RERANKING MODEL

	UI->>API: Query search services for results
	API->>UI: Return search results
	UI->>API: Query Best Bets Database
	API->>DB: Query Database for match
	DB->>API: Return match from database if present
	API->>UI: Return Best Bets database match if present
	UI->>AI: Send results to reranking API if no DB match
	AI->>UI: Return reranked search results
```
