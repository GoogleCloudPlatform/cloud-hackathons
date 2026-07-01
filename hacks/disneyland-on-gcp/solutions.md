# Disneyland Agentic Data Cloud - Coach's Guide & Solutions

Welcome to the coach's guide for the *Disneyland Agentic Data Cloud* gHack. This guide contains the complete reference implementations, SQL queries, configurations, and code blocks for all 9 challenges of the hackathon.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

* Challenge 1: Setting up AlloyDB and replicating data to BigQuery
* Challenge 2: Creating the agentic database layer
* Challenge 3: Sentiment and wait-time forecasting
* Challenge 4: Image classification and brochure RAG
* Challenge 5: Graph analytics and visitor flow
* Challenge 6: Conversational analytics for insights
* Challenge 7: From insights to action, syncing BigQuery and AlloyDB
* Challenge 8: Exposing Database Tools via MCP
* Challenge 9: Building the guest assistant app

---

## Challenge 1: Setting up AlloyDB and replicating data to BigQuery

### 1.1 Ingest Data into AlloyDB

#### 1. Create a Dedicated Database

Connect to the default `postgres` database in AlloyDB Studio or `psql`, and run:

```sql
CREATE DATABASE disney;
```

Once created, **disconnect and reconnect** to the new `disney` database. All subsequent tables, extensions, and queries must be run within this `disney` database.

#### 2. Create the Tables

Create the two primary operational tables with primary keys:

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

CREATE TABLE visitor_movements (
    visitor_id INT,
    from_attraction_id INT,
    to_attraction_id INT,
    timestamp TIMESTAMP,
    PRIMARY KEY (visitor_id, timestamp)
);
```

#### 3. Add a Full-Text Search Vector

Add a generated `tsvector` column to the attractions table to support hybrid search:

```sql
ALTER TABLE disneyland_attractions 
ADD COLUMN description_tsvector tsvector 
GENERATED ALWAYS AS (to_tsvector('english', description)) STORED;
```

#### 4. Import Data from Cloud Storage

Use the AlloyDB Import API (via the Cloud Console UI or `gcloud`) to import the public CSV files:

* Import `gs://ghacks-disneyland-on-gcp/reviews.csv` into `disneyland_reviews`
* Import `gs://ghacks-disneyland-on-gcp/attractions.csv` into `disneyland_attractions`
* Import `gs://ghacks-disneyland-on-gcp/visitor_movements.csv` into `visitor_movements`

---

### 1.2 Generate Vector Embeddings at the Source

#### 1. Enable Extensions

```sql
CREATE EXTENSION IF NOT EXISTS vector CASCADE;
CREATE EXTENSION IF NOT EXISTS google_ml_integration CASCADE;
```

#### 2. Add the Embedding Column

Add a vector column of size 3072 (corresponding to the dimension of `gemini-embedding-001`):

```sql
ALTER TABLE disneyland_attractions ADD COLUMN embedding vector(3072);
```

#### 3. Generate Embeddings

Populate the column by calling the Vertex AI embedding model natively:

```sql
UPDATE disneyland_attractions
SET embedding = google_ml.embedding('gemini-embedding-001', description)::vector;
```

#### 4. Verify Similarity Search (Checkpoint Validation)

To verify the embeddings, run a similarity search for the top 5 attractions closest to `'thrilling dark ride in space'`:

```sql
SELECT name, description, 1 - (embedding <=> google_ml.embedding('gemini-embedding-001', 'thrilling dark ride in space')::vector) AS similarity
FROM disneyland_attractions
ORDER BY embedding <=> google_ml.embedding('gemini-embedding-001', 'thrilling dark ride in space')::vector ASC
LIMIT 5;
```

---

### 1.3 Set Up Real-Time Replication with One-Click Datastream

1. In the Google Cloud Console, navigate to **AlloyDB > Clusters**.
2. Select your cluster and click **Replicate data to BigQuery** on the top menu.
3. Follow the wizard:
   * **Region**: Same as your AlloyDB cluster (e.g., `us-central1` or `europe-west1`).
   * **Tables**: Select `disneyland_reviews`, `disneyland_attractions`, and `visitor_movements`.
   * **Write Mode**: **Merge**.
   * **Staleness Limit**: **0 seconds** (real-time).
   * **Destination Dataset**: **disney**.
4. Start the stream.

*(Optional: If configuring logical replication manually on the database)*:

```sql
CREATE PUBLICATION pub_disney FOR TABLE disneyland_reviews, disneyland_attractions, visitor_movements;
ALTER USER postgres WITH REPLICATION;
SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('slot_disney', 'pgoutput');
```

---

### 1.4 Prove the Flow with Data Canvas

