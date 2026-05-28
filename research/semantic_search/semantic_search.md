# Semantic search

## Abstract

In our Library catalog we use Solr with keyword search as our primary search engine to index approximately 22 million bibliographic records using MARC fields. In this project we explore the integration of semantic search to enhance user experience and deliver more relevant results. Semantic search allows the search engine to comprehend the meaning behind user queries and search objects, similar to humans. This approach not only improves text-based searches but also extends to various media types, including images, videos, and audio data, as long as their meanings can be represented as vectors. By implementing semantic search, we aim to create more effective and satisfying search experiences for our users.
   

## keywords: BERT, Lucene Solr, sklearn, transformers, torch, python, semantic search, marcXML

## Introduction

## Methodology
Text embeddings were implemented in Python utilizing the Sentence Transformers library with the pretrained model `multi-qa-mpnet-base-cos-v1`. This model was selected from the available [semantic search models](https://sbert.net/docs/sentence_transformer/pretrained_models.html#semantic-similarity-models) based on its support for 15 languages (Arabic, Chinese, Dutch, English, French, German, Italian, Korean, Polish, Portuguese, Russian, Spanish, and Turkish), compact model size, and default output dimensionality of 768 dimensions. The model was deployed locally to generate embeddings using a [nearest neigbor text embeddings](https://github.com/pulibrary/dedup-text-embeddings/pull/1/changes) for similarity computation.

The Solr schema was extended with a [denseVector](https://solr.apache.org/guide/solr/latest/query-guide/dense-vector-search.html) field to enable k-nearest neighbor (kNN) index-based retrieval. A new request handler, /semantic, was configured with deftype='lucene' to facilitate semantic search queries against the dense vector index. 

The catalog application was modified to support the new `/semantic` Solr handler and to accept semantic search query parameters, enabling end-to-end semantic search functionality across the system.
## Results

## Conclusions and next steps


## References
1. [BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding](https://aclanthology.org/N19-1423/) (Devlin et al., NAACL 2019)
2. Code: [google search/bert](https://github.com/google-research/bert)
3. [Text embeddings using BERT](https://medium.com/@davidlfliang/intro-getting-started-with-text-embeddings-using-bert-9f8c3b98dee6)
4. [Dense vector search](https://solr.apache.org/guide/solr/latest/query-guide/dense-vector-search.html)
5. [Solr.pl](https://solr.pl/en/2024/11/18/apache-solr-embeddings-how-to-start/)


## Appendix

