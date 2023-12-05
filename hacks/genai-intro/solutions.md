# Practical GenAI

## Introduction


## Coach's Guides

- Challenge 1: Automatic triggers
- Challenge 2: First steps into the LLM realm
- Challenge 3: Getting summaries from a document
- Challenge 4: BigQuery &#10084; LLMs
- Challenge 5: Simple semantic search
- Challenge 6: Vector Search for scale

## Challenge 1: Automatic triggers

### Notes & Guidance

Create the buckets, on Cloud Shell the variable `$GOOGLE_CLOUD_PROJECT` contains the project id.

```shell
REGION="us"  # LLMs only available in US, although buckets could be anywhere
BUCKET="gs://$GOOGLE_CLOUD_PROJECT-documents"
STAGING="gs://$GOOGLE_CLOUD_PROJECT-staging"

gsutil mb -l $REGION $BUCKET
gsutil mb -l $REGION $STAGING
```

```shell
TOPIC=documents
gcloud storage buckets notifications create --event-types=OBJECT_FINALIZE --topic=$TOPIC $BUCKET
```

## Challenge 2: First steps into the LLM realm

### Notes & Guidance

```python
def get_prompt_for_title_extraction() -> str:
    return """
        Extract the title from the following text delimited by triple backquotes.

        ```{text}```

        TITLE:
    """
```

And make sure to truncate the text:

```python
response = model.predict(prompt.format(text=text[:10000]))
```

If you want to use gsutil & jq to get the contents, this is the command to use:

```shell
gsutil cat $STAGING/2309.00031.pdf/output-1-to-2.json | jq -r .responses[].fullTextAnnotation.text
```

## Challenge 3: Summarizing a large document using chaining

### Notes & Guidance

See below for the complete code, although there could be slight deviations, there should be two prompts first one using the rolling context and the current page and the second one just the final rolling context. The `extract_summary_from_text` function only needs to be updated for passing the `context`, `page` and `summaries` variables to the `format` function.

```python
def get_prompt_for_summary_1() -> str:
    return """
        Taking the following context delimited by triple backquotes into consideration:

        ```{context}```

        Write a concise summary of the following text delimited by triple backquotes.

        ```{text}```

        CONCISE SUMMARY:
    """


def get_prompt_for_summary_2() -> str:
    return """
        Write a concise summary of the following text delimited by triple backquotes.

        ```{text}```

        SUMMARY:
    """


def extract_summary_from_text(text: str) -> str:
    model = TextGenerationModel.from_pretrained("text-bison@latest")
    rolling_prompt_template = get_prompt_for_summary_1()
    final_prompt_template = get_prompt_for_summary_2()

    if not rolling_prompt_template or not final_prompt_template:
        return ""  # return empty summary for empty prompts

    context = ""
    summaries = ""
    for page in pages(text, 16000):
        prompt = rolling_prompt_template.format(context=context, text=page)  # <-- updated format
        context = model.predict(prompt).text
        summaries += f"\n{context}"
    
    prompt = final_prompt_template.format(text=summaries)  # <-- updated format
    return model.predict(prompt).text   
```

## Challenge 4: BigQuery &#10084; LLMs

### Notes & Guidance

First step is to create the dataset and the table with the right set of columns.

```shell
BQ_DATASET=articles
bq mk --location=$REGION -d $BQ_DATASET
```

```shell
BQ_TABLE=summaries
bq mk -t "$BQ_DATASET.$BQ_TABLE" uri:STRING,name:STRING,title:STRING,summary:STRING
```