1. In the Google Cloud Console, navigate to **BigQuery Studio**.
2. Click the **Data Canvas** tab.
3. Load the replicated `disney.public_disneyland_reviews` table.
4. Click **Visualize** or **Analyze** to generate a quick chart (e.g., a bar chart of the average rating per branch) to prove that the data has replicated successfully.

---

## Challenge 2: Creating the agentic database layer

### 2.1 QueryData Context Set

Create a file named `querydata_disney_context.json` with the following configuration and upload it in the AlloyDB Console under **Context Sets** (named `disney-context`):

```json
{
  "templates": [
    {
      "nlQuery": "Show available attractions in Disneyland Paris",
      "sql": "SELECT name, description FROM public.disneyland_attractions WHERE branch = 'Disneyland_Paris'",
      "intent": "List all attractions for a specific park branch",
      "manifest": "List attractions by branch",
      "parameterized": {
        "parameterized_intent": "Show available attractions in $1",
        "parameterized_sql": "SELECT name, description FROM public.disneyland_attractions WHERE branch = $1"
      }
    },
    {
      "nlQuery": "Find reviews with rating 5 for Space Mountain",
      "sql": "SELECT r.review_id, r.rating, r.review_text FROM public.disneyland_reviews r INNER JOIN public.disneyland_attractions a ON r.branch = a.branch WHERE a.name = 'Space Mountain' AND r.rating = 5",
      "intent": "Get reviews with a specific rating for a named attraction",
      "manifest": "Get reviews by attraction and rating",
      "parameterized": {
        "parameterized_intent": "Find reviews with rating $2 for $1",
        "parameterized_sql": "SELECT r.review_id, r.rating, r.review_text FROM public.disneyland_reviews r INNER JOIN public.disneyland_attractions a ON r.branch = a.branch WHERE a.name = $1 AND r.rating = $2"
      }
    },
    {
      "nlQuery": "Average rating of attractions in California Adventure",
      "sql": "SELECT AVG(rating) FROM public.disneyland_reviews WHERE branch = 'Disneyland_California'",
      "intent": "Calculate the average review rating for a specific branch",
      "manifest": "Average rating by branch",
      "parameterized": {
        "parameterized_intent": "Average rating of attractions in $1",
        "parameterized_sql": "SELECT AVG(rating) FROM public.disneyland_reviews WHERE branch = $1"
      }
    }
  ],
  "facets": [
    {
      "sql_snippet": "r.rating >= 4",
      "intent": "highly rated reviews",
      "manifest": "Filter reviews by a minimum rating threshold",
      "parameterized": {
        "parameterized_intent": "reviews with rating greater than or equal to $1",
        "parameterized_sql_snippet": "r.rating >= $1"
      }
    }
  ],
  "value_searches": [
    {
      "query": "SELECT DISTINCT T.name as value, 'public.disneyland_attractions.name' as columns, 'Attraction Name' as concept_type, (1.0 - ts_rank(to_tsvector('english', T.name), plainto_tsquery('english', $value))) as distance, '{}'::text as context FROM public.disneyland_attractions T WHERE to_tsvector('english', T.name) @@ plainto_tsquery('english', $value)",
      "concept_type": "Attraction Name",
      "description": "Full-text search for attraction names"
    },
    {
      "query": "SELECT DISTINCT T.branch as value, 'public.disneyland_attractions.branch' as columns, 'Branch Name' as concept_type, (1.0 - ts_rank(to_tsvector('english', T.branch), plainto_tsquery('english', $value))) as distance, '{}'::text as context FROM public.disneyland_attractions T WHERE to_tsvector('english', T.branch) @@ plainto_tsquery('english', $value)",
      "concept_type": "Branch Name",
      "description": "Full-text search for park branches"
    }
  ]
}
```

---

### 2.2 Expose AlloyDB AI Operators

#### 1. Install Extensions and Create Indexes for Hybrid Search

```sql
-- Install required extensions
CREATE EXTENSION IF NOT EXISTS alloydb_scann CASCADE;
CREATE EXTENSION IF NOT EXISTS rum CASCADE;
-- Index RUM for Keyword FTS
CREATE INDEX IF NOT EXISTS attractions_tsvector_idx ON disneyland_attractions USING RUM (description_tsvector rum_tsvector_ops);

-- Index ScaNN for Vector Cosine Similarity
CREATE INDEX IF NOT EXISTS attractions_vector_idx ON disneyland_attractions USING scann (embedding cosine) WITH (num_leaves=10);
```

#### 2. Create the Semantic Filtering Function

Define a custom SQL function utilizing `google_ml.if` to filter attractions semantically:

```sql
CREATE OR REPLACE FUNCTION check_attraction_suitability(attraction_name TEXT, suitability_profile TEXT)
RETURNS TABLE(name TEXT, description TEXT) AS $$
  SELECT a.name, a.description 
  FROM disneyland_attractions a
  WHERE a.name = attraction_name
    AND google_ml.if(
      prompt => 'Is this attraction ' || suitability_profile || '? Description: ' || a.description
    );
$$ LANGUAGE SQL;
```

