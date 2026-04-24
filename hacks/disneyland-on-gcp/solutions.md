# Disneyland Data Analytics

## Introduction

Welcome to the coach's guide for the *Disneyland Data Analytics* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Data Ingestion in AlloyDB
- Challenge 2: Semantic Search with Embeddings
- Challenge 3: Real-time Sync with Datastream
- Challenge 4: Data Discovery & Metadata Management
- Challenge 5: Data Profiling & Quality
- Challenge 6: Data Preparation with Gemini
- Challenge 7: Sentiment & Category Analysis
- Challenge 8: Visualization with Data Canvas
- Challenge 9: Multimodal Image Analysis
- Challenge 10: PDF Document Intelligence (RAG)
- Challenge 11: Time-Series Forecasting
- Challenge 12: Intelligent Classification & Ranking
- Challenge 13: Operationalizing Insights with Reverse-ETL
- Challenge 14: Automated Data Engineering Agents
- Challenge 15: Conversational Analytics Agents
- Challenge 16: Rapid Development with Gemini-CLI
- Challenge 17: Custom Agent Development (ADK & MCP)

## Challenge 1: Data Ingestion in AlloyDB

### Notes & Guidance

#### 1. Data Loading in AlloyDB

##### Table Creation

Participants can use `psql` from Cloud Shell, but the recommendation would be to use SQL Studio in the AlloyDB Console. In order to connect built-in authentication with the user `postgres` and database `postgres` should be used. Password should be provided by the coach.

Creating the tables is rather straight-forward; in case the participants struggle with the syntax, remind them to use the Gemini powered *Generate SQL* capability in the SQL Editor.

> [!NOTE]  
> The CSV file that's imported in the next step contains duplicates for `review_id`, if that columnn is made a primary key or has any other unique constraints import will fail.

```sql
CREATE TABLE disneyland_reviews (
    review_id INT,
    rating INT,
    year_month TEXT,
    reviewer_location TEXT,
    review_text TEXT,
    branch TEXT
);

CREATE TABLE disneyland_attractions (
    attraction_id INT,
    branch TEXT,
    name TEXT,
    description TEXT
);
```

##### Data Import

Students can use the AlloyDB UI *Import* feature from the Console (on cluster overview page, top navbar) or `gcloud alloydb instances import`.

## Challenge 2: Semantic Search with Embeddings

### Notes & Guidance

#### Generating the Embeddings

First we need to install the `vector` extension in AlloyDB

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Then a new `vector` column is added to the table.

> [!NOTE]  
> The `text-embedding-005` model below is an example, participants can use any supported embbedding model version, as long as the same model and version is also used when doing the search. Also keep in mind the vector length (size of the embedding) depends on the specific model and can vary from 768 (`text-embedding-005`) to 3072 (`gemini-embedding-001`) unless otherwise specified.

```sql
ALTER TABLE disneyland_attractions ADD COLUMN embedding vector;

UPDATE 
    disneyland_attractions
SET
    embedding = google_ml.embedding('text-embedding-005', description)::vector;
```

#### Searching in Embeddings

Searching is similar to generating the embeddings, make sure that the same model and version is used.

```sql
SELECT
  name,
-- description,
  branch
FROM
  disneyland_attractions
ORDER BY
  embedding <=> google_ml.embedding('text-embedding-005', 'Dark ride in space')::vector ASC
LIMIT
 5;
```

The search should return something like this:

| name | branch |
| --- | --- |
| Space Mountain | Disneyland_California |
| Hyperspace Mountain | Disneyland_HongKong |
| Star Tours: The Adventures Continue | Disneyland_Paris |
| Les Voyages de Pinocchio | Disneyland_Paris |
| Blanche-Neige et les Sept Nains | Disneyland_Paris |

## Challenge 3: Real-time Sync with Datastream

### Notes & Guidance

#### AlloyDB Preperation

First we need to grant permissions to the `postgres` user.

```sql
ALTER USER postgres WITH REPLICATION;
```

And then we can create the publication and replication slot.

```sql
CREATE PUBLICATION pub_disney FOR TABLE disneyland_reviews, disneyland_attractions;
SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('slot_disney', 'pgoutput');
```