Now, we can create the connection to Vertex AI to call the API and make sure that the corresponding service account (that's created after the creation of the connection) has the correct role.

```shell
CONN_ID=conn-llm
bq mk --connection --location=$REGION --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json $REGION.$CONN_ID | jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/aiplatform.user" --condition=None

```

This is the SQL statement to create a link to the LLM.

```sql
CREATE OR REPLACE MODEL
  articles.llm REMOTE
WITH CONNECTION `us.conn-llm` OPTIONS (REMOTE_SERVICE_TYPE = 'CLOUD_AI_LARGE_LANGUAGE_MODEL_V1')
```

Finally, we can use the linked model to make predictions.

```sql
SELECT
  title,
  json_value(ml_generate_text_result['predictions'][0]['content']) AS generated_text
FROM
  ML.GENERATE_TEXT( 
    MODEL `articles.llm`,
    (
      SELECT
        title,
        CONCAT('Multi-choice problem: Define the category of the text?\nCategories:\n- Astrophysics\n- Mathematics\n- Computer Science\n- Quantitative Biology\n- Economics\nText:', summary) AS prompt
      FROM
        `articles.summaries` 
    ),
    STRUCT( 0.2 AS temperature, 64 AS max_output_tokens)
  )
ORDER BY 2
```

## Challenge 5: Simple semantic search

### Notes & Guidance

We don't need to create another connection, we can reuse the existing one. Run the following command to create the model.

```sql
CREATE OR REPLACE MODEL
  articles.embeddings REMOTE
WITH CONNECTION `us.conn-llm` OPTIONS (REMOTE_SERVICE_TYPE = 'CLOUD_AI_TEXT_EMBEDDING_MODEL_V1')
```

Next step is to apply that model to get the embeddings for every summary.

```sql
CREATE OR REPLACE TABLE articles.summary_embeddings AS (
  SELECT uri, title, content as summary, text_embedding
    FROM ML.GENERATE_TEXT_EMBEDDING(
      MODEL articles.embeddings,
      (SELECT uri, title, summary as content FROM articles.summaries),
      STRUCT(TRUE AS flatten_json_output)
    )
)
```

And finally here's the SQL query to get the results, although any variation (temp tables etc. for the query) is also fine. Emphasize that none of the words from the query occurs in the summary, so it's a far better search than a keyword search.

```sql
WITH query_embeddings AS (
  SELECT text_embedding FROM
  ML.GENERATE_TEXT_EMBEDDING(MODEL articles.embeddings,
      (SELECT "Which paper is about characteristics of living organisms in alien worlds?" AS content),
      STRUCT(TRUE AS flatten_json_output)
    )
)
SELECT 
  uri,
  summary,
  title, 
  ML.DISTANCE(
    s.text_embedding,
    q.text_embedding,
    'COSINE') AS distance
FROM
  articles.summary_embeddings s,
  query_embeddings q
ORDER BY
  distance ASC
LIMIT 1;
```

Just keep in mind that participants might miss the fact that you need to generate a single embedding for the prompt first. And although using an intermediate table to hold the query embedding is fine, the inner SELECT is a better approach and could be pointed out if they miss it.

## Challenge 6: Vector Search for scale

### Notes & Guidance

> **Note** Students might get hung up on the JSONL file format as our docs don't do a good job of explaining it. The student guide contains an explanation, so point that out if they missed it.

Create a new bucket to hold the embeddings.

```shell
EMBEDDINGS="gs://$GOOGLE_CLOUD_PROJECT-embeddings"
gsutil mb -l $REGION $EMBEDDINGS
```

Export data in JSON format from BQ, make sure that column names are id & embedding [BQ Exporting Data](https://cloud.google.com/bigquery/docs/exporting-data#sql)

```sql
EXPORT DATA
  OPTIONS( 
    uri='gs://$GOOGLE_CLOUD_PROJECT-embeddings/raw/*.json',
    format='JSON',
    overwrite=TRUE) AS
SELECT
  uri AS id,
  text_embedding AS embedding
FROM
  articles.summary_embeddings
```

In case data is exported in JSON array format instead of JSONL, use the following `jq` command for the conversion.

```shell
jq -c '.[]' exported.json > jsonl-formatted.json
```

Assuming that files were written to the bucket, you can also do something like this:

```shell
for FILE in `gsutil ls $EMBEDDINGS/raw/`
do 
    DST_NAME=`basename $FILE`
    gsutil cat $FILE | jq -c '.[]' | gsutil cp - "$EMBEDDINGS/jsonl/${DST_NAME}"
done
```

Creating the index & the endpoint and the deployment from the console should be trivial. In order to run the query, first get the embeddings for the query:

```sql
EXPORT DATA
  OPTIONS( 
    uri='gs://$GOOGLE_CLOUD_PROJECT-embeddings/query/*.json',
    format='JSON',
    overwrite=TRUE) AS
SELECT text_embedding FROM
  ML.GENERATE_TEXT_EMBEDDING(MODEL articles.embeddings,
      (SELECT "Which paper is about characteristics of living organisms in alien worlds?" AS content),
      STRUCT(TRUE AS flatten_json_output)
    )
```

```shell
TOKEN=`gcloud auth print-access-token`
EP_DOMAIN=`gcloud ai index-endpoints list --region=$REGION --format=json | jq -r '.[0].publicEndpointDomainName'`
EP_PATH=`gcloud ai index-endpoints list --region=$REGION --format=json | jq -r '.[0].name'`
INDEX_ID=`gcloud ai index-endpoints list --region=$REGION --format=json | jq -r '.[0].deployedIndexes[0].id'`
URL="https://$EP_DOMAIN/v1/$EP_PATH:findNeighbors"

FEATURES=`gsutil cat gs://$GOOGLE_CLOUD_PROJECT-embeddings/query/000000000000.json | jq -r '.text_embedding' | tr -d "\n"`

cat <<EOF >query.json
{
  "deployed_index_id": "$INDEX_ID",
  "queries": [{
    "datapoint": {
      "datapoint_id": "0",
      "feature_vector": $FEATURES
    },
    "neighbor_count": 1
  }]
}
EOF

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN"  $URL -d @query.json

```