#### 3. Test and Validate the Capabilities

To verify these features in AlloyDB Studio, you can run the following test queries:

**Hybrid Search Test:**

```sql
SET google_ml_integration.enable_preview_ai_functions = true;
SELECT a.name, a.description, search_results.score
FROM disneyland_attractions a
JOIN ai.hybrid_search(
  search_inputs => ARRAY[
      '{
        "data_type": "vector",
        "table_name": "disneyland_attractions",
        "key_column": "attraction_id",
        "vec_column": "embedding",
        "distance_operator": "public.<=>",
        "limit": 5,
        "query_vector": "ai.embedding(''gemini-embedding-001'', ''thrilling space roller coaster'')::vector"
      }'::JSONB,
      '{
        "data_type": "text",
        "table_name": "disneyland_attractions",
        "key_column": "attraction_id",
        "text_column": "description_tsvector",
        "limit": 5,
        "ranking_function": "<=>",
        "query_text_input": "thrilling space roller coaster"
      }'::JSONB
  ],
  id_type => NULL::BIGINT
) AS search_results ON a.attraction_id = search_results.id;
```

**Semantic Filtering Function Test:**

```sql
-- This should return 0 rows (Space Mountain is not safe for pregnant women)
SELECT * FROM check_attraction_suitability('Space Mountain', 'safe for pregnant women');

-- This should return 1 row (it's a small world is suitable for toddlers)
SELECT * FROM check_attraction_suitability('it''s a small world', 'suitable for toddlers');
```

---

## Challenge 3: Sentiment and wait-time forecasting

### 3.1 Automated Sentiment Analysis with BQ Studio Data Science Agent

> [!IMPORTANT]
> **Dependency Note:**
> This task queries the `disneyland_reviews` table in BigQuery, which is replicated from AlloyDB. This requires **Challenge 1** (specifically the Datastream replication in Task 1.3) to be completed first.

#### 1. Create the Remote Model

```sql
CREATE OR REPLACE MODEL `disney.gemini_flash`
  REMOTE WITH CONNECTION `us-central1.conn`
  OPTIONS (ENDPOINT = 'gemini-2.5-flash');
```

#### 2. Classify Sentiments (Sample of 100)

Using the BigQuery Studio Data Science Agent, generate and run the following query:

```sql
CREATE OR REPLACE TABLE `disney.reviews_sentiment_analysis` AS
SELECT 
  review_id, rating, year_month, reviewer_location, review_text, branch,
  ml_generate_text_result AS sentiment
FROM 
  ML.GENERATE_TEXT(
    MODEL `disney.gemini_flash`,
    (
      SELECT *,
      'Classify the sentiment of this review as Positive, Negative, or Neutral. Output ONLY the single word. Review: ' || review_text AS prompt
      FROM `disney.public_disneyland_reviews` 
      LIMIT 100
    ),
    STRUCT(0.0 AS temperature, 10 AS max_output_tokens)
  );
```

---

### 3.2 Time-Series Wait Time Forecasting

#### 1. Load Data

```sql
LOAD DATA OVERWRITE `disney.waiting_times`
FROM FILES (
  format = 'CSV',
  uris = ['gs://ghacks-disneyland-on-gcp/waiting_times.csv']
);
```

#### 2. Train the ARIMA_PLUS Model

```sql
CREATE OR REPLACE MODEL `disney.waiting_time_forecast_model`
  OPTIONS(
    model_type='ARIMA_PLUS',
    time_series_timestamp_col='time_bucket',
    time_series_data_col='avg_wait_time',
    time_series_id_col='attraction',
    data_frequency='AUTO_FREQUENCY'
  ) AS
  SELECT
    TIMESTAMP_SECONDS(1800 * DIV(UNIX_SECONDS(timestamp), 1800)) AS time_bucket, -- 30-min intervals
    attraction,
    AVG(waiting_time) AS avg_wait_time
  FROM `disney.waiting_times`
  GROUP BY 1, 2;
```

#### 3. Generate 24-Hour Forecast (48 intervals of 30 mins)

Join the forecast results with the attractions table to resolve the `attraction_id` for FDW compatibility:

```sql
CREATE OR REPLACE TABLE `disney.forecasted_waiting_times` AS
SELECT
  a.attraction_id,
  f.forecast_timestamp AS forecasted_timestamp,
  f.forecast_value AS predicted_wait_time
FROM
  ML.FORECAST(MODEL `disney.waiting_time_forecast_model`, STRUCT(48 AS horizon, 0.95 AS confidence_level)) f
JOIN
  `disney.public_disneyland_attractions` a ON f.attraction = a.name;
```

