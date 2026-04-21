# Disneyland Data Analytics Hackathon - Coach's Guide

## Challenge 1: The Magic Begins: Operational Data & Syncing

### Solution Steps

#### 1. Data Loading in AlloyDB

* **Table Creation:**

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

* **Data Import:** Students can use the AlloyDB UI "Import" feature or `gcloud alloydb instances import`.
* **Embeddings:**

    ```sql
    CREATE EXTENSION IF NOT EXISTS pgvector;
    ALTER TABLE disneyland_attractions ADD COLUMN embedding vector(768);

    -- Example using AlloyDB AI (Native integration)
    UPDATE disneyland_attractions
    SET embedding = azure_ai.generate_embeddings('text-embedding-004', description) -- Note: check exact function name for AlloyDB AI
    -- Or using the Vertex AI integration via ml_predict_row
    ```

    *Note: Students should use the `google_ml_integration` extension if available.*

#### 2. Sync to BigQuery with Datastream

* **AlloyDB Prep:**

    ```sql
    CREATE PUBLICATION pub_disney FOR TABLE disneyland_reviews, disneyland_attractions;
    ALTER USER postgres WITH REPLICATION;
    SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('slot_disney', 'pgoutput');
    ```

* **Datastream Config:**
  * Source: AlloyDB (PostgreSQL).
  * Destination: BigQuery.
  * Region: `europe-west1`.
  * Dataset: `disney`.

## Challenge 2: Polishing the Wand: Data Discovery & Quality

### Solution Steps

* **Semantic Search:** Use the "Search" tab in BQ Studio.
* **Data Insights:** Click on the `disneyland_reviews` table and select the "Insights" tab.
* **Metadata Generation:** Click on the "Edit" button for dataset/table descriptions and use the "Suggest with Gemini" option.
* **Quality Scan:**
  * Check for NULL in `branch`.
  * `rating` BETWEEN 1 AND 5.
  * `review_id` uniqueness.
* **Data Preparation:** Open the table in Data Preparation, follow Gemini suggestions for cleaning (Filter NULLs, replace "missing").

## Challenge 3: Seeing Through the Magic Mirror: Multi-modal Analysis

### Solution Steps

#### 1. Image Analysis

* **Object Table:**

    ```sql
    CREATE OR REPLACE EXTERNAL TABLE `disney.attraction_images`
    WITH CONNECTION `europe-west1.my-connection`
    OPTIONS (
      object_metadata = 'DIRECTORY',
      uris = ['gs://hackathon_data_disneyland_xxx/attraction_parc_photos/*']
    );
    ```

* **Gemini Classification:**

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

* **Python UDF for Chunking:** (Use the code provided in the student guide/content.md).
* **Vector Search:**

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

## Challenge 4: Predicting the Future: ML & Reverse-ETL

### Solution Steps

#### 1. Forecasting

* **Model Training:**

    ```sql
    CREATE OR REPLACE MODEL `disney.waiting_time_forecast`
    OPTIONS(model_type='ARIMA_PLUS', time_series_timestamp_col='timestamp', time_series_data_col='waiting_time', time_series_id_col='attraction_id')
    AS SELECT timestamp, waiting_time, attraction_id FROM `disney.waiting_times`;
    ```

#### 2. Classification & Scoring

* **Classify:** `SELECT * FROM AI.CLASSIFY(MODEL ..., (SELECT description FROM ...), ...)`
* **Score:** `SELECT * FROM AI.SCORE(MODEL ..., (SELECT description FROM ...), ...)`

#### 3. Reverse-ETL

* **AlloyDB Setup:**

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

## Challenge 5: The Ultimate Wizard: Intelligent Agents

### Solution Steps

* **Conversational Agent:** Setup via the "Agents" tab in BigQuery. Ensure it has access to the `disney` dataset.
* **Gemini-CLI:**
  * Install: `npm install -g @google/gemini-cli` (or equivalent).
  * Configure `.env` with project IDs and credentials.
  * Use `/mcp` to verify connectivity.
* **ADK & MCP Toolbox:**
  * Deploy MCP Toolbox: `gcloud run deploy mcp-toolbox ...`
  * Deploy ADK: Follow the ADK docs to connect it to the MCP endpoint.
  * Tool definition example (for MCP Toolbox):

    ```yaml
    tools:
        - name: list_attractions
        description: List all Disneyland attractions
        sql: SELECT name, description FROM disneyland_attractions
    ```
