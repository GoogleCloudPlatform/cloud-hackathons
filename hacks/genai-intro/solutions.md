# Introduction to GenAI

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
REGION="us-central1"
BUCKET="gs://$GOOGLE_CLOUD_PROJECT-documents"
STAGING="gs://$GOOGLE_CLOUD_PROJECT-staging"

gsutil mb -l $REGION $BUCKET
gsutil mb -l $REGION $STAGING
```

```shell
TOPIC=documents
gcloud storage buckets notifications create --event-types=OBJECT_FINALIZE --topic=$TOPIC $BUCKET
```
Since the topic already exists, this command will emit a warning, indicating that the topic is already there, you can safely ignore it.

If the participants miss the `OBJECT_FINALIZE` event type when they configure the notifications, things will fail when files are deleted from the bucket. Also, it's possible to have multiple triggers, so if they've made a mistake, the best course for action would be to delete all notification configurations and recreate it properly (as indicated above).

```shell
gcloud storage buckets notifications delete $BUCKET  # delete all notification configurations
```

## Challenge 2: First steps into the LLM realm

### Notes & Guidance

If students are new to Python, it might be helpful to explain the structure of the code. We've recently added [docstrings](https://peps.python.org/pep-0257/) to each function, make sure that they understand that it is the Pythonic way to document code. They only need to edit the parts where there's a TODO, they shouldn't modify the code in any other way.

Note that these prompts are examples and until we have the `seed` parameter available in the API, we can't have a deterministic prompt that always works, so consider this as a good starting point.

```python
def get_prompt_for_title_extraction() -> str:
    return """
        Extract the title from the following text delimited by triple backquotes. Output only the title. Do not format.

        ```{text}```
    """
```

And make sure to truncate the text (assuming that on average 1 token is 3-4 characters, 5000 characters should be less than 2500 tokens):

```python
prompt = prompt_template.format(text=text[:5000])
```

> **Note**  If participants mention that they could have used models with large context windows to prevent the token limit issue, remind them that longer windows mean more tokens and become more expensive. The title is typically at the beginning of the article, so even when using those models it would make sense to truncate the text.

Some participants might want to use string concatenation (instead of `prompt.format`, something like `prompt + text`) which could work, but that's less elegant and limits things (text can only be put at the end). Since for the next challenge the `format` function is going to be more important, it's good to stick to that for this challenge. The linked documentation for `str.format` is quite helpful.

If you want to use gsutil & jq to get the contents, this is the command to use:

```shell
gsutil cat $STAGING/2309.00031.pdf/output-1-to-2.json | jq -r .responses[].fullTextAnnotation.text
```

But, for non-technical people *or even for technical people* who don't have much `jq` experience, the easier option is to open the PDF file in a viewer and copy paste from there.

And just to re-emphasize, the prompt listed here is just an example, there's a great variety when it comes to the possible valid prompts, so as a coach you should validate the results, which should be (only) the title of the paper as it is in the paper (including any subtitles).

## Challenge 3: Summarizing a large document using chaining

### Notes & Guidance

See below for the complete code, although there could be slight deviations, there should be two prompts first one using the rolling context and the current page and the second one just the final rolling context. The `extract_summary_from_text` function only needs to be updated for passing the `context`, `page` and `summaries` variables to the `format` function.

```python
def get_prompt_for_page_summary_with_context() -> str:
    return """
        Taking the following context delimited by triple backquotes into consideration:

        ```{context}```

        Write a concise summary of the following text delimited by triple backquotes. Output only the summary. Do not format.

        ```{text}```
    """
```

And then make sure to provide the `summary` as context and `page` as text in the `extract_summary_from_text` method.

```python
prompt = rolling_prompt_template.format(context=summary, text=page)
```

The prompts listed here are just examples, there's a great variety when it comes to the possible valid prompts, so as a coach you should validate the results, which should in this case reflect the main points from the summary in _Success Criteria_.

> **Note**  If participants mention that they could have used models with a much larger context window instead of chaining, remind them that these models sometimes have issues extracting relevant bits when given very large contexts (see for example [Lost in the Middle](https://arxiv.org/pdf/2307.03172.pdf) paper) although better prompt engineering sometimes can help. In addition, chaining might still be more memory efficient (processing chunks individually instead of whole documents) and more flexible (by integrating data from diverse information sources & tools within a single workflow) in some cases. Although the expanding context windows of LLMs are gradually reducing the need for this technique, it remains relevant in specific use cases. The optimal approach depends on the specific requirements of the task and the available resources.

## Challenge 4: BigQuery &#10084; LLMs

### Notes & Guidance

First step is to create the dataset and the table with the right set of columns before uncommenting the snippet to write to BQ from Cloud Function.

```shell
BQ_DATASET=articles
bq mk --location=$REGION -d $BQ_DATASET
```

```shell
BQ_TABLE=summaries
bq mk -t "$BQ_DATASET.$BQ_TABLE" uri:STRING,name:STRING,title:STRING,summary:STRING
```

You could download and upload the papers one by one, or use the following to automate that:

```shell
URLS="https://arxiv.org/pdf/2310.00044 https://arxiv.org/pdf/2310.01062 https://arxiv.org/pdf/2310.08243 https://arxiv.org/pdf/2310.09196 https://arxiv.org/pdf/2310.00446 https://arxiv.org/pdf/2310.02081 https://arxiv.org/pdf/2310.00245 https://arxiv.org/pdf/2310.01303 https://arxiv.org/pdf/2310.00067 https://arxiv.org/pd
f/2310.02553"