---

### 3.3 Ride Clustering (Intensity & Popularity)

#### 1. Categorize Attractions using `AI.CLASSIFY`

```sql
CREATE OR REPLACE TABLE `disney.thrill_class` AS
SELECT
  attraction_id,
  name,
  AI.CLASSIFY(
    description,
    categories => ['easy-peasy', 'thrilling', 'extreme']
  ) AS class
FROM
  `disney.public_disneyland_attractions`;
```

#### 2. Rank Attractions using `AI.SCORE`

```sql
CREATE OR REPLACE TABLE `disney.thrill_score` AS
SELECT
  attraction_id,
  name,
  CAST(AI.SCORE(
    'Score attractions on a thrill level from 1 to 10 based on their description. Description: ' || description
  ) AS INT64) AS rank
FROM
  `disney.public_disneyland_attractions`;
```

---

## Challenge 4: Image classification and brochure RAG

### 4.1 Multimodal Image Classification

#### 1. Create the Object Table

```sql
CREATE OR REPLACE EXTERNAL TABLE `disney.attraction_images`
WITH CONNECTION `us-central1.conn`
OPTIONS (
  object_metadata = 'SIMPLE',
  uris = ['gs://ghacks-disneyland-on-gcp/attraction_parc_photos/*']
);
```

#### 2. Classify Images

```sql
CREATE OR REPLACE TABLE `disney.images_classification` AS
SELECT
  uri,
  ml_generate_text_result AS classification_json
FROM
  ML.GENERATE_TEXT(
    MODEL `disney.gemini_flash`,
    TABLE `disney.attraction_images`,
    STRUCT(
      'Is this image from a Disneyland park? Answer with a JSON object containing keys ''is_disneyland'' (boolean) and ''reason'' (string).' AS prompt
    )
  );
```

---

### 4.2 PDF Brochure Ingestion & RAG Pipeline

#### 1. Create the Object Table for PDFs

```sql
CREATE OR REPLACE EXTERNAL TABLE `disney.brochures_pdf`
WITH CONNECTION `us-central1.conn`
OPTIONS (
  object_metadata = 'SIMPLE',
  uris = ['gs://ghacks-disneyland-on-gcp/disneyland_brochures/*.pdf']
);
```

#### 2. Chunk PDFs using Pre-provided UDF

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

#### 3. Generate Embeddings

```sql
CREATE OR REPLACE MODEL `disney.embedding_model`
  REMOTE WITH CONNECTION `us-central1.conn`
  OPTIONS (ENDPOINT = 'gemini-embedding-001');

CREATE OR REPLACE TABLE disney.brochure_embeddings AS
SELECT *
FROM
  AI.GENERATE_EMBEDDING(
    MODEL `disney.embedding_model`,
    (
      SELECT uri, chunk AS content FROM disney.brochures_chunks
    )
  );
```

---

### 4.3 Vector Search & RAG Validation

Run a single, end-to-end RAG query that finds the relevant chunks using vector search, aggregates them, and passes them to Gemini Flash to answer: *"Where to eat a tex-mex meal buffet-style?"*:

```sql
WITH context_chunks AS (
  SELECT base.content AS chunk
  FROM
    VECTOR_SEARCH(
      TABLE `disney.brochure_embeddings`,
      'embedding',
      (
        SELECT embedding
        FROM
          AI.GENERATE_EMBEDDING(
            MODEL `disney.embedding_model`,
            (SELECT 'Where to eat a tex-mex meal buffet-style?' AS content)
          )
      ),
      top_k => 3
    )
),
assembled_context AS (
  SELECT STRING_AGG(chunk, '\n\n') AS context FROM context_chunks
)
SELECT
  ml_generate_text_result AS grounded_response
FROM
  ML.GENERATE_TEXT(
    MODEL `disney.gemini_flash`,
    (
      SELECT
        'Answer the following question using only the provided context. If the answer cannot be found in the context, say "I don''t know".\n\nQuestion: Where to eat a tex-mex meal buffet-style?\n\nContext:\n' || context AS prompt
      FROM assembled_context
    )
  );
```

---

## Challenge 5: Graph analytics and visitor flow

### 5.1 Build a Property Graph in BigQuery

> [!IMPORTANT]
> **Dependency Note:**
> Creating the Property Graph requires both `public_disneyland_attractions` and `public_visitor_movements` tables to exist in BigQuery. This requires **Challenge 1** (Datastream replication) to be completed first.

Define a property graph over the attractions and movements. Specify explicit keys for the node and edge tables:

