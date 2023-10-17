# Introduction to GenAI

## Introduction

Introduction to GenAI will challenge you to build a system that summarizes scientific papers (in PDF format) when they're added to a Cloud Storage bucket, and will put the results in BQ for further analysis. We'll use a Cloud Function to orchestrate the whole process. The function will extract text from the document, determine the document's title, create a summary from the extracted text, and store the summary in a database for you to view, search and further process, all of this using Large Language Models (LLMs).

![Architecture of the system](./images/genai-intro-arch.png)

## Learning Objectives

This hack will help you explore the following tasks:

- Using Vertex AI Foundational models for text understanding
- Prompt engineering 
- Using BigQuery to run LLMs

## Challenges

- Challenge 1: Automatic triggers
- Challenge 2: First steps into the LLM realm
- Challenge 3: Summarizing a large document using chaining
- Challenge 4: BigQuery &#10084; LLMs

## Prerequisites

- Basic knowledge of GCP
- Basic knowledge of Python
- Access to a GCP environment

## Contributors

- Murat Eken

## Challenge 1: Automatic triggers

### Introduction 

This challenge is all about configuring the pre-requisites for the system we're building.

### Description

Create two Cloud Storage Buckets, one for uploading documents and another one for staging. You can choose any name for the first bucket, but call the staging bucket `{YOUR PROJECT ID}-staging`.

We'll trigger the summary generation automatically when a document is uploaded to the first Cloud Storage Bucket. We've already provided you with a(n incomplete) Cloud Function, make sure that this function is triggered whenever a new document is uploaded to the Cloud Storage Bucket.

### Success Criteria

- There are two Cloud Storage Buckets, one for uploading the documents and another one for staging with the required name.
- The provided Cloud Function is triggered (only) when a file is uploaded.
- No code was modified.

### Learning Resources

