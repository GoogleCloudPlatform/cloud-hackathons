# Disneyland Data Analytics

## Introduction

Welcome to the coach's guide for the *Disneyland Data Analytics* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Data Ingestion, Search and Sync
- Challenge 2: Data Discovery & Quality
- Challenge 3: Multi-modal Analysis
- Challenge 4: ML & Reverse-ETL
- Challenge 5: Intelligent Agents

## Challenge 1: Data Ingestion, Search and Sync

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

#### 2. Semantic Search

##### Generating the Embeddings

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

##### Searching in Embeddings

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

#### 3. Sync to BigQuery with Datastream

##### AlloyDB Preperation

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

##### Connectivity Preparation

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

##### Datastream configuration

Participants can either create the source & destination connection profiles separately and refer to them when creating the *Stream*, or just start with *Create Stream* and configure those during the setup. All of the required configuration is in the instructions, so it should be rather straight forward. Depending on which method is chosen (defnining the profiles in the *Create stream* wizard or individually, the order of some of the parameters might be different).

> [!WARNING]  
> Make sure that the participants use the public IP of the database proxy as the hostname and validate that the connection is successfull

## Challenge 2: Data Discovery & Quality

### Notes & Guidance

- **Semantic Search:** Use the "Search" tab in BQ Studio.
- **Data Insights:** Click on the `disneyland_reviews` table and select the "Insights" tab.
- **Metadata Generation:** Click on the "Edit" button for dataset/table descriptions and use the "Suggest with Gemini" option.

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

#### Data Preparation

- Click on *Filter* end ask Gemini *filter out rows where `branch` is NULL or empty*, this should yield `branch IS NOT NULL AND branch != ''`
- *Transform*, replace "missing" with NULL values: `NULLIF(year_month, 'missing')`
- *Transform*, replace all underscores with spaces in the branch column: `REPLACE(branch, '_', ' ')`
- *Destination*, `disney` dataset, `disneyland_reviews_cleaned` table

## Challenge 3: Multi-modal Analysis

### Notes & Guidance

#### 1. Image Analysis

- **Object Table:**

    ```sql
    CREATE OR REPLACE EXTERNAL TABLE `disney.attraction_images`
    WITH CONNECTION `europe-west1.my-connection`
    OPTIONS (
      object_metadata = 'DIRECTORY',
      uris = ['gs://hackathon_data_disneyland_xxx/attraction_parc_photos/*']
    );
    ```

- **Gemini Classification:**

    ```sql
    SELECT *
    FROM ML.GENERATE_TEXT(
      MODEL `disney.gemini_pro_vision`,
      TABLE `disney.attraction_images`,
      STRUCT(
        'Is this photo from a Disneyland park? Answer with True or False.' AS prompt,
        TRUE AS flatten_json_output
      )
    );
    ```

#### 2. RAG System with PDF Brochures

- **Python UDF for Chunking:** (Use the code provided in the student guide/content.md).
- **Vector Search:**

    ```sql
    SELECT
      query_text,
      base.text_content,
      distance
    FROM
      VECTOR_SEARCH(
        TABLE `disney.brochure_embeddings`,
        'embedding',
        (SELECT ml_generate_embedding_result, content AS query_text
         FROM ML.GENERATE_EMBEDDING(MODEL `disney.embedding_model`, (SELECT 'Where to eat a tex-mex meal buffet-style?' AS content))),
        top_k => 3
      );
    ```

## Challenge 4: ML & Reverse-ETL

### Notes & Guidance

#### 1. Forecasting

- **Model Training:**

    ```sql
    CREATE OR REPLACE MODEL `disney.waiting_time_forecast`
    OPTIONS(model_type='ARIMA_PLUS', time_series_timestamp_col='timestamp', time_series_data_col='waiting_time', time_series_id_col='attraction_id')
    AS SELECT timestamp, waiting_time, attraction_id FROM `disney.waiting_times`;
    ```

#### 2. Classification & Scoring

- **Classify:** `SELECT * FROM AI.CLASSIFY(MODEL ..., (SELECT description FROM ...), ...)`
- **Score:** `SELECT * FROM AI.SCORE(MODEL ..., (SELECT description FROM ...), ...)`

#### 3. Reverse-ETL

- **AlloyDB Setup:**

    ```sql
    CREATE EXTENSION bigquery_fdw;
    CREATE SERVER bq_disney FOREIGN DATA WRAPPER bigquery_fdw;
    CREATE USER MAPPING FOR postgres SERVER bq_disney;

    CREATE FOREIGN TABLE reviews_analysis (
        review_id INT,
        sentiment TEXT
    ) SERVER bq_disney OPTIONS (
        project 'YOUR_PROJECT_ID',
        dataset 'disney',
        table 'reviews_analysis'
    );
    ```

## Challenge 5: Intelligent Agents

### Notes & Guidance

- **Conversational Agent:** Setup via the "Agents" tab in BigQuery. Ensure it has access to the `disney` dataset.
- **Gemini-CLI:**
  - Install: `npm install -g @google/gemini-cli` (or equivalent).
  - Configure `.env` with project IDs and credentials.
  - Use `/mcp` to verify connectivity.
- **ADK & MCP Toolbox:**
  - Deploy MCP Toolbox: `gcloud run deploy mcp-toolbox ...`
  - Deploy ADK: Follow the ADK docs to connect it to the MCP endpoint.
  - Tool definition example (for MCP Toolbox):

    ```yaml
    tools:
        - name: list_attractions
        description: List all Disneyland attractions
        sql: SELECT name, description FROM disneyland_attractions
    ```