```sql
CREATE OR REPLACE PROPERTY GRAPH disney.disney_movement_graph
NODE TABLES (
  disney.public_disneyland_attractions
    KEY (attraction_id)
    LABEL Attraction
)
EDGE TABLES (
  disney.public_visitor_movements
    KEY (visitor_id, timestamp)
    SOURCE KEY (from_attraction_id) REFERENCES public_disneyland_attractions (attraction_id)
    DESTINATION KEY (to_attraction_id) REFERENCES public_disneyland_attractions (attraction_id)
    LABEL Moved
);
```

---

### 5.2 Query the Graph for Patterns

#### 1. Flow Analysis: Top 3 Rides after Space Mountain

Identify where visitors head immediately after riding "Space Mountain":

```sql
SELECT b_name, COUNT(*) AS transition_count
FROM GRAPH_TABLE(
  disney.disney_movement_graph
  MATCH (a:Attraction) -[e:Moved]-> (b:Attraction)
  WHERE a.name = 'Space Mountain'
  RETURN b.name AS b_name
)
GROUP BY b_name
ORDER BY transition_count DESC
LIMIT 3;
```

#### 2. Multi-Hop Journeys: Top 3-Ride Sequences from Space Mountain

Identify the most common sequences of 3 rides starting from "Space Mountain" taken by the same visitor within a 2-hour window:

```sql
SELECT mid_ride, end_ride, COUNT(*) AS journey_count
FROM GRAPH_TABLE(
  disney.disney_movement_graph
  MATCH (a:Attraction) -[e1:Moved]-> (b:Attraction) -[e2:Moved]-> (c:Attraction)
  WHERE a.name = 'Space Mountain'
    AND e1.visitor_id = e2.visitor_id
    AND e1.timestamp < e2.timestamp
    AND TIMESTAMP_DIFF(e2.timestamp, e1.timestamp, MINUTE) <= 120
  RETURN b.name AS mid_ride, c.name AS end_ride
)
GROUP BY mid_ride, end_ride
ORDER BY journey_count DESC
LIMIT 5;
```

---

### 5.3 Generate a Next-Ride Routing Table

Use `GRAPH_TABLE` to query transitions on the property graph `disney_movement_graph`, and generate the top 2 recommendations (ranks 1 and 2) for each attraction using BQ's `QUALIFY` filter:

```sql
CREATE OR REPLACE TABLE disney.graph_recommendations AS
SELECT
  from_id AS attraction_id,
  to_id AS recommended_next_attraction_id,
  ROW_NUMBER() OVER(PARTITION BY from_id ORDER BY transition_count DESC) AS recommendation_rank
FROM (
  SELECT
    from_id,
    to_id,
    COUNT(*) AS transition_count
  FROM GRAPH_TABLE(
    disney.disney_movement_graph
    MATCH (a:Attraction) -[e:Moved]-> (b:Attraction)
    RETURN a.attraction_id AS from_id, b.attraction_id AS to_id
  )
  GROUP BY from_id, to_id
)
QUALIFY recommendation_rank <= 2;
```

---

## Challenge 6: Preparing the Context Layer

This challenge is performed using the BigQuery and Dataplex console interfaces.

### 6.1 Technical Metadata Enrichment

Add descriptions to the columns of the `disneyland_reviews` table in the BigQuery schema editor to help the agent interpret data types and purposes (e.g., describing the vector embeddings or sentiment labels).

### 6.2 Business Glossary Alignment

1. Create a Business Glossary inside Dataplex.
2. Define key terms like "Rollercoaster" or "Premium visitor" (e.g., `Premium visitor: A visitor who left more than 2 reviews`).
3. Link the business terms to the target columns in BigQuery and AlloyDB tables.

### 6.3 Automated profiling & quality

1. Create and execute a Dataplex Data Profile scan on `disney.public_disneyland_reviews`.
2. Define Data Quality rules (e.g., checking that `rating` is between 1 and 5, or that `reviewer_location` is not null) and run a Data Quality scan.

### 6.4 Automated GCS Metadata Generation

1. Go to the BigQuery Metadata Curation tab.
2. Link your GCS object table pointing to brochures.
3. Run the automated tag inference to attach metadata tags to the PDF brochure files.

### 6.5 Lookup Context API

Verify you can query the LookupContext API. An example call:

```bash
curl -X POST \
  -H "Authorization: Bearer \$(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dataplex.googleapis.com/v1/projects/YOUR_PROJECT_ID/locations/YOUR_LOCATION/entryGroups/YOUR_ENTRY_GROUP/entries/YOUR_ENTRY_ID:lookup \
  -d '{"aspectTypes": ["business-context"]}'
```

---

## Challenge 7: Conversational analytics for insights

### 7.1 Initialize Agent

In BigQuery Studio, go to the **Agents** tab, create a new agent named `disney_park_analyst` and connect it to the `disney` dataset.

### 7.2 Configure Knowledge Catalog