> [!WARNING]  
> Sometimes running the SQL commands above in a single run causes an error message: postgresql error: cannot create logical replication slot in transaction that has performed writes. Easiest way to solve that is to run the statements one by one.

#### Connectivity Preparation

The easiest method to configure the Datastream to AlloydDB connection is through IP Allowlisting. During the initialization we've already configured the required firewall rules for the region `us-central1` using the following command.

```shell
gcloud compute firewall-rules create fwr-ingress-allow-datastream-us-central1 \
  --network=default \
  --action=ALLOW \
  --direction=INGRESS \
  --source-ranges=34.72.28.29/32,34.67.234.134/32,34.67.6.157/32,34.72.239.218/32,34.71.242.81/32 \
  --rules=tcp:5432 \
  --description="Allow Datastream public IPs for us-central1 to access AlloyDB/PostgreSQL"
```

In case any other region is used, a similar rule needs to be created, where the `source-ranges` will depend on the chosen region (and will be displayed in Datastream UI).

#### Datastream configuration

Participants can either create the source & destination connection profiles separately and refer to them when creating the *Stream*, or just start with *Create Stream* and configure those during the setup. All of the required configuration is in the instructions, so it should be rather straight forward. Depending on which method is chosen (defining the profiles in the *Create stream* wizard or individually, the order of some of the parameters might be different).

> [!WARNING]  
> Make sure that the participants use the public IP of the database proxy as the hostname and validate that the connection is successfull

## Challenge 4: Data Discovery & Metadata Management

### Notes & Guidance

- **Semantic Search:** Use the "Search" tab in BQ Studio.
- **Data Insights:** Click on the `disneyland_reviews` table and select the "Insights" tab.
- **Metadata Generation:** Click on the "Edit" button for dataset/table descriptions and use the "Suggest with Gemini" option.

## Challenge 5: Data Profiling & Quality

### Notes & Guidance

#### Data Profiling

Quick profile with 10% sampling should be sufficient and we expect the following results

- What's the average rating of Disneyland? *4.44*
- Where are reviewers located the most? *United_States*
- Are all reviews unique? *No, uniquness is not 100%*
- What's the percentage of "missing" data from the year_month column? *~3.98%*

> [!WARNING]  
> Since quick profile does a 10% sample, there might be some small discrepancies in the expected values above.

#### Quality Scan

Add 3 built-in rule types, *Null check* for `branch` column, *Value set check* for `rating` column, and *Uniqueness check* for `review_id` column. Once you have created these rule types, you need to edit the `rating` column rule to include the set of allowed values. Once this runs, the uniqueness check for the `review_id` should fail.

## Challenge 6: Data Preparation with Gemini

### Notes & Guidance

- Click on *Filter* end ask Gemini *filter out rows where `branch` is NULL or empty*, this should yield `branch IS NOT NULL AND branch != ''`
- *Transform*, replace "missing" with NULL values: `NULLIF(year_month, 'missing')`
- *Transform*, replace all underscores with spaces in the branch column: `REPLACE(branch, '_', ' ')`
- *Destination*, `disney` dataset, `disneyland_reviews_cleaned` table

## Challenge 7: Sentiment & Category Analysis

### Notes & Guidance

#### 1. Analyze Reviews with Gemini

##### Create the Model

```sql
CREATE OR REPLACE MODEL `disney.gemini_flash`
  REMOTE WITH CONNECTION `us-central1.conn`
  OPTIONS (ENDPOINT = 'gemini-2.5-flash');
```

##### Extract Categories

```sql
CREATE OR REPLACE TABLE `disney.reviews_categories` AS
SELECT
  review_id, rating, year_month, reviewer_location, review_text, branch, result AS categories 
FROM
  AI.GENERATE_TEXT(
    MODEL `disney.gemini_flash`,
    (
      SELECT
        *,
        """Identify categories (e.g., cleanliness, food, waiting time) in the following review text 
        and return thme as a comma separated list. Review: 
        """ || review_text AS prompt
      FROM `disney.public_disneyland_reviews`
      LIMIT 100
    )
  )
```