- [Creating new Cloud Storage Buckets](https://cloud.google.com/storage/docs/creating-buckets)
- [Pub/Sub notifications for Cloud Storage Notifications](https://cloud.google.com/storage/docs/pubsub-notifications)

### Tips

- Check the provided Cloud Function configuration to see the details on how it's being triggered

## Challenge 2: First steps into the LLM realm

### Introduction

Let's get started with a simple objective; we're going to _extract_ the title of a document using LLMs. In order to work with LLMs we need textual data, so the first step in our process is to extract text data from PDF documents. We've already implemented that functionality for you using Cloud Vision APIs in the provided Cloud Function. Go ahead and have a look at the `extract_text_from_document` function to understand where and how the results are stored. Now, with those results we can look into extracting the title from the text content of the document.

### Description

For this challenge we'll use PaLM (`text-bison`) to determine what the title (including any subtitle) of the uploaded document is. We've already provided the skeleton of the function `extract_title_from_text`, all you need to do is come up with the correct prompt and update the `mapping` to pass the document content to your prompt. Once you've made your changes re-deploy the Cloud Function.

### Success Criteria

- The following papers should yield the corresponding titles, you can see those in the `Logs` section of the Cloud Function:

  | Paper                                           | Title |
  | ---                                             | ---   |
  | [LOFAR paper](https://arxiv.org/pdf/2309.00102) | _The LOFAR Two-Metre Sky Survey (LOTSS) VI. Optical identifications for the second data release_|
  | [PEARL paper](https://arxiv.org/pdf/2309.00031) | _PEARLS: Near Infrared Photometry in the JWST North Ecliptic Pole Time Domain Field_ |

### Learning Resources

- Using Python [str.format](https://docs.python.org/3/library/stdtypes.html#str.format)
- [Prompt Engineering](https://cloud.google.com/vertex-ai/docs/generative-ai/text/text-prompts)

### Tips

- You can test your prompts using [Generative AI Studio](https://cloud.google.com/vertex-ai/docs/generative-ai/text/test-text-prompts#generative-ai-test-text-prompt-console)
- You could get the content from PDF files either by copy-paste or using `gsutil cat` & `jq` commands from Cloud Shell by accessing the JSON files in the staging bucket

## Challenge 3: Summarizing a large document using chaining

### Introduction

The objective of this challenge is to try to get a summary of a complete paper. You've already seen that there are limitations when it comes to the number of input tokens for an LLM. For the title it's okay to just look at a part of the document, but generating a summary for the complete document requires an alternative approach, namely LLM _chains_. 

With LLMs there's roughly 3 different approaches; _Stuffing_ is the most basic approach where the full content (possibly from multiple documents) is provided as the context. However this only works with smaller documents due to the context length limits.

The _Map-Reduce_ chain is an alternative approach that's designed to handle large/multiple documents. In essence it makes multiple calls to an LLM for chunks of content (usually in parallel). It first applies an LLM to each document/chunk individually (the _Map_ phase), then the results (outputs of the LLM) are combined and sent to an LLM again to get a single output (the _Reduce_ phase). Typically different prompts are used for the Map and Reduce phases. 

The _Refine_ chain approach also makes multiple calls to an LLM, but it does that in an iterative fashion. It starts with the first document/chunk, passes its content and gets a response, and then gets to the second document/chunk passing that content plus the response from the previous call, iterating until the last document/chunk and then passing the last (rolling) response and getting a final answer using a different (final) prompt.

### Description

In order to get the summaries, we'll implement the _Refine_ approach for this challenge. Most of the code is already provided in the `extract_summary_from_text` method in Cloud Function. Similar to the previous challenge, you're expected to design the prompts and provide the right mapping.

### Success Criteria

- For this [paper](https://arxiv.org/pdf/2310.01473) we expect a summary like this:

  ```
  The author argues that the standard cosmological model is incorrect and that there is no dark matter. The author provides several arguments for this, including:

  * The observed properties of galaxies are consistent with them being self-regulated, largely isolated structures that sometimes interact.
  * The observed uniformity of the galaxy population is evidence against the standard cosmological model.
  * The large observed ratio of star-forming galaxies over elliptical galaxies is evidence against the standard cosmological model.

  The author concludes that understanding galaxies purely as baryonic, self-gravitating systems becomes simple and predictive.
  ```
  > **Note** By their nature, LLM results can vary, this is something to expect so your exact text may not match the above, but the intent should be the same.

## Challenge 4: BigQuery &#10084; LLMs

### Introduction

So far we've used the PaLM APIs from the Vertex AI Python SDK. It's also possible to use those through BigQuery, this challenge is all about using BigQuery to run an LLM.

### Description

Before we start using the LLMs you'll need to store the outputs of the Cloud Function in BigQuery. The first step is to create a BigQuery dataset called `articles` (in multi-region US) and a table `summaries` with the following columns, `uri`, `name`, `title` and `summary`.

We've already provided the code in the Cloud Function to store the results in the newly created table, just uncomment the call to `store_results_in_bq`.

Once the table is there, configure BigQuery to use an LLM and run a query that categorizes each paper that's in the `articles.summaries` table using their `summary`. Make sure that the LLM generates one of the following categories: `Astrophysics`, `Mathematics`, `Computer Science`, `Economics` and `Quantitative Biology`. 

Upload the following papers to Cloud Storage Bucket and run your SQL query in BigQuery to show the title and category of each paper
- [Astrophysics 1](https://arxiv.org/pdf/2310.00044)
- [Astrophysics 2](https://arxiv.org/pdf/2310.01062)
- [Computer Science 1](https://arxiv.org/pdf/2310.08243)
- [Computer Science 2](https://arxiv.org/pdf/2310.09196)
- [Economics 1](https://arxiv.org/pdf/2310.00446)
- [Economics 2](https://arxiv.org/pdf/2310.02081)
- [Mathematics 1](https://arxiv.org/pdf/2310.00245)
- [Mathematics 2](https://arxiv.org/pdf/2310.01303)
- [Quantitative Biology 1](https://arxiv.org/pdf/2310.00067)
- [Quantitative Biology 2](https://arxiv.org/pdf/2310.02553)

> **Warning**  
> Currently PaLM has a rate limit of 60 calls per minute, since every page from the documents is a single call, if you process more than 60 pages you might run into this limit. None of the provided examples has more than 60 pages, but if you add them all at the same time you'll get to that limit.

### Success Criteria

- Running the SQL query yields the following results

  | Title | Category |
  | ---   | ---      |
  | From particles to orbits: precise dark matter density profiles using dynamical information | Astrophysics |
  | Bayesian inference methodology to characterize the dust emissivity at far-infrared and submillimeter frequencies | Astrophysics |
  | Computing Twin-Width Parameterized by the Feedback Edge Number | Computer Science |
  | A 4-approximation algorithm for min max correlation clustering | Computer Science |
  | Reconstructing supply networks | Economics |
  | Student debt and behavioral bias: a trillion dollar problem | Economics |
  | Singularities and clusters | Mathematics |
  | Dynamics of automorphism groups of projective surfaces: classification, examples and outlook | Mathematics |
  | Solvent constraints for biopolymer folding and evolution in extraterrestrial environments | Quantitative Biology |
  | Full-Atom Protein Pocket Design via Iterative Refinement | Quantitative Biology |

### Learning Resources

- Creating BigQuery [datasets](https://cloud.google.com/bigquery/docs/datasets) and [tables](https://cloud.google.com/bigquery/docs/tables)
- BigQuery [LLM support](https://cloud.google.com/bigquery/docs/generate-text-tutorial)

### Tips

- You could download and upload the papers manually, but you can also consider  using `wget` and `gsutil` from Cloud Shell.