* **Synonyms**:
  * "rollercoaster", "thrill ride" -> "Space Mountain", "Big Thunder Mountain"
  * "queue", "line" -> `waiting_time`

### 7.3 Define Golden Queries

Add these pre-approved SQL templates to train the agent's SQL generation:

#### Golden Query 1: Attractions + Wait Time Forecasts

```sql
SELECT 
  a.name AS attraction_name,
  a.branch,
  f.forecasted_timestamp,
  f.predicted_wait_time
FROM 
  `disney.public_disneyland_attractions` a
JOIN 
  `disney.forecasted_waiting_times` f ON a.attraction_id = f.attraction_id
WHERE 
  a.name = 'Space Mountain'
ORDER BY 
  f.forecasted_timestamp ASC;
```

#### Golden Query 2: Graph Routing

```sql
SELECT 
  a1.name AS current_attraction,
  a2.name AS recommended_next_attraction,
  r.recommendation_rank
FROM 
  `disney.graph_recommendations` r
JOIN 
  `disney.public_disneyland_attractions` a1 ON r.attraction_id = a1.attraction_id
JOIN 
  `disney.public_disneyland_attractions` a2 ON r.recommended_next_attraction_id = a2.attraction_id
WHERE 
  a1.name = 'Space Mountain' AND r.recommendation_rank = 1;
```

---

### 7.4 Execute Multi-Silo Prompts

Test the agent with the complex prompt: *"Which attractions have the highest negative sentiment today, and what is the most common path visitors take after leaving them?"*

The agent should resolve this to a SQL query similar to:

```sql
WITH negative_attractions AS (
  SELECT 
    a.attraction_id,
    a.name AS attraction_name,
    COUNT(*) AS negative_count
  FROM 
    `disney.reviews_sentiment_analysis` s
  JOIN 
    `disney.public_disneyland_attractions` a ON s.branch = a.branch
  WHERE 
    s.sentiment = 'Negative'
    AND s.review_text ILIKE '%' || a.name || '%'
  GROUP BY 
    a.attraction_id, a.name
  ORDER BY 
    negative_count DESC
  LIMIT 1
),
next_steps AS (
  SELECT 
    b.name AS next_attraction_name,
    COUNT(*) AS transition_count
  FROM 
    GRAPH_TABLE(
      disney.disney_movement_graph
      MATCH (a:Attraction) -[e:Moved]-> (b:Attraction)
      RETURN a.attraction_id AS from_id, b.name AS name
    )
  WHERE 
    from_id = (SELECT attraction_id FROM negative_attractions)
  GROUP BY 
    next_attraction_name
  ORDER BY 
    transition_count DESC
  LIMIT 1
)
SELECT 
  (SELECT attraction_name FROM negative_attractions) AS worst_attraction,
  (SELECT next_attraction_name FROM next_steps) AS most_common_next_attraction;
```

---

## Challenge 8: From insights to action, syncing BigQuery and AlloyDB

### 8.1 Create Local Analytical Tables in AlloyDB

Run the following DDL in AlloyDB Studio inside the `disney` database:

```sql
CREATE TABLE IF NOT EXISTS public.forecasted_waiting_times (
    attraction_id INT,
    forecasted_timestamp TIMESTAMP,
    predicted_wait_time NUMERIC
);

CREATE TABLE IF NOT EXISTS public.graph_recommendations (
    attraction_id INT,
    recommended_next_attraction_id INT,
    recommendation_rank INT
);
```

### 8.2 Grant IAM Privileges to AlloyDB

Find your AlloyDB cluster's service account:

```bash
gcloud beta alloydb clusters describe <CLUSTER_ID> --region=<REGION> --format="value(serviceAccountEmail)"
```

Grant this service account the following roles in your project:

* **BigQuery Data Viewer** (`roles/bigquery.dataViewer`)
* **BigQuery Read Session User** (`roles/bigquery.readSessionUser`)

### 8.3 Map BigQuery Tables using the AlloyDB Studio Wizard

1. In the Google Cloud Console, navigate to **AlloyDB** -> **Clusters** -> select your cluster -> **AlloyDB Studio**.
2. Connect to the `disney` database.
3. Click on the **Query BigQuery** button (or look for the **External Data** / **BigQuery** integration option in the explorer pane).
4. Follow the wizard to link your BigQuery dataset `disney` and map the tables. Name the foreign tables `bq_forecasted_waiting_times` and `bq_graph_recommendations` to match the sync queries.

*Alternative (Manual DDL):*
If you prefer to run the DDLs manually instead of using the wizard:

```sql
CREATE EXTENSION IF NOT EXISTS bigquery_fdw;
CREATE SERVER bq_disney_server FOREIGN DATA WRAPPER bigquery_fdw;
CREATE USER MAPPING FOR postgres SERVER bq_disney_server;

CREATE FOREIGN TABLE bq_forecasted_waiting_times (
    attraction_id INT,
    forecasted_timestamp TIMESTAMP,
    predicted_wait_time NUMERIC
) SERVER bq_disney_server OPTIONS (
    project '<YOUR_PROJECT_ID>',
    dataset 'disney',
    table 'forecasted_waiting_times'
);

CREATE FOREIGN TABLE bq_graph_recommendations (
    attraction_id INT,
    recommended_next_attraction_id INT,
    recommendation_rank INT
) SERVER bq_disney_server OPTIONS (
    project '<YOUR_PROJECT_ID>',
    dataset 'disney',
    table 'graph_recommendations'
);
```

### 8.4 Sync Data from BigQuery to AlloyDB

Run the following queries in AlloyDB Studio to copy the analytical insights locally:

```sql
-- Sync wait time forecasts
INSERT INTO public.forecasted_waiting_times (attraction_id, forecasted_timestamp, predicted_wait_time)
SELECT attraction_id, forecasted_timestamp, predicted_wait_time 
FROM public.bq_forecasted_waiting_times;

-- Sync graph recommendations
INSERT INTO public.graph_recommendations (attraction_id, recommended_next_attraction_id, recommendation_rank)
SELECT attraction_id, recommended_next_attraction_id, recommendation_rank 
FROM public.bq_graph_recommendations;
```

---

## Challenge 9: Exposing Database Tools via MCP

### 9.1 Configure `tools.yaml`

Create a `tools.yaml` file to configure the **MCP Toolbox** for database access. This file defines five tools mapping to the operational and local analytical tables (not the FDW tables directly):

```yaml
kind: source
name: disney-db
type: alloydb-postgres
project: "[YOUR_PROJECT_ID]"
region: "europe-west1"
cluster: "[YOUR_CLUSTER]"
instance: "[YOUR_INSTANCE]"
ipType: "public"
database: "disney"
user: "postgres"
password: "buildwithgemini2026"
---
# Tool 1: Hybrid Search using ScaNN and Full-Text Search
kind: tool
name: search_attractions_hybrid
type: postgres-sql
source: disney-db
description: "Performs a high-performance hybrid (vector + keyword) search on park attractions based on user interests."
parameters:
  - name: vector_query
    type: string
    description: "Semantic search term (e.g., 'thrilling space roller coaster')"
  - name: text_query
    type: string
    description: "Keyword search term (e.g., 'Space Mountain')"
statement: |
  SET google_ml_integration.enable_preview_ai_functions = true;
  SELECT a.name, a.description, search_results.score
  FROM disneyland_attractions a
  JOIN ai.hybrid_search(
    search_inputs => ARRAY[
        ( '{
          "data_type": "vector",
          "table_name": "disneyland_attractions",
          "key_column": "attraction_id",
          "vec_column": "embedding",
          "distance_operator": "public.<=>",
          "limit": 5,
          "query_vector": "ai.embedding(''gemini-embedding-001'', ''' || $1 || ''')::vector"
        }' )::JSONB,
        ( '{
          "data_type": "text",
          "table_name": "disneyland_attractions",
          "key_column": "attraction_id",
          "text_column": "description_tsvector",
          "limit": 5,
          "ranking_function": "<=>",
          "query_text_input": "' || $2 || '"
        }' )::JSONB
    ],
    id_type => NULL::BIGINT
  ) AS search_results ON a.attraction_id = search_results.id;
---
# Tool 2: Semantic Filtering using AlloyDB AI operator (google_ml.if)
kind: tool
name: check_ride_suitability
type: postgres-sql
source: disney-db
description: "Evaluates if a specific attraction is safe or suitable based on a guest's profile (e.g., 'pregnant women' or 'toddlers')."
parameters:
  - name: attraction_name
    type: string
  - name: suitability_profile
    type: string
statement: |
  SELECT * FROM check_attraction_suitability($1, $2);
---
# Tool 3: Transactional Tool to record new reviews
kind: tool
name: add_attraction_review
type: postgres-sql
source: disney-db
description: "Saves a new customer review for an attraction into the operational database."
parameters:
  - name: rating
    type: integer
  - name: review_text
    type: string
  - name: branch
    type: string
statement: |
  INSERT INTO public.disneyland_reviews (review_id, rating, review_text, branch, year_month)
  VALUES ((SELECT COALESCE(MAX(review_id), 0) + 1 FROM public.disneyland_reviews), $1, $2, $3, TO_CHAR(CURRENT_DATE, 'YYYY-MM'))
  RETURNING review_id, rating, branch;
---
# Tool 4: Analytical Tool checking Wait Time Forecasts (Local Table)
kind: tool
name: get_wait_time_forecast
type: postgres-sql
source: disney-db
description: "Queries the local database to get forecasted wait times for a specific attraction."
parameters:
  - name: attraction_id
    type: integer
statement: |
  SELECT predicted_wait_time 
  FROM public.forecasted_waiting_times 
  WHERE attraction_id = $1 
  ORDER BY forecasted_timestamp ASC LIMIT 1;
---
# Tool 5: Analytical Tool checking Graph Recommendations (Local Table)
kind: tool
name: get_next_ride_recommendation
type: postgres-sql
source: disney-db
description: "Gets next-ride routing recommendations for a guest leaving a specific attraction to avoid queues."
parameters:
  - name: attraction_id
    type: integer
statement: |
  SELECT recommended_next_attraction_id, recommendation_rank 
  FROM public.graph_recommendations 
  WHERE attraction_id = $1;
---
kind: toolset
name: disneyland_operational_tools
tools:
  - search_attractions_hybrid
  - check_ride_suitability
  - add_attraction_review
  - get_wait_time_forecast
  - get_next_ride_recommendation
```