##### Sentiment Analysis

```sql
CREATE OR REPLACE TABLE `disney.reviews_analysis` AS
SELECT 
  review_id, rating, year_month, reviewer_location, review_text, branch, result AS sentiment
FROM 
  AI.GENERATE_TEXT(
    MODEL `disney.gemini_flash`,
    (
      SELECT *,
      """Classify the sentiment of this review as Positive, Negative, or Neutral 
      and only output single word. Review:
      """ || review_text AS prompt
      FROM `disney.public_disneyland_reviews` 
      LIMIT 100
    )
  )
```

## Challenge 8: Visualization with Data Canvas

### Notes & Guidance

#### Visualize with Data Canvas

Participants should navigate to the *Data Canvas* tab in BigQuery Studio, add the `reviews_analysis` table, and use the "Visualize" or "Analyze" buttons to generate the requested charts. The *Canvas assistant* is very useful. Using the task descriptions as prompt works pretty good, just make sure that join is mentioned (or performed before) for the second graph.

## Challenge 9: Multimodal Image Analysis

### Notes & Guidance

#### 1. Image Analysis

##### Create Object Table for Images

```sql
CREATE OR REPLACE EXTERNAL TABLE `disney.attraction_images`
WITH CONNECTION `us-central1.conn`
OPTIONS (
  object_metadata = 'SIMPLE',
  uris = ['gs://<YOUR_BUCKET>/attraction_parc_photos/*']
);
```

##### Analyze Images

```sql
CREATE OR REPLACE TABLE disney.images_analysis AS
SELECT
  uri,
  result AS is_disneyland
FROM
  AI.GENERATE_TEXT(
    MODEL `disney.gemini_flash`,
    TABLE `disney.attraction_images`,
    STRUCT(
      'Is this photo from a Disneyland park? Answer with true or false, output only true or false and if unsure stick to false'
        AS prompt
    )
  )
```

## Challenge 10: PDF Document Intelligence (RAG)

### Notes & Guidance

#### 1. RAG System for Brochures

##### Create Object Table for PDFs

```sql
CREATE OR REPLACE EXTERNAL TABLE `disney.brochures_pdf`
WITH CONNECTION `us-central1.conn`
OPTIONS (
  object_metadata = 'SIMPLE',
  uris = ['gs://<YOUR_BUCKET>/disneyland_brochures/*.pdf']
);
```

##### Chunk PDFs (Using pre-provided UDF)

```sql
CREATE OR REPLACE TABLE disney.brochures_chunks AS
SELECT 
  uri, chunk
FROM
  `disney.brochures_pdf`,
  UNNEST(
    disney.chunk_pdf(
      TO_JSON_STRING(
        OBJ.GET_ACCESS_URL(OBJ.MAKE_REF(uri, 'us-central1.conn'), 'r')
      ),
      1000,
      100
    )
  ) AS chunk;
```

##### Generate Embeddings

```sql
CREATE OR REPLACE MODEL `disney.embedding_model`
  REMOTE WITH CONNECTION `us-central1.conn`
  OPTIONS (ENDPOINT = 'gemini-embedding-001');
```

```sql
CREATE OR REPLACE TABLE disney.brochures_embeddings AS
SELECT *
FROM
  AI.GENERATE_EMBEDDING(
    MODEL `disney.embedding_model`,
    (
      SELECT uri, chunk AS content FROM disney.brochures_chunks
    )
  );
```

##### Vector Search

```sql
SELECT query.query, base.content, distance
FROM
  VECTOR_SEARCH(
    TABLE `disney.brochures_embeddings`,
    'embedding',
    (
      SELECT embedding, content AS query
      FROM
        AI.GENERATE_EMBEDDING(
          MODEL `disney.embedding_model`,
          (SELECT 'Where to eat a tex-mex meal buffet-style?' AS content)
        )
    ),
    top_k => 3
  );
```

## Challenge 11: Time-Series Forecasting

### Notes & Guidance

#### 1. Forecast Waiting Times

