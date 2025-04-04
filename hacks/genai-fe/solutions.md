# Crash Course in AI: Formula E Edition

## Introduction

Welcome to the coach's guide for the *Crash Course in AI: Formula E Edition* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Getting in gear
- Challenge 2: Formula E-mbed
- Challenge 3: Formula E RAG-ing
- Challenge 4: Telemetry to the rescue!

## Challenge 1: Getting in gear

### Notes & Guidance

Create a GCS bucket and copy sample files to that bucket.

```shell
REGION=... 
BUCKET="gs://$GOOGLE_CLOUD_PROJECT"

gsutil mb -l $REGION $BUCKET
gsutil -m cp -r gs://ghacks-genai-fe/* $BUCKET/ 
```

> **Note** It's okay if particpants only copy the video files for this challenge. The telemetry data will be needed for the final challenge, but it can also be accessed from its source (without copying it to the new bucket).

Create a new BigQuery dataset.

```shell
BQ_DATASET=fe
bq mk --location=$REGION -d $BQ_DATASET
```

Create a connection and give permission to access the bucket. We're providing the CLI command here, but participants will likely use the console for that, which is fine.

> **Note** It's possible to create the *connection* from the Console, but it can be confusing as (per the docs) you need to create a Vertex AI connection, which can be used for BigLake and Object Table entities. The creation of the table needs to happen either through `bq` CLI or the SQL editor.

```shell
CONN_ID=conn
bq mk --connection --location=$REGION --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json $REGION.$CONN_ID | jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/storage.objectUser" --condition=None
```

Now, create the Object Table (replace the variables with literals) (`uris` might be different if the participants only copied the video files without the *cctv* prefix).

```sql
CREATE OR REPLACE EXTERNAL TABLE `$BQ_DATASET.videos`
WITH CONNECTION `$REGION.$CONN_ID`
OPTIONS(
  object_metadata = 'SIMPLE',
  uris = ['gs://$BUCKET/cctv/*.mp4']
)
```

> **Note** If the wildcard is left out, the table will be empty.

In order to get the number of rows, a simple count query would suffice.

```sql
SELECT COUNT(*) FROM `$BQ_DATASET.videos`
```

## Challenge 2: Formula E-mbed

### Notes & Guidance

In principle the same connection can be used to access Vertex AI models as long as it has the correct permissions, so we're now adding the additional permissions (can be done through the Console too). If participants want to use another connection/service account, that's fine too.

```shell
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/aiplatform.user" --condition=None
```

> **Note** It takes a while (1-2 minutes) before the IAM changes are propagated, so if the model creation fails due to lack of permissions even after granting the correct role, just retry after some time.

Now, create the model

```sql
CREATE OR REPLACE MODEL `$BQ_DATASET.multimodal_embedding_model`
REMOTE WITH CONNECTION `$REGION.$CONN_ID`
OPTIONS (
  ENDPOINT = 'multimodalembedding@001'
)
```

Generate the embeddings, note that flattening the JSON output will ensure that the embeddings are in `ARRAY<FLOAT64>` format (rather than JSON which complicates things for the further challenges).

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

> **Note** Without the `interval_seconds` set to 120, there will be multiple embeddings per video segment. There might be cases that this is more desirable, but since we'll be providng the full segment to Gemini in the next challenge (to illustrate the RAG concept), and for the sake simplicity (we seem to have too many false positives with the increased number of embeddings), we're sticking to a single embedding per segment.

In order to get the number rows, participants could check the `Details` tab (when clicked on the table in BigQuery Studio Explorer pane) and `Storage info` section, or run a query.

```sql
SELECT COUNT(*) FROM `$BQ_DATASET.cctv_embeddings`
```

## Challenge 3: Formula E RAG-ing

### Notes & Guidance

The first part is all about getting the correct video segment by doing a semantic search in the embeddings table. There are multiple ways to do that in BigQuery, the below two queries are the most straightforward.

#### Option 1 - Using `top_k`

```sql
SELECT
  base.uri AS uri,
  distance
FROM
  VECTOR_SEARCH( 
    TABLE $BQ_DATASET.cctv_embeddings,
    'ml_generate_embedding_result',
    (
      SELECT ml_generate_embedding_result AS query
      FROM ML.GENERATE_EMBEDDING( 
        MODEL $BQ_DATASET.multimodal_embedding_model,
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
    TABLE $BQ_DATASET.cctv_embeddings,
    'ml_generate_embedding_result',
    (
      SELECT ml_generate_embedding_result AS query
      FROM ML.GENERATE_EMBEDDING( 
        MODEL $BQ_DATASET.multimodal_embedding_model,
        (SELECT "car crash" AS content) 
      )
    )
  )
ORDER BY distance
LIMIT 1
```