### 9.2 Start the Server

Run the toolbox server:

```bash
./toolbox --config tools.yaml --ui
```

---

## Challenge 10: Building the guest assistant app

### 10.1 Scaffold the Guest Assistant with ADK (`agent.py`)

Scaffold the agent using the Python ADK SDK, loading the tools from the local MCP Toolbox server:

```python
from google.adk.agents import Agent
from toolbox_core import ToolboxSyncClient

# 1. Connect to the MCP server running on port 5000
toolbox = ToolboxSyncClient("http://127.0.0.1:5000")

# 2. Load all tools (operational + analytical)
disney_tools = toolbox.load_toolset('disneyland_operational_tools')

# 3. Define the Guest Guide Agent
visitor_guide = Agent(
    name='disney_guide_agent',
    model="gemini-2.5-flash",
    description='A helpful, friendly guide for Disneyland visitors.',
    instruction="""
    You are a friendly Disneyland Guest Assistant. Your goal is to help visitors plan their day.
    Use the tools at your disposal to:
    - Search for attractions (using hybrid search) or filter them semantically.
    - Check forecasted wait times for attractions.
    - Recommend the next ride to avoid queues based on graph recommendations.
    - Add customer reviews if they want to review a ride.

    Always maintain a magical, helpful, and friendly tone.
    """,
    tools=disney_tools,
)
```

---

### 10.2 Vibe-Coding a Premium Web Application

An example **Streamlit** dashboard/chat application that integrates the ADK agent:

```python
import streamlit as st
import asyncio
from google.genai import types
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from agent import visitor_guide

st.set_page_config(page_title="Disneyland Guest Assistant", page_icon="🪄", layout="wide")

# Styling for a premium "vibe-coded" look
st.markdown("""
    <style>
    .stApp {
        background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
        color: #f8fafc;
    }
    .attraction-card {
        background: rgba(255, 255, 255, 0.05);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 15px;
        padding: 20px;
        margin-bottom: 15px;
        transition: transform 0.2s;
    }
    .attraction-card:hover {
        transform: translateY(-5px);
        border-color: #fbbf24;
    }
    </style>
    """, unsafe_gradient=True)

st.title("🪄 Disneyland Magical Guest Assistant")
st.write("Plan your perfect day at Disneyland with real-time AI guidance, crowd forecasts, and smart routing.")

# Initialize Session State
if "messages" not in st.session_state:
    st.session_state.messages = []
if "runner" not in st.session_state:
    session_service = InMemorySessionService()
    st.session_state.runner = Runner(agent=visitor_guide, app_name="disney_app", session_service=session_service)
    st.session_state.session_id = "guest_session"

# Sidebar or main layout elements
# (e.g. displaying featured attractions, wait times, or map recommendations)

# Chat Interface
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.write(msg["content"])

if prompt := st.chat_input("Ask your magical guide..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.write(prompt)

    async def get_agent_response():
        response_text = ""
        async for event in st.session_state.runner.run_async(
            user_id="visitor",
            session_id=st.session_state.session_id,
            new_message=types.Content(role="user", parts=[types.Part.from_text(text=prompt)])
        ):
            if event.is_final_response():
                response_text = event.content.parts[0].text
        return response_text

    with st.chat_message("assistant"):
        with st.spinner("Consulting the magic mirror..."):
            response = asyncio.run(get_agent_response())
            st.write(response)
            st.session_state.messages.append({"role": "assistant", "content": response})
```

---

### 10.3 Deploy to Google Cloud Run

#### 1. Write the Dockerfile

```dockerfile
FROM python:3.11-slim

# Install system dependencies (e.g., git if needed)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

# Run Streamlit or your web server
CMD ["streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]
```

#### 2. Deploy Command

```bash
gcloud run deploy disneyland-guest-assistant \
  --source . \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated
```