```sql
-- Load data first (or using the UI or bq load)
LOAD DATA OVERWRITE `disney.waiting_times`
FROM FILES (
  format = 'CSV',
  uris = ['gs://<YOUR_BUCKET>/waiting_time.csv']
);

CREATE OR REPLACE TABLE disney.forecasted_wait_times AS
SELECT *
FROM
  AI.FORECAST(
    (
      SELECT
        TIMESTAMP_TRUNC(usage_start_time, HOUR) AS time_bucket,
        attraction,
        AVG(waiting_time) AS avg_wait_time
      FROM `disney.waiting_times`
      GROUP BY 1, 2
    ),
    horizon => 15,
    confidence_level => 0.95,
    timestamp_col => 'time_bucket',
    id_cols => ['attraction'],
    data_col => 'avg_wait_time'
    -- output_historical_time_series => true
  );

```

## Challenge 12: Intelligent Classification & Ranking

### Notes & Guidance

#### 1. Classify and Rank Rides

```sql
CREATE OR REPLACE TABLE `disney.attractions_classified` AS
SELECT
  *,
  AI.CLASSIFY(
    description,
    categories => ['easy-peasy', 'thrilling', 'extreme']
  ) AS category,
  AI.SCORE(
    """
    Score attractions on a **thrill level** from 1 to 10 based on their description. Description: 
    """ || description
  ) as thrill_level
FROM
  `disney.attractions`

```

## Challenge 13: Operationalizing Insights with Reverse-ETL

### Notes & Guidance

#### 1. Reverse-ETL to AlloyDB

##### Install Extension

As this functionality is not part of the documentation, you can use the following to get things working:

```sql
CREATE EXTENSION bigquery_fdw; 

CREATE SERVER bq_disney FOREIGN DATA WRAPPER bigquery_fdw; 

CREATE USER MAPPING FOR postgres SERVER bq_disney;
```

You can now create a *foreign table* that will be mapped to a specific table in BigQuery.

```sql
CREATE FOREIGN TABLE reviews_analysis (
    "review_id" int,
    "sentiment" text
  ) 
  SERVER bq_disney OPTIONS (
    PROJECT '<YOUR PROJECT ID>',
    DATASET 'disney',
    TABLE 'reviews_analysis'
  );
```

And before you can use this table, you'll need to grant a service account the required permissions, running from Cloud Shell:

```shell
SA=$(gcloud beta alloydb clusters describe disney-cluster --region=us-central1 --format="value(serviceAccountEmail)")
for ROLE in "roles/bigquery.dataViewer" "roles/bigquery.readSessionUser"; do
  gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:$SA" \
    --role="$ROLE"
done
```

Now you can just run queries on the table from AlloyDB:

```sql
SELECT * FROM reviews_analysis
```

## Challenge 14: Automated Data Engineering Agents

### Notes & Guidance

- **Data Engineering Agent:** Open BigQuery Studio, click on *Pipelines*, and use the Gemini icon to prompt for the view creation.

## Challenge 15: Conversational Analytics Agents

### Notes & Guidance

- **Conversational Analytics Agent:** Go to the *Agents* tab, select the `disney` dataset, and configure the agent with instructions.

## Challenge 16: Rapid Development with Gemini-CLI

### Notes & Guidance

#### 1. Gemini-CLI

Participants should install the CLI via `npm install -g @google/gemini-cli` (or as instructed in the tool's documentation).
Configuring extensions:

```bash
gemini mcp add bigquery
gemini mcp add alloydb
```

Prompts for HTML generation:

- *"Generate a single HTML page with a dashboard summarizing the Disneyland reviews from BigQuery."*
- *"Generate a single HTML page summarizing the attractions and their descriptions from AlloyDB."*

## Challenge 17: Custom Agent Development (ADK & MCP)

### Notes & Guidance

#### 1. ADK & MCP Toolbox

- **MCP Toolbox:** Use the provided GitHub repository link to deploy the toolbox. Configure sources to point to your project's AlloyDB and BigQuery.
- **ADK Agent:** Use the ADK documentation to create a new agent. The core is the `agent.yaml` or code where tools are defined as MCP calls.
- **Verification:** Ensure the agent can answer: *"What is the best time to join the queue for Space Mountain?"* (This requires the agent to call the tool that queries the forecast data).
