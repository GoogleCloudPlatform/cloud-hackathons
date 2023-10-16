# Practical GenAI

## Introduction


## Coach's Guides

- Challenge 1: Automatic triggers
- Challenge 2: First steps into the LLM realm
- Challenge 3: Getting summaries from a document
- Challenge 4: BigQuery &#10084; LLMs

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

        ```$text```

        TITLE:
    """
```

And make sure to truncate the text:

```python
response = model.predict(prompt.safe_substitute(mapping={"text": text[:10000]}))
```

If you want to use gsutil & jq to get the contents, see:

```shell
gsutil cat $STAGING/2309.00031.pdf/output-1-to-2.json | jq -r .responses[].fullTextAnnotation.text
```

## Challenge 3: Summarizing a large document using chaining

### Notes & Guidance

```python
def get_prompt_for_summary_1() -> str:
    return """
        Taking the following context delimited by triple backquotes into consideration:

        ```$context```

        Write a concise summary of the following text delimited by triple backquotes.

        ```$text```

        CONCISE SUMMARY:
    """


def get_prompt_for_summary_2() -> str:
    return """
        Write a concise summary of the following text delimited by triple backquotes.

        ```$text```

        SUMMARY:
    """


def extract_summary_from_text(text: str) -> str:
    model = TextGenerationModel.from_pretrained("text-bison@latest")
    rolling_prompt_template = string.Template(get_prompt_for_summary_1())
    final_prompt_template = string.Template(get_prompt_for_summary_2())

    context = ""
    summaries = ""
    for page in pages(text, 16000):
        prompt = rolling_prompt_template.safe_substitute(mapping={"context": context, "text": page})
        context = model.predict(prompt).text
        summaries += f"\n{context}"
    
    prompt = final_prompt_template.safe_substitute(mapping={"text": summaries})
    return model.predict(prompt).text   
```

## Challenge 4: BigQuery &#10084; LLMs

### Notes & Guidance

```shell
BQ_DATASET=articles
bq mk --location=$REGION -d $BQ_DATASET
```

```shell
BQ_TABLE=summaries
bq mk -t "$BQ_DATASET.$BQ_TABLE" uri:STRING,name:STRING,title:STRING,summary:STRING
```

```shell
CONN_ID=conn-llm
bq mk --connection --location=$REGION --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json $REGION.$CONN_ID | jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/aiplatform.user" --condition=None
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/bigquery.connectionUser" --condition=None  ## needed?

```

```sql
CREATE OR REPLACE MODEL
articles.llm
REMOTE WITH CONNECTION `us.conn-llm`
OPTIONS (REMOTE_SERVICE_TYPE = 'CLOUD_AI_LARGE_LANGUAGE_MODEL_V1');
```

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