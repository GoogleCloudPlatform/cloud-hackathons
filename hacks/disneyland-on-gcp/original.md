# Hackathon Challenge Lab

## 🏰 Disneyland Data Analytics Hackathon (2nd Edition - 3rd Dec) 🏰

| <strong>Summary</strong> | In this Hackathon, you will build an end-to-end data analytics pipeline leveraging AI/ML capabilities on Google Cloud. You&#39;ll load data into <strong>AlloyDB</strong>, a fully-managed, PostgreSQL-compatible database optimized for demanding workloads, then use <strong>Datastream</strong>, a serverless change data capture (CDC) service, to move it to <strong>BigQuery</strong>, Google Cloud&#39;s serverless data warehouse. In BigQuery, you&#39;ll apply <strong>BigQuery ML</strong>, which allows you to create and execute machine learning models directly in BigQuery using standard SQL, for review analysis and attendance forecasting. Finally, you&#39;ll play around with agents, either out of the box through <strong>Conversational Analytics</strong> &amp; Data Agents or create a custom agent, powered by <strong>Agent Development Kit</strong> and  <strong>MCP toolbox</strong> for natural language interaction with your data. |
| --- | --- |
| <strong>categories</strong> | docType:Codelab, product:Bigquery |
| <strong>Author</strong> | Rayhane Rezgui, Matt Cornillon |
| <strong>Layout</strong> | scrolling |
| <strong>Robots</strong> | noindex |

## Introduction

Welcome, future Disney data wizards!🪄

Forget tedious travel guides and endless forum scrolling. Imagine planning the perfect Disneyland trip, equipped with data-driven insights. Which park offers the best experience? When are the crowds thinnest? Can you predict the best time to conquer that notoriously long queue?

In this Hackathon, you're building your ultimate Disneyland planning tool. We've got the data: reviews from visitors across global branches, historical waiting times, and attendance figures. Your mission? Transform this raw data into actionable insights:

* **Gather Data:** Load diverse Disneyland reviews, waiting times, and attendance figures into AlloyDB, our high-performance, PostgreSQL-compatible database.
* **Seamless Movement:** Use Datastream, our serverless change data capture service, to effortlessly move this dynamic information into BigQuery, Google Cloud's powerful serverless data warehouse.
* **Predict the Magic:** Unleash BigQuery ML to analyze review sentiment and forecast waiting times directly with SQL. Discover which branches consistently deliver smiles and the optimal time for your visit.
* **Talk to your data - literally!:** Use pre-built tools that allow you to get insights with a swipe of a wand.
* **Intelligent Interaction:** Crown your creation with an intelligent agent, powered by MCP toolbox for databases and ADK (Agent Development Kit). Ask, "What's the best attraction in DisneyLand Paris for space lovers, and what is the best time to join the queue?" and get instant, data-driven answers.

Get ready to unlock the secrets of the most magical places on Earth and build a data analytics pipeline that would make Mickey proud!

<img src="img/a5db692deef31d78.jpeg" alt="a5db692deef31d78.jpeg"  width="624.00" />

<img src="img/db26cb0beaf5a543.jpeg" alt="db26cb0beaf5a543.jpeg"  width="624.00" />

## Task 1: From Operational to Analytical; Analyze Disneyland reviews with Gemini

Duration: 90:00

For this initial stage, you will retrieve the data from your AlloyDB operational database and load it into BigQuery for subsequent data analysis.

You will also set up everything needed in AlloyDB for your future agent!

### Data loading in AlloyDB

First of all, let's import some data into our **AlloyDB for PostgreSQL** cluster !

We are gonna ingest 20k reviews for DisneyLand amusement parks and a list of attractions.

> aside positive
>
> **AlloyDB Postgres credentials:**
>
> * Database: postgres
> * Username: postgres
> * Password: buildwithgemini2025

The steps you need to take are as follows:

#### **Tables creation:**

* Create a table **disneyland_reviews** with 6 columns: review_id and rating as integer, year_month, reviewer_location, review_text, branch as text.
* Create a table **disneyland_attractions** with 4 columns: attraction_id as integer, branch, name and description as text.

