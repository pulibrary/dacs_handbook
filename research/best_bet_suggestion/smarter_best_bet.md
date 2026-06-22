# Semantic search

## Abstract

We have a Best Bet feature in the AllSearch application, but it is currently just querying a database for a pre-defined match. This work seeks to give the user a suggestion to assist with starting the discovery process. The proposed work collects the results from each search service and sends the data to an AI ReRanker model, which uses the query to compare all results for the best match.

## keywords: rerank, BAAI, discovery, text-embreddings

## Methodology

I was initially able to achieve a working demo using Ollama to manage the model, but Ollama does not natively support the rerank API. I was able to use a shim to emulate the API using dengcao/Qwen3-Reranker-8B:Q5_K_M as a model, but the reranking was performed as a chat-like prompt behind the scenes. This required a large model (5.8gb) and had poor performance, taking as long as 30 seconds to return results utilizing my Mac's built-in GPU. This performance was not ideal so I sought out alternatives that could host the reranking API natively.

Using the Hugging Face Text Embeddings Interface, a CLI tool built in Rust, I was able to achieve acceptable results, using the much smaller (600mb) BAAI/bge-reranker-large model. Performance was greatly improved, resulting in approximately 1 second response time.

## Results

## Conclusions and next steps


## References


## Appendix

