# Formula E: Accident analysis

## Introduction

Welcome to the coach's guide for the *Formula E: Accident analysis* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Loading the data
- Challenge 2: Generating multimodal embeddings
- Challenge 3: Semantic search
- Challenge 4: Basic RAG

## Challenge 1: Loading the data

### Notes & Guidance

Create a GCS bucket and copy sample files to that bucket.

```shell
REGION=... 
BUCKET="gs://$GOOGLE_CLOUD_PROJECT-videos"

gsutil mb -l $REGION $BUCKET
gsutil -m cp {...} $BUCKET/ 
```

Create a new BigQuery dataset

```shell
BQ_DATASET=fe
bq mk --location=$REGION -d $BQ_DATASET
```

Create a connection and give permission to access buckets.

```shell
CONN_ID=conn
bq mk --connection --location=$REGION --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json $REGION.$CONN_ID | jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/storage.objectUser" --condition=None
```

Now, create the object table (replace the variables with literals)

```sql
CREATE OR REPLACE EXTERNAL TABLE `$BQ_DATASET.videos`
WITH CONNECTION `$REGION.$CONN_ID`
OPTIONS(
  object_metadata = 'SIMPLE',
  uris = ['gs://$BUCKET/*.mp4']
)
```

## Challenge 2: Generating multimodal embeddings

### Notes & Guidance

In principle the same connection can be used to access Vertex AI models as long as it has the correct permissions, so we're now adding the additional permissions.

```shell
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/aiplatform.user" --condition=None
```

Now, create the model

```sql
CREATE OR REPLACE MODEL `$BQ_DATASET.multimodal_embedding_model`
REMOTE WITH CONNECTION `$REGION.$CONN_ID`
OPTIONS (
  ENDPOINT = 'multimodalembedding@001'
)
```

Generate the embeddings

```sql
CREATE OR REPLACE TABLE `$BQ_DATASET.cctv_embeddings`
AS
SELECT *
FROM
  ML.GENERATE_EMBEDDING(
    MODEL `$BQ_DATASET.multimodal_embedding_model`,
    TABLE `$BQ_DATASET.videos`,
    STRUCT(
      TRUE AS flatten_json_output,
      120 AS interval_seconds
    )
  )
```

## Challenge 3: Semantic search

### Notes & Guidance

There are multiple ways to get this information, the below two are the most straightforward.

#### Option 1 - Using `top_k`

```sql
SELECT
  base.uri AS uri,
  distance
FROM
  VECTOR_SEARCH( 
    TABLE embeddings.video_embeddings,
    'ml_generate_embedding_result',
    (
      SELECT ml_generate_embedding_result AS query
      FROM ML.GENERATE_EMBEDDING( 
        MODEL embeddings.multimodal_embedding_model,
        (SELECT "car crash" AS content) 
      )
    ),
    top_k => 1
  )
```

#### Option 2 - Using `ORDER BY` and `LIMIT`

```sql
SELECT
  base.uri AS uri,
  distance
FROM
  VECTOR_SEARCH( 
    TABLE embeddings.video_embeddings,
    'ml_generate_embedding_result',
    (
      SELECT ml_generate_embedding_result AS query
      FROM ML.GENERATE_EMBEDDING( 
        MODEL embeddings.multimodal_embedding_model,
        (SELECT "car crash" AS content) 
      )
    )
  )
ORDER BY distance
LIMIT 1
```

## Challenge 4: Basic RAG

### Notes & Guidance

Prompt:

```text
If there's a car crash in the following CCTV footage, please indicate the exact timestamp. 
The corresponding frames already have this information in dd/mm/yyyy * HH:MM:SS on the top left corner.
[cam_15_07.mp4]
```

Response should be: *11/05/2024 15:42:06*