#### **Using the tool of your choice, import data from the CSVs:**

* `gs://hackathon_data_disneyland_&lt;YOUR_PROJECT_3DIGITS&gt;/reviews.csv` for the reviews table
* `gs://hackathon_data_disneyland_&lt;YOUR_PROJECT_3DIGITS&gt;/attractions.csv` for the attractions table

> aside positive
>
> **Tips:** AlloyDB is 100% compatible with Postgres interfaces. Meaning you can use tools like psql to connect to the cluster.
>
> Or you can use the import API of AlloyDB using the UI or gcloud!

#### **To provide attractions recommendation, we need to create embeddings of attractions description:**

* Install the pgvector extension in AlloyDB
* Add a vector column called "embedding" to your table attraction
* Generate and populate the embedding of the descriptions using the native integration between AlloyDB and Vertex AI

> aside positive
>
> **Tips:** You might have to give Vertex AI privileges to the AlloyDB service account

> aside negative
>
> **Checkpoint**: To validate this task you will need to showcase:
>
> * A row count of your two tables
> * Show the SQL query you used to generate the embeddings
> * Perform a similarity search on attraction descriptions to identify the top 5 attractions similar to ‘Dark ride in space'

### From operational to analytical with Datastream

To stream our data from AlloyDB to BigQuery, we're gonna use Google Datastream. It's a powerful serveless solution that will listen to all changes in source tables (using Change Data Capture) and send them to BigQuery.

To be able to replicate changes from AlloyDB with Datastream, we need to create what is called a publication and replication slot on Postgres.

Execute the following queries on your AlloyDB cluster (you need to run them one at a time):

```
CREATE PUBLICATION pub_disney FOR TABLE disneyland_reviews, disneyland_attractions;

ALTER USER postgres WITH REPLICATION;

SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('slot_disney', 'pgoutput');
```

You'll use the publication and replication slot in your stream so remember the names!

And that's all, now we can create a stream!

The steps in Datastream you need to take are as follows:

* Create a source profile for your AlloyDB cluster (use the public IP address)
* Create a destination profile for BigQuery
* Create a stream from AlloyDB to BigQuery.

The data should be available in BigQuery in a few minutes.

> aside positive
>
> **Configure the dataset characteristics:**
>
> * Schema grouping: Single dataset for all schemas
> * Dataset: Create one with the name **disney** in the **Belgium**  (europe-west1) region
> * Stream write mode; Merge
> * Staleness limit: 0 seconds

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * A stream that copies data from AlloyDB to BQ
> * A BigQuery Table called disneyland_reviews of 42,656
> * A BigQuery Table called disneyland_attractions of 73 rows

### Data Discovery in BigQuery

Now that we have our data in BigQuery, let's make sure we know the new enhancements in the interface before getting into work!

We have 3 new functions that you can already see in the BigQuery exploration panel.

<img src="img/bcafae83cfd4f968.png" alt="bcafae83cfd4f968.png"  width="197.00" />

* **Overview:** contains information about BigQuery features, tours to get started on analysis amongst other possibilities.
* **Search:** perform semantic search on your data assets.
* **Agents:** Shhh! We'll save this for later 🤫

#### **Search your data semantically in BigQuery**

Go to the Search tab in BigQuery exploration panel, and play around with terms related to disney like "attractions" or "branch".

#### **Visualize your Data in BigQuery**

You can now visualize and manipulate your data in BigQuery. For this, you can run this query in a new query tab;

```
SELECT
  *
FROM
  [dataset_name].[table_name];
```

#### **Generate data insights on the reviews table**

In this task, you will enable data insights on the `disneyland_reviews` table within the `disney` dataset.

