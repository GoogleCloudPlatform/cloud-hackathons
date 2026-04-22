# Disneyland Data Analytics

## Introduction

Welcome to the coach's guide for the *Disneyland Data Analytics* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Data Ingestion & Sync
  - Load data into AlloyDB, create embeddings for similarity search, and sync data to BigQuery using Datastream.
- Challenge 2: Data Discovery & Quality
  - Explore data semantically in BigQuery, perform profiling and quality scans, and use Gemini for data preparation.
- Challenge 3: Multi-modal Analysis
  - Analyze attraction images and build a RAG system to query park brochures using PDF chunking and vector search.
- Challenge 4: ML & Reverse-ETL
  - Forecast waiting times, classify rides by intensity, and implement Reverse-ETL to move insights back to AlloyDB.
- Challenge 5: Intelligent Agents
  - Create conversational analytics agents in BigQuery and build a custom AI agent using ADK and MCP Toolbox.

## Challenge 1: Data Ingestion & Sync

### Notes & Guidance

#### 1. Data Loading in AlloyDB

- **Table Creation:**

    ```sql
    CREATE TABLE disneyland_reviews (
        review_id INT PRIMARY KEY,
        rating INT,
        year_month TEXT,
        reviewer_location TEXT,
        review_text TEXT,
        branch TEXT
    );

    CREATE TABLE disneyland_attractions (
        attraction_id INT PRIMARY KEY,
        branch TEXT,
        name TEXT,
        description TEXT
    );
    ```

- **Data import:** Students can use the AlloyDB UI "Import" feature or `gcloud alloydb instances import`.
- **Generating the embeddings:**

    ```sql
    CREATE EXTENSION IF NOT EXISTS vector;

    ALTER TABLE disneyland_attractions ADD COLUMN embedding vector(768);

    UPDATE 
        disneyland_attractions
    SET
        embedding = google_ml.embedding('text-embedding-004', description)::vector;
    ```

- **Searching in embeddings:**

   ```sql
   SELECT
    name,
    description,
    branch
   FROM
    disneyland_attractions
   ORDER BY
    embedding <=> google_ml.embedding('text-embedding-004', 'Dark ride in space')::vector ASC
   LIMIT
    5;
   ```

#### 2. Sync to BigQuery with Datastream

- **AlloyDB Prep:**

    ```sql
    ALTER USER postgres WITH REPLICATION;
    CREATE PUBLICATION pub_disney FOR TABLE disneyland_reviews, disneyland_attractions;
    SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('slot_disney', 'pgoutput');
    ```

- **Public IP Allowlisting:** In case any other location is chosen, this is the approach

  ```shell
  gcloud compute firewall-rules create allow-datastream-us-central1 \
    --network=default \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=34.72.28.29/32,34.67.234.134/32,34.67.6.157/32,34.72.239.218/32,34.71.242.81/32 \
    --rules=tcp:5432 \
    --description="Allow Datastream public IPs for us-central1 to access PostgreSQL"
  ```

- **Datastream configuration:**
  - Source: AlloyDB (PostgreSQL)
    - Use database proxy IP to connect, user `postgres`, database `postgres`
    - IP Allowlisting
    - `slot_disney` as the replication slot and `pubset` as publication
    - Select the `disneyland_attractions` and `disneyland_reviews` from the schema `public`
  - Destination: BigQuery
    - Dataset: `disney`

## Challenge 2: Data Discovery & Quality

### Notes & Guidance

- **Semantic Search:** Use the "Search" tab in BQ Studio.
- **Data Insights:** Click on the `disneyland_reviews` table and select the "Insights" tab.
- **Metadata Generation:** Click on the "Edit" button for dataset/table descriptions and use the "Suggest with Gemini" option.
- **Quality Scan:**
  - Check for NULL in `branch`.
  - `rating` BETWEEN 1 AND 5.
  - `review_id` uniqueness.
- **Data Preparation:** Open the table in Data Preparation, follow Gemini suggestions for cleaning (Filter NULLs, replace "missing").

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
