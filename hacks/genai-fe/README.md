# Formula E: Accident analysis

## Introduction

Given the close proximity racing, varying track conditions, and high speeds of electric cars, incidents in Formula E are virtually inevitable. The series' aggressive, unpredictable nature combined with street circuits often leads to crashes and collisions.

In this gHack we'll analyze multimodal data to detect accidents and try to do a root cause analysis, comparing driving lines and telemetry with ideal driving lines.

We'll start with using a RAG like approach to detect accidents from video footage. Once we have found the accidents we'll correlate that with telemetry data for the involved drivers and compare that with the ideal data to find out any discrepancies. Then we'll build an agent that brings all that information in a summary.

## Learning Objectives

During the process we'll learn about

- BigQuery Object tables
- Multimodal embeddings & Vector search in BigQuery
- Retrieval Augmented Generation (RAG)
- BigQuery for analyzing tabular data

## Challenges

- Challenge 1: Loading the data
- Challenge 2: Generating multimodal embeddings
- Challenge 3: Semantic search
- Challenge 4: Basic RAG

## Prerequisites

- Basic knowledge of GCP
- Basic knowledge of Python
- Basic knowledge of SQL
- Access to a GCP environment

## Contributors

- Murat Eken
- Michelle Liu
- Deb Lee
- Gino Filicetti

## Challenge 1: Loading the data

### Introduction

Formula E races are extensively covered with a network of broadcast cameras capturing the on-track action and drama, supplemented by CCTV cameras providing additional views for safety and race control. In this gHack we'll use CCTV footage to detect any incidents.

> **Note**  
> A circuit will have multiple CCTV cameras covering different parts of the track, for the sake of simplicity we'll use the feed from a single camera.

This first step is all about getting started with the source data, which is a collection of 2-minute segments from a CCTV camera.

### Description

Create a new bucket, and copy the sample videos from `TBD` to the newly created bucket.

> **Note**  
> You should navigate to your Cloud Storage bucket and preview the videos to familiarize yourself with the content.

Once the data is in the bucket, create an *Object table* in BigQuery on that data in a new BigQuery dataset.

### Success Criteria

- There is a new Cloud Storage Bucket with the sample video files.
- There is an Object table that makes the sample video files available in BigQuery.

### Learning Resources

- [Creating new Cloud Storage Buckets](https://cloud.google.com/storage/docs/creating-buckets)
- [Object tables in BigQuery](https://cloud.google.com/bigquery/docs/object-tables)

## Challenge 2: Generating multimodal embeddings

### Introduction

Embeddings are high-dimensional numerical vectors representing entities like text, video or audio for machine learning models to encode semantics. These vectors help us to measure distances and find *semantically* similar items. If we want to be able to search within our videos, to find the most relevant one for a given question, we need to generate embeddings as a first step.

### Description

Now the source data is available in BigQuery, use BigQuery ML capabilities to generate multimodal embeddings and store those embeddings in a new BigQuery table. Make sure that there's *only one* embedding vector *per 2 minute segment*.

### Success Criteria

- There is a new BigQuery table with 26 rows of multimodal embeddings for the sample video files.

### Learning Resources

- [Generate multimodal embeddings](https://cloud.google.com/bigquery/docs/generate-multimodal-embeddings)

### Tips

- The method for creating multimodal embeddings supports a few different arguments, pay attention to `flatten_json_output` and `interval_seconds`.

## Challenge 3: Semantic search

### Introduction

In order to find semantically similar items we need to measure the distance between vectors in the embedding space. We could implement that ourselves by calculating the distance between each embedding, but BigQuery already provides a function, `VECTOR_SEARCH`, that simplifies this process.

### Description

Design a SQL query that retrieves the **top result** from the embeddings table given the phrase `car crash`.

### Success Criteria

- The SQL query returns the uri for `cam_15_07.mp4`.

### Learning Resources

- [Generate and search multimodal embeddings](https://cloud.google.com/bigquery/docs/generate-multimodal-embeddings)
- [Deploying Cloud Functions from the Console](https://cloud.google.com/functions/docs/deploy#from-inline-editor)

## Challenge 4: Basic RAG

### Introduction

Retrieval augmented generation (RAG) is a popular approach for enabling LLMs to access external data and provides a mechanism to mitigate against hallucinations. The main idea is to provide the LLM more context to get reliable answers. This is typically done by looking up relevant information from a (vector) database and adding that information to the prompt of the LLM.

In the previous challenge we've done the lookup from a vector database, we're now going to use that in our prompt to get the exact timestamp for the crash.

### Description

Use Vertex AI Studio to get the exact timestamp of the crash from the video segment that was found in the previous challenge.

### Success Criteria

- Vertex AI Studio outputs the exact timestamp for the crash covered in the video segment.

### Learning Resources

- [What is RAG?](https://cloud.google.com/use-cases/retrieval-augmented-generation)
- [Using multimodal prompts in Gemini](https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/video-understanding)

### Tips

- Note that the CCTV footage contains the timestamp information in `dd/mm/yyyy * HH:MM:SS` format on the top left corner of each frame.