for URL in $URLS; do
    wget --user-agent="Mozilla" -O "${URL##*/}.pdf" $URL
done

for PDF in *.pdf; do
   gsutil cp $PDF $BUCKET
   sleep 10
done
```

Now, we can create the connection to Vertex AI to call the API and make sure that the corresponding service account (that's created after the creation of the connection) has the correct role.

```shell
CONN_ID=conn-llm
bq mk --connection --location=$REGION --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json $REGION.$CONN_ID | jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/aiplatform.user" --condition=None
```

This is the SQL statement to create a link to the LLM (you need to replace `$REGION` with the correct value).

> **Note** Remind the participants that they can also use Gemini in BigQuery to get assistance on how to do certain things in SQL.

```sql
CREATE OR REPLACE MODEL
  articles.llm REMOTE
WITH CONNECTION `$REGION.conn-llm` OPTIONS (ENDPOINT = 'gemini-1.5-flash-001')
```

Finally, we can use the linked model to make predictions.

```sql
SELECT
  title,
  ml_generate_text_llm_result
FROM
  ML.GENERATE_TEXT( 
    MODEL `articles.llm`,
    (
      SELECT
        title,
        CONCAT('Multi-choice problem: Define the category of the text. Output only the category. Do not format. Categories: Astrophysics, Mathematics, Computer Science,Quantitative Biology, Economics\nText:', summary, '\nCategory:') AS prompt
      FROM
        `articles.summaries` 
    ),
    STRUCT( 0.2 AS temperature, 64 AS max_output_tokens, TRUE AS flatten_json_output)
  )
ORDER BY 2
```

The prompt listed here is just an example, there's a great variety when it comes to the possible valid prompts, so as a coach you should validate the results, which should be the corresponding category from the _Success Criteria_ for each paper.

In order to compare things, the results must be sorted. If the students don't flatten the JSON outputs, they'll have to use the `JSON_VALUE` function on the column that contains the categories, to be able to sort.

## Challenge 5: Simple semantic search

### Notes & Guidance

We don't need to create another connection, we can reuse the existing one. Run the following command to create the model (you need to replace `$REGION` with the correct value).

```sql
CREATE OR REPLACE MODEL
  articles.embeddings REMOTE
WITH CONNECTION `$REGION.conn-llm` OPTIONS (ENDPOINT = 'textembedding-gecko@latest')
```

Next step is to apply that model to get the embeddings for every summary.

```sql
CREATE OR REPLACE TABLE articles.summary_embeddings AS (
  SELECT uri, title, content as summary, ml_generate_embedding_result as text_embedding
    FROM ML.GENERATE_EMBEDDING(
      MODEL articles.embeddings,
      (SELECT uri, title, summary as content FROM articles.summaries),
      STRUCT(TRUE AS flatten_json_output)
    )
)
```

And finally here's the SQL query to get the results, although any variation (temp tables etc. for the query) is also fine. Emphasize that none of the words from the query occurs in the summary, so it's a far better search than a keyword search.

```sql
WITH query_embeddings AS (
  SELECT ml_generate_embedding_result as text_embedding FROM
  ML.GENERATE_EMBEDDING(MODEL articles.embeddings,
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

> **Note** Students might get hung up on the JSON Lines file format as our docs don't do a good job of explaining it. The student guide contains an explanation, so point that out if they missed it.

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

> **Warning**  Vector Search only supports single regions, and expects the `.json` data to be in a bucket in the same region. So if the bucket for the embeddings is in a multi region, participants will have to recreate it in a single region and re-export the embeddings.

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

Creating the index & the endpoint and the deployment from the console should be trivial. In order to run the query, first get the embeddings for the query (you need to replace `$GOOGLE_CLOUD_PROJECT` with the correct value):

```sql
EXPORT DATA
  OPTIONS( 
    uri='gs://$GOOGLE_CLOUD_PROJECT-embeddings/query/*.json',
    format='JSON',
    overwrite=TRUE) AS
SELECT ml_generate_embedding_result as text_embedding FROM
  ML.GENERATE_EMBEDDING(MODEL articles.embeddings,
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

In case students use different methods to generate the text embeddings for the summaries and the query, they should be aware that they should be using the same version of the model.

See below a Python version of the same code:
```python
from google.cloud import aiplatform
from vertexai.language_models import TextEmbeddingModel

# retrieve index endpoint (assuming that there's only one)
index_endpoint_name = aiplatform.MatchingEngineIndexEndpoint.list()[0].name
index_endpoint = aiplatform.MatchingEngineIndexEndpoint(index_endpoint_name=index_endpoint_name)

# embed the query
model = TextEmbeddingModel.from_pretrained("textembedding-gecko@001")  # make sure that the version matches
query = "Which paper is about characteristics of living organisms in alien worlds?"
query_embeddings = model.get_embeddings([query])[0]

# query the index endpoint for the nearest neighbors.
resp = index_endpoint.find_neighbors(
    deployed_index_id=index_endpoint.deployed_indexes[0].id,  # assuming that there's only one deployed index
    queries=[query_embeddings.values],
    num_neighbors=1,
)

print(resp[0][0].id)
```

Note that _Deployed index info_ page on the console gives examples of `curl` as well as `Python` code.