> **Note** If you're wondering about the prefix `base` in the example queries above, it's one of the outputs of the `VECTOR_SEARCH` function that contains all columns from the `base_table` (which is the first argument,`$BQ_DATASET.cctv_embeddings` in this case).

#### Prompt for Vertex AI Studio

In the Vertex AI Studio, Free Form, it's possible to add the video segment (`cam_15_07.mp4`) to the prompt through clicking on `Insert Media` and choosing `Import from Cloud Storage` option.

The *Prompt* should be something like the following, (where `[cam_15_07.mp4]` is the video segment inserted into the prompt).

```text
If there's a car crash in the following CCTV footage, please indicate the exact timestamp. 
The corresponding frames already have this information in dd/mm/yyyy * HH:MM:SS on the top left corner.
[cam_15_07.mp4]
```

And the correct response will be: *11/05/2024 15:42:06* (the exact wording might differ).

> **Warning** The footage is from a European race, so the time format in the video is `dd/mm/yyyy` and not `mm/dd/yyyy`.

We've succesfully tested this with `gemini-2.0-flash-001` using the default settings, but participants are free to experiment with different models and settings to get the correct answer.

## Challenge 4: Telemetry to the rescue!

### Notes & Guidance

There are multiple ways of loading the telemetry data, *BigLake* might be an option if the participants have copied the telemetry data to their own bucket. Otherwise, just a simple import with the `bq` CLI or BigQuery Studio should work too. The key thing to notice is that the data is in multiple files, so the uri should reference those through a wildcard.

```shell
bq load \
    --source_format=PARQUET \
    $BQ_DATASET.telemetry \
    gs://ghacks-genai-fe/telemetry/*.parquet # or $BUCKET/telemetry/*.parquet if everything was copied to the bucket
```

See below for an alternative way of loading the data from the SQL Editor:

```sql
LOAD DATA OVERWRITE $BQ_DATASET.telemetry
FROM FILES (
  format = 'PARQUET',
  uris = ['gs://ghacks-genai-fe/telemetry/*']  -- or $BUCKET/telemetry/*.parquet if everything was copied to the bucket
)
```

> **Note** For both options, if the wildcard is left out, the table will be empty.

After loading the data, the notebook needs to be uploaded. You can click on the vertical ellipsis (3 dots) next to *Notebooks* in BigQuery Explorer pane and select *Upload to Notebooks*. Participants can either first download the notebook and upload it or, directly import it through its [URL](https://raw.githubusercontent.com/meken/gcp-genai-fe/refs/heads/main/notebooks/Formula-E-Challenge-4.ipynb). Note that some OS's append a `.txt` extension to the notebook file when downloaded, that needs to be fixed before uploading the file to BigQuery Studio, if they choose for that option.

The following SQL statement should provide the required information to determine the drivers involved in the crash. Please note that the timestamp filtering has been updated for UTC in this solution, if the participants forget about updating the timezone information they will get empty results. The identifier `telemetry_during_crash` after the `%%bigquery` magic is the name of the Python variable where the results of the query will be stored. It's referenced in the final cell (it's a dataframe and will be converted to markdown, appended to the prompt to be designed by the participants).

> **Note** It's probably easier if the participants start experimenting with the SQL in BigQuery Studio (SQL Editor). You can recommend using Gemini from the SQL Editor. Entering the content of the cell where we explain the SQL to be designed, yields pretty impressive results.

```sql
%%bigquery telemetry_during_crash
SELECT
  car_number, driver_name, avg(tv_brake) as brake, avg(tv_speed) as speed
FROM $BQ_DATASET.telemetry
WHERE
  time_utc > "2024-05-11T13:42:05" AND time_utc < "2024-05-11T13:42:06"
GROUP BY
  car_number,
  driver_name
```

> **Note** If the participants use a timestamp that's too early, the averages will be more homogeneous as there's a turn just before the crash where all cars slow down, so it won't be possible to detect the drivers that were involved in the crash.

After determining and running the correct SQL, the following prompt should, in most cases :), give the correct answer.

```text
Given the following telemetry data from Formula E cars for a second, a crash has happened, 
could you please identify the two drivers who were involved in that crash and explain why you think that
```

The response should include only the drivers *Jake Hughes* and *Maximilian Günther*.

If participants don't get the right answer, you can suggest them to play with the prompt and or settings (temperature/model etc.).