[Data insights](https://cloud.google.com/bigquery/docs/data-insights) is a tool for anyone who wants to explore their data and gain insights without writing complex SQL queries.

**This might take a few minutes.**

**Query the disneyland_reviews table without SQL**

The insights you generated in the previous section are now ready. In this task, you will use a prompt generated from these insights to query the `disneyland_reviews` table without using code.

Select an insight and run the query associated with it. For example, find the query that calculates the difference in the average rating between consecutive months for each branch. It would look like this:

```
WITH
 monthly_avg AS (
 SELECT
   branch,
   year_month,
   AVG(rating) AS avg_rating
 FROM
   [dataset_name].[table_name]
 WHERE
   year_month IS NOT NULL
 GROUP BY
   1,
   2 )
SELECT
 branch,
 year_month,
 avg_rating,
 avg_rating - LAG(avg_rating, 1, 0) OVER (PARTITION BY branch ORDER BY year_month) AS rating_difference
FROM
 monthly_avg
ORDER BY
 branch,
 year_month;
```

**Use BigQuery Knowledge engine to better understand the data**

First things first; let's start with looking at the **Insights** tab on a dataset level; this will give us an idea on the hidden relationships across tables in the disney dataset. Then,

* Generate a description of the dataset using Gemini and add it to the dataset details.
* Generate a description of the tables reviews and attractions; as well as all the individual columns in those tables, and save it.

> aside negative
>
> **Checkpoint**: To validate this sub-task you will need:
>
> * Gemini-generated descriptions added to the details of the dataset, tables and columns

#### **Perform a profile scan of your data**

The goal of this section is to clean and prepare your data. However, you're not very familiar with the distribution of the values of each column. You need to profile your data to know what kind of transformation steps you need to perform on your data.

Google Cloud's Dataplex Universal Catalog automates [profiling scans](https://cloud.google.com/dataplex/docs/data-profiling-overview) to deliver consistent data quality metrics. Key statistics identified include null counts, distinct values, data ranges, and value distributions. It's possible to activate a profile scan through the BigQuery Interface.

It can take a couple of minutes, so you can look at the next section while waiting.

Answer the following questions:

* What's the average rating of Disneyland?
* Where are reviewers located the most?
* Are all reviews unique?
* What's the percentage of missing data from the Year_Month column?

#### **Perform a quality scan of your data**

Dataplex Universal Catalog  [automatic data quality](https://cloud.google.com/dataplex/docs/auto-data-quality-overview) lets you define and measure the quality of the data in your BigQuery tables. You can automate the scanning of data, validate data against defined rules, and log alerts if your data doesn't meet quality requirements. You can manage data quality rules and deployments as code, improving the integrity of data production pipelines.

Based on the profile scan, define a quality scan (on no more than 10% of your data as sample size) that:

* Checks for null values for the column "**branch**"
* Performs a validity check for the "**rating**", as it can only be in the set of : 1,2,3,4,5
* Checks uniqueness of "**review_id**"

**Make sure the scan exports results to a BigQuery Table quality_scan_results.**

Think about all the potential transformations you need to apply to your data.

#### **Prepare your data using Gemini's Data Preparation**

Following the data quality and profiling scans you performed, it's time to clean the data before analyzing it.

[Data preparations](https://cloud.google.com/bigquery/docs/data-prep-get-suggestions) are  [BigQuery](https://cloud.google.com/bigquery/docs/query-overview#bigquery-studio) resources, which use Gemini in BigQuery to analyze your data and provide intelligent suggestions for cleaning, transforming, and enriching it. You can significantly reduce the time and effort required for manual data preparation tasks.

In this section, you'll use Data Preparation to perform these operations on your disneyland_reviews table:

* Filter out rows where the Branch column is either NULL or an empty string.
* Replace "missing" in Year_Month by Null.
* Replaces underscores with spaces in the branch column to improve readability
* Export to transformed table disneyland_reviews_cleaned

> aside negative
>
> **Checkpoint**: To validate this sub-task you will need:
>
> * A profile scan on disneyland_reviews table
> * A quality scan on disneyland_reviews table with the right SQL rules
> * A data preparation pipeline with 3 intermediate transformation steps
> * A table named cleaned_disneyland_reviews

### Analyze reviews with Gemini

> aside positive
>
> For simplicity reasons, continue on working with the original disneyland_reviews table rather than the cleaned one.

Now that you've cleaned your data, you can start analyzing it using BigQuery ML and Gemini models. You have two objectives:

* Extract categories from reviews
* Sentiment Analysis of disneyland_reviews

BigQuery ML lets you  [create and run machine learning (ML) models](https://cloud.google.com/bigquery/docs/e2e-journey) by using GoogleSQL queries. BigQuery ML models are stored in BigQuery datasets, similar to tables and views. BigQuery ML also lets you access  [Vertex AI models](https://cloud.google.com/bigquery/docs/generative-ai-overview) and  [Cloud AI APIs](https://cloud.google.com/bigquery/docs/ai-application-overview) to perform artificial intelligence (AI) tasks like text generation or machine translation. Gemini for Google Cloud also provides AI-powered assistance for BigQuery tasks.

You can choose to use  [ML.GENERATE_TEXT](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-generate-text) or  [AI.GENERATE](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-ai-generate) (preview) with Gemini pro or Flash models.

The following steps guide you through if you want to use ML.GENERATE_TEXT.

#### **Create the cloud resource connection and grant IAM role**

You need to create a Cloud resource connection in BigQuery to Vertex AI models, so you can work with Gemini Pro and Gemini Flash models. You will also grant the cloud resource connection's service account IAM permissions, through a role, to enable it access the Vertex AI services.

#### **Grant Vertex AI User role to the connection's service account**

Allow the connection's service account to use your chosen model (for example `gemini-2.5-flash`), by granting it the Vertex AI User role. It takes 1 minute for the permission to propagate.

#### **Create the Gemini models in BigQuery**

Create your model by using the connection above. Use for example the endpoint `gemini-2.5-flash.`

#### **Prompt Gemini to analyze customer reviews for categories and sentiment**

In this task, you will use the Gemini model to analyze each customer review for categories and sentiment, either positive or negative.

##### **Analyze the customer reviews for categories**

Note: From now on, for the analysis, **we'll only take 100 rows**, as Gemini call on 20k rows can take a while.

* `Extract categories by modifying and running the following SQL Query:`

```
CREATE OR REPLACE TABLE
[dataset_name].[results_table_name] AS (
SELECT Review_ID, Rating, Year_Month, Reviewer_Location, Review_Text, Branch, ml_generate_text_llm_result AS categories FROM
ML.GENERATE_TEXT(
MODEL [model_name],
(
   SELECT Review_ID, Rating, Year_Month, Reviewer_Location, Review_Text, Branch, CONCAT(
      '[WRITE YOUR PROMPT HERE].',
      Review_Text) AS prompt
   FROM (SELECT * FROM [dataset_name].[table_name] LIMIT 100)
),
STRUCT(
   0.2 AS temperature, TRUE AS flatten_json_output)));
```

This query takes customer reviews from the **`disneyland_reviews`** table, constructs prompts for the `gemini` model to identify categories within each review. The results should be stored in a new table **`reviews_categories`**

**.**
Please wait. The model takes approximately 30 seconds to process the customer review records and to have the results in the output table.

Display the results:

```
SELECT * FROM [dataset_name].[results_table_name];
```

Take some time to read some of the categories.

##### **Analyze the customer reviews for positive and negative sentiment**

Based on the SQL query for Keyword extraction, write a query that analyses review into Positive, Negative and Neutral under a column called "sentiment".

This query takes customer reviews from the **`disneyland_reviews`** table, constructs prompts for the `gemini` model to classify the sentiment of each review. The results are then stored in a new table **`reviews_analysis`**, so that you may use it later for further analysis.
Please wait. The model takes a few seconds to process the customer review records.
When the model is finished, the result is in the **`reviews_analysis`** table that is created.

Explore the results:

```
SELECT * FROM [...];
```

The **`reviews_analysis`** table has the `Sentiment` column containing the sentiment analysis, with the `social_media_source`, `review_text`, `customer_id`, `location_id` and `review_datetime` columns included.
Take a look at some of the records. You may notice some of the results for positive and negative may not be formatted correctly, with extraneous characters like periods, or extra space. You can sanitize the records by using the view below.

#### Create a view to sanitize the records

Create a view that sanitizes the values of the column sentiment by:

* Using LOWER to make sure all the values are lowercase.
* Removing punctuation (. and , and space) by using REPLACE

```
CREATE OR REPLACE VIEW [view_name] AS
SELECT [SANITIZATION_EXPRESSION] AS sentiment,
Review_ID, Rating, Year_Month, Reviewer_Location, Review_Text, Branch,
FROM `disney.reviews_analysis`;
```

The query creates the view **`cleaned_data_view`** and includes the sentiment results, the review text,  `Review_ID, Rating, Year_Month, Reviewer_Location, Review_Text and Branch`. It then takes the sentiment result (positive or negative) and ensures that all letters are made lower case, and extraneous characters like extra spaces or periods are removed. The resulting view will make it easier to do further analysis in later steps within this lab.

1. You can query the view with the query below, to see the rows created.

```
SELECT * FROM [view_name];
```

#### **Create a report of positive and negative review counts with Data Canvas**

Now, it's time to analyze your results. Let's start by doing directly in BigQuery, through Data Canvas. This is a tool that allows you to search data (semantically or keyword), query and join tables, create graphs and get insights by creating a flow of canvas.

Your final goal is to create a graph of your choice of the percentages of positive vs negative reviews . Here's an example:

<img src="img/c599269a77b3933c.png" alt="c599269a77b3933c.png"  width="382.50" />

#### **Create a graph of the number of reviews per category, as well as the distribution of positive and negative reviews for each category**

Tip: Activate and use Data Canvas's **Advanced Analysis**, which runs a Python Notebook inside a canvas.

> aside negative
>
> **Checkpoint**: To validate this sub-task you will need:
>
> * A model in europe-west1.
> * A table named reviews_categories with a column named categories
> * A table named reviews_analysis with a column Sentiment
> * A view cleaned_reviews_analysis with the right formatting expression
> * A data canvas with the right analysis

## Task 2: Analyze attraction parc images to identify Disneyland photos & extract fun facts from Park Brochures

Duration: 30:00

#### **Image Analysis in BigQuery**

You have access to some thrilling and appealing pictures of Attraction parc that visitors took along the years. You're so excited for your upcoming trip! However, you don't know which ones are actual photos of disneyland. You're tasked with identifying those. The pictures are located in **`gs://hackathon_data_disneyland_&lt;YOUR_PROJECT_3DIGITS&gt;/attraction_parc_photos/`**.

<img src="img/ed155804de3f13e7.png" alt="ed155804de3f13e7.png"  width="322.57" />

**Is_disneyland:** False

<img src="img/e201eb9a26faa4c.jpeg" alt="e201eb9a26faa4c.jpeg"  width="323.00" />

**Is_disneyland:** True

In order to rapidly perform this analysis. You should use BigQuery's object tables and Gemini through BigQuery ML (**ML.GENERATE_TEXT**).

> aside positive
>
> You might have to give the right roles to some service accounts (BQ, Vertex AI)

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * An object table referencing the images
> * A table images_analysis with Is_disneyland boolean column

Can you verify the output of Gemini by checking some photos?

#### **Create your own RAG system with BigQuery on Disneyland brochures**

While waiting in line, you want to get some fun facts/technical details about the attraction you're waiting for.

In **`gs://hackathon_data_disneyland_&lt;YOUR_PROJECT_3DIGITS&gt;/disneyland_brochures/,`** you'll find PDF files that contain brochures for all parks around the world.

**Goal:** Create a Retrieval-Augmented Generation (RAG) system entirely within BigQuery to allow users to ask complex questions about the park based on some PDF documents.

To achieve this, you need to:

* Create an object table of pdf files
* Create a Python UDF to chunk PDF files. Here's an example you can use:

```
CREATE OR REPLACE FUNCTION disney.chunk_pdf(src_json STRING, chunk_size INT64, overlap_size INT64)
RETURNS ARRAY<STRING>
LANGUAGE python
WITH CONNECTION `[LOCATION].[CONN_NAME]`
OPTIONS (entry_point='chunk_pdf', runtime_version='python-3.11', packages=['pypdf'])
AS """
import io
import json

from pypdf import PdfReader  # type: ignore
from urllib.request import urlopen, Request

def chunk_pdf(src_ref: str, chunk_size: int, overlap_size: int) -> str:
 src_json = json.loads(src_ref)
 srcUrl = src_json["access_urls"]["read_url"]

 req = urlopen(srcUrl)
 pdf_file = io.BytesIO(bytearray(req.read()))
 reader = PdfReader(pdf_file, strict=False)

 # extract and chunk text simultaneously
 all_text_chunks = []
 curr_chunk = ""
 for page in reader.pages:
     page_text = page.extract_text()
     if page_text:
         curr_chunk += page_text
         # split the accumulated text into chunks of a specific size with overlaop
         # this loop implements a sliding window approach to create chunks
         while len(curr_chunk) >= chunk_size:
             split_idx = curr_chunk.rfind(" ", 0, chunk_size)
             if split_idx == -1:
                 split_idx = chunk_size
             actual_chunk = curr_chunk[:split_idx]
             all_text_chunks.append(actual_chunk)
             overlap = curr_chunk[split_idx + 1 : split_idx + 1 + overlap_size]
             curr_chunk = overlap + curr_chunk[split_idx + 1 + overlap_size :]
 if curr_chunk:
     all_text_chunks.append(curr_chunk)

 return all_text_chunks
""";
```

* Parse the PDF file into chunks
* Generate embeddings after creating a remote model
* Run a vector search to find "`Ou manger un repas tex-mex à volonté?`" or "`where to eat a tex-mex meal buffet-style?`"
* Generate an answer augmented by vector search results of the question "`Ou manger un repas tex-mex à volonté?`" or ""`where to eat a tex-mex meal buffet-style?`"

> aside positive
>
> **Tip:** you can get inspired by  [this tutorial](https://docs.cloud.google.com/bigquery/docs/multimodal-data-sql-tutorial#create_a_python_udf_to_chunk_pdf_data) as well as [this one](https://docs.cloud.google.com/bigquery/docs/rag-pipeline-pdf#create_the_remote_model_for_embedding_generation).

> aside positive
>
> You might have to give the right roles to some service accounts (BQ, Vertex AI)

> aside positive
>
> **Note:** the UDF function can take up to 3mn to be created.

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * An object table referencing the pdf files
> * A table for chunk embeddings
> * A vector search of the question

## Task 3: Machine Learning at scale with BigQuery: Forecasting, classification & ranking

Duration: 30:00

#### **Forecast Waiting times**

The pictures are very cool! You can't wait! Now in order to know which attractions to choose and which ones to avoid, you want to know the actual waiting times for some of the attractions between Paris and California. Your task is to forecast waiting_times of every attraction  using Machine Learning (Arima plus or TimesFM) for every 30mns in 2025.

The data you'll use is in this csv file: **`gs://hackathon_data_disneyland_&lt;YOUR_PROJECT_3DIGITS&gt;/waiting_times.csv`**

The steps of your task are:

* Load the file into your BigQuery dataset under a table called waiting_times.
* Train a forecasting model on your data (Arima_Plus) or **forecast directly using AI.Forecast**
* Evaluate the model performance or  [compare](https://cloud.google.com/bigquery/docs/timesfm-time-series-forecasting-tutorial#compare_the_forecasted_data_to_the_input_data) the forecasted data to the input data

> aside positive
>
> **Tips:** If you train a model, make sure to split your data into training, evaluation and prediction sets. You can use views.

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * A table named attendance
>
> If the model used is Arima_Plus:
>
> * A trained model
> * A table of the evaluation results named arima_plus_evaluation
>
> If the model used is TimesFM:
>
> * A table containing the forecasted data named timesfm_forecasted_waiting_time

#### **Classify the rides by intensity**

You're visiting Disneyland with friends, and while the park is generally family-friendly, some rides can be too intense for some people. Let's use BigQuery Managed AI functions to classify and rank the attractions by thrill & intensity level, without human bias, so we can accommodate to everyone.

* Use `AI.CLASSIFY` to categorize rides based on their descriptions into one of three magical categories: [easy-peasy, thrilling, extreme]

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * A table with a column class with the extracted category

#### **Rank rides on thrill level**

* Use `AI.SCORE` to compare and order attractions based on a **thrill level**, where Rank 10 is the most extreme and Rank 1 is the least.

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * A table with a column rank with the rank score

## Task 3-Bonus: Reverse-ETL, from BigQuery to AlloyDB

Duration: 30:00

You've taken advantage of BigQuery's powerful capabilities to generate insights on large amounts of data. Now you want those insights to be actionable by your operational applications (and AI agents!).

But how? By going the other way around! AlloyDB for Postgres thrive at serving data with low-latency and high speed, perfect for your critical user facing applications. So let's reverse-ETL the data we just generated.

In order to do that, we are gonna use a brand new feature, still in private preview, called "BigQuery views" in AlloyDB. This feature allows you to query BigQuery data right in your Postgres database.

> aside positive
>
> **Note:** As this feature is very recent and not yet public, we will guide you through the steps to implement and use it.

First, you need to grant your AlloyDB cluster service account the necessary privileges to query BigQuery.

```
gcloud beta alloydb clusters describe <CLUSTER ID> --region=europe-west1
```

The output contains a serviceAccountEmail field, which is the service account for this cluster.

In the Google Cloud Console, go to the IAM page and grant the following privileges to this principal:

* BigQuery Data Viewer (roles/bigquery.dataViewer)
* BigQuery Read Session User (roles/bigquery.readSessionUser)

Now, go to AlloyDB Studio in the Console and connect to the "postgres" database.

> aside positive
>
> **AlloyDB Postgres credentials:**
>
> * Database: postgres
> * Username: postgres
> * Password: buildwithgemini2025

Execute the following queries to install and configure the new feature:

```
CREATE EXTENSION bigquery_fdw; 

CREATE SERVER bq_disney FOREIGN DATA WRAPPER bigquery_fdw; 

CREATE USER MAPPING FOR postgres SERVER bq_disney ;
```

You can now create a "foreign table" that will be mapped to a current table in BigQuery. Use any table you created in Task 3. Here's an example of the syntax:

```
CREATE FOREIGN TABLE reviews_analysis ( "Review_ID" int,
    "Sentiment" text) SERVER bq_disney OPTIONS (PROJECT 'bqml-hack25par-xxx',
    dataset 'disney',
    TABLE 'reviews_analysis');
```

All set, let's query the table! Execute a first SELECT to validate the link between AlloyDB and BigQuery, and finally create a new table in AlloyDB to ingest the data from your foreign table.

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * Show the result of a SELECT querying BigQuery from AlloyDB
> * A new table in AlloyDB containing the data you queried in BigQuery

## Task 4: Out-of-the-Box Data Agents

Duration: 30:00

You have friends who want to contribute to the Disneyland Application project. They have access to the data in BigQuery, but have varying levels in SQL and data engineering. You want to leverage BigQuery's recent announcements around data agents that are already integrated into the UI to assist your friends:

* Create Data pipelines.
* Collaborate on SQL code.
* Talk to their Data.

#### **Data Engineering Agents for automating your Data Pipelines**

Create a new view average_waiting_time that joins the table waiting time and attractions, and calculates the average waiting_time per attraction, using the Data Engineering Agent.  

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * A data pipeline created in BigQuery's Data Pipelines
> * A view average_waiting_time with the relevant columns

#### **Create your Conversational Analytics agent in BigQuery**

What if you could create an agent to talk to your data, without coding, without SQL, and without deployment, and from BigQuery's interface, how cool would that be?
Well it's possible today with the "Agents" tab in BigQuery.

<img src="img/98570651479cfd3.png" alt="98570651479cfd3.png"  width="624.00" />

* Create an agent my_disney_friend, that connects to your disney tables. You can improve the agent performance by filling the Agent instructions. Ask questions like "what percentage of positive vs negative reviews, what's the average waiting time per attraction,etc ... ?"
* Publish the agent in BigQuery and on API (you will be using it later).

> aside negative
>
> **Checkpoint**: To validate this task you will need:
>
> * An agent published in BigQuery

## Task 5: Improve your development experience with Gemini-CLI

Duration: 30:00

In this AI era, building software has never been more accessible. You have thousands of ideas for your Disneyland application, and you want to use your data at its maximum capacity. You want to go further than just talking to the data, now you need action!

To help you in that path, you are gonna need help. And we've got you covered.

Gemini CLI is an open-source AI agent that brings the power of Gemini directly into your terminal. Developers can build powerful applications and thanks to extensions, they can also interact with various MCP (Model Context Protocol) servers.

Amongst those, you can of course find extensions to query your AlloyDB or BigQuery data!

> aside positive
>
> **Note:** If you want to find out more about other Gemini-CLI extensions, follow this link:  [https://geminicli.com/extensions/](https://geminicli.com/extensions/)

In this task, your goal is to:

* Install Gemini-CLI (in your own terminal or in Cloud Shell)
* Install BigQuery and AlloyDB Gemini-CLI extensions
* Create an environment file that allows Gemini-CLI to connect to your BigQuery and AlloyDB instances
* Ask Gemini-CLI to generate a fancy single HTML page that explains the content of your AlloyDB database
* Do the same for BigQuery

> aside positive
>
> **Note:** You can be creative in what you ask Gemini-CLI to do. Your goal is to showcase how Gemini-CLI was able to connect to your data to build something out of it. It can be an HTML page, but anything you can think of. Have fun with it!

> aside negative
>
> **Checkpoint**: To validate this task you will need to showcase:
>
> * The output of /mcp command from Gemini-CLI highlighting the two extensions connected to your AlloyDB and Gemini
> * Two successful prompts that you used to generate insights from your AlloyDB and BigQuery data
> * The two HTML pages that describe the data in BigQuery and AlloyDB

Here are some examples of what you could generate in a single (or few) prompts with Gemini-CLI and its extensions. Now imagine that you could do that with real life applications?  <img src="img/147214db02ae32f7.png" alt="147214db02ae32f7.png"  width="379.50" />

<img src="img/d73dda1665b16c66.png" alt="d73dda1665b16c66.png"  width="383.49" />

## Task 6: Create an AI agent to interact with your data

Duration: 60:00

In order to offer a brand new user experience to DisneyLand visitors, you will create an assistant that can help them during their trip. Your agent will be able to:

* List all the available attractions in the parc
* Recommend an attraction based on expectations
* Add reviews for an attraction
* Provide an estimation of the waiting time for an attraction in the next few hours
* Provide an overview of the reviews for a specific attraction

You will make sure that your assistant can only answer questions related to DisneyLand, and it keeps a friendly tone with the user. Tune your agent prompt to make sure the agent picks the right tools for the user's needs.

The steps you need to follow are:

* Deploy an  [MCP toolbox for databases](https://github.com/googleapis/genai-toolbox) server that use AlloyDB and BigQuery as sources
* Declare 5 different tools for your MCP server that query AlloyDB and BigQuery and map the agent actions listed earlier
* Use the MCP Toolbox UI to validate each of your tools
* Deploy an agent using  [Agent Development Kit](https://google.github.io/adk-docs/) that can use the tools exposed by your MCP toolbox server
* Connect to your ADK web interface and showcase a full discussion with your assistant, including all the available tools

> aside positive
>
> **Tips:** ADK and MCP Toolbox can be deployed on Cloud Shell for fast development and debugging. Once you're ready, you can then deploy to Cloud Run or Agent engine.

> aside negative
>
> **Checkpoint**: To validate this task you will need to showcase:
>
> * The MCP Toolbox UI showcasing all your tools and a successful execution of one of it
> * A full discussion with your assistant in the ADK web interface, demonstrating all the different tools (listing attractions, recommendation, add review, etc.).

***Bonus step if you finish early:***

Your agent is ready? Let's deploy it to Agent Engine !
