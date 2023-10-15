# Practical GenAI

## Introduction

Practical GenAI will challenge you to build a system that is going to summarize scientific papers (in PDF format) when they're added to a Cloud Storage bucket, and will put the results in BQ for further analysis. We'll use a Cloud Function to orchestrate the whole process. The function will extract text from the document, create a summary from the extracted text, and store the summary in a database for you to view, search and further process.

## Learning Objectives

This hack will help you explore the following tasks:

- Using Vertex AI Foundational models for text understanding
- Prompt engineering 
- Using BigQuery to run LLMs

## Challenges

- Challenge 1: Automatic triggers
- Challenge 2: First steps into the LLM realm
- Challenge 3: Getting summaries from a document
- Challenge 4: BigQuery &#10084; LLMs

## Prerequisites

- Knowledge of Python
- Basic knowledge of GCP
- Access to a GCP environment

## Contributors

- Murat Eken

## Challenge 1: Automatic triggers

### Introduction 

This challenge is all about configuring the pre-requisites for the system we're building.

### Description

Create two Cloud Storage Buckets, one for uploading documents and another for staging. You can choose any name for the first bucket, but call the staging bucket `{YOUR PROJECT ID}-staging`.

We'll trigger the summary generation automatically when a new document is uploaded to the first Cloud Storage Bucket. We've already provided you with a(n incomplete) Cloud Function, make sure that this function is triggered whenever a new document is uploaded to that Cloud Storage Bucket.

### Success Criteria

- There are two Cloud Storage Buckets (names?)
- Provided Cloud Function is triggered when a new file is uploaded

### Learning Resources

- Cloud Storage Buckets
- Cloud Storage Notifications
- BQ Create dataset 

### Tips

- Check the Cloud Function to see how it's being triggered

## Challenge 2: First steps into the LLM realm

### Introduction

The first step in our process is to extract text data from PDF documents, we've already implemented that functionality for you using Cloud Vision APIs. Go ahead and have a look at the `extract_text_from_document` to understand where and how the results are stored. Cloud Function main.py...

### Description

For this challenge we'll use PaLM (`text-bison`) to determine what the title of the uploaded document is. We've already provided the skeleton of the function `extract_title_from_text`, all you need to do is come up with the correct prompt and update the `mappings` to pass the contents to your prompt.

### Success Criteria

- Running the Cloud Function on the following [paper](https://arxiv.org/pdf/2309.00102) generates the following title: _The LOFAR Two-Metre Sky Survey (LOTSS) VI. Optical identifications for the second data release*_

### Learning Resources

- Python string.Template

### Tips

- gsutil cat & jq Cloud Shell
- Generative AI Studio

## Challenge 3: Getting summaries from a document

### Introduction 

### Description

### Success Criteria

### Learning Resources

### Tips

## Challenge 4: BigQuery &#10084; LLMs

### Introduction 

### Description

### Success Criteria

### Learning Resources

### Tips
