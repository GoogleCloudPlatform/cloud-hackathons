# Hack to the Future: Data Track

## Introduction

Welcome to the coach's guide for the *Hack to the Future: Data Track* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Migration
- Challenge 2: Federation
- Challenge 3: Automation
- Challenge 4: Generating text and embeddings
- Challenge 5: Semantic search
- Challenge 6: Generating images

## Challenge 1: Migration

### Notes & Guidance

This will be probably done from the UI, but for the sake of simplicity we'll be documenting the CLI commands here. The following command creates a new Spanner instance with the required configuration.

```shell
MYSQL=`gcloud sql instances list --format='value(NAME)'`
REGION=`gcloud sql instances describe $MYSQL --format='value(REGION)'`
SPANNER=onlineboutique

gcloud spanner instances create $SPANNER \
    --description="Cymbal Online Boutique" \
    --config=regional-$REGION \
    --edition=ENTERPRISE \
    --processing-units=100
```

Once the Spanner instances is created, we can create the database.

```shell
gcloud spanner databases create ecom \
    --instance=$SPANNER
```

And before we get started with the Spanner Migration Tool we need to make sure that the source MySQL database is accessible from the Cloud Shell (where we'll install the Spanner Migration Tool).

```shell
CLOUD_SHELL_IP=`curl -s ifconfig.me`

gcloud sql instances patch $MYSQL -q \
  --authorized-networks=$CLOUD_SHELL_IP/32
```

The *Quickstart* section of the Spanner Migration Tool documentation includes the necessary steps, which is basically installing the tool using `apt` and starting its web interface.

```shell
sudo apt-get install google-cloud-cli-spanner-migration-tool
gcloud alpha spanner migrate web
```

Once the tool is installed and running, you can access it through port 8080 (Using the Cloud Shell Preview button).

For the source database configuration:

- Use the public IP of the MySQL instance as the hostname
- The port will be the default `3306`.
- The username is `migration-admin` and the password was provided by Qwiklab (or Terraform)
- The Spanner Dialect should be the default *Google Standard SQL Dialect*.

Also you need to click the pencil icon at the top right of the screen and fill in the Spanner details (project id and Spanner instance id) and click on *Connect*.

On the *Configure Schema* page you don't need to alter anything, just click on the *Prepare Migration* link at the top middle of the page to configure a few more details:

- *Migration Type*: POC Migration
- *Spanner Database*: `ecom` (which we just created)

Once you're ready, click on the *Migrate* button to start the migration, which will take roughly 15 minutes.

Alternatively the following CLI command would do the same:

```shell
MYSQL_IP=`gcloud sql instances describe $MYSQL \
  --format='value(ipAddresses[0].ipAddress)'`
MYSQL_USR="migration-admin"
MYSQL_PWD=... # should be provided by coach

gcloud alpha spanner migrate schema-and-data \
    --source=mysql \
    --source-profile="host=$MYSQL_IP,port=3306,user=$MYSQL_USR,dbName=ecom,password=$MYSQL_PWD" \
    --target-profile="project=$GOOGLE_CLOUD_PROJECT,instance=$SPANNER,dbName=ecom"
```

In order to verify the contents, the following SQL in the Spanner Studio can be used.

```sql
SELECT 'distribution_centers' AS table_name, COUNT(*) AS row_count FROM distribution_centers UNION ALL
SELECT 'products', COUNT(*) FROM products UNION ALL
SELECT 'users', COUNT(*) FROM users UNION ALL
SELECT 'events', COUNT(*) FROM events UNION ALL
SELECT 'inventory_items', COUNT(*) FROM inventory_items UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items ORDER BY table_name;
```

## Challenge 2: Federation

### Notes & Guidance

All of the following can be done through the Console, but see below the CLI equivalents for the sake of simplicity. Create the BigQuery dataset in the required region.

```shell
BQ_DATASET="cymbal_analytics"

bq  --location=us mk --dataset $BQ_DATASET
```

Now we can create the federated dataset.

```shell
bq  --location=us mk --dataset \
    --external_source google-cloudspanner:///projects/$GOOGLE_CLOUD_PROJECT/instances/$SPANNER/databases/ecom \
    spanner_external_dataset
```

Copying the tables can be done through a CTAS statement.

> **Note** The snippets in this guide use the CLI for executing the SQL for BigQuery from the Cloud Shell. But we expect the participants to use the BigQuery Studio to enter the SQL statements (everything between the [heredoc](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Here-Documents) delimiters `EOF`), in which case the variables should be replaced by their literal values.

```shell
bq query --use_legacy_sql=false <<EOF
CREATE TABLE $BQ_DATASET.distribution_centers AS SELECT * FROM spanner_external_dataset.distribution_centers; 
CREATE TABLE $BQ_DATASET.events AS SELECT * FROM spanner_external_dataset.events; 
CREATE TABLE $BQ_DATASET.inventory_items AS SELECT * FROM spanner_external_dataset.inventory_items; 
CREATE TABLE $BQ_DATASET.order_items AS SELECT * FROM spanner_external_dataset.order_items; 
CREATE TABLE $BQ_DATASET.orders AS SELECT * FROM spanner_external_dataset.orders; 
CREATE TABLE $BQ_DATASET.products AS SELECT * FROM spanner_external_dataset.products; 
CREATE TABLE $BQ_DATASET.users AS SELECT * FROM spanner_external_dataset.users;
EOF
```

Once the tables have been created, the contents can be verified similarly to the previous challenge.

```shell
bq query --use_legacy_sql=false <<EOF
SELECT 'distribution_centers' AS table_name, COUNT(*) AS row_count FROM $BQ_DATASET.distribution_centers UNION ALL
SELECT 'products', COUNT(*) FROM $BQ_DATASET.products UNION ALL
SELECT 'users', COUNT(*) FROM $BQ_DATASET.users UNION ALL
SELECT 'events', COUNT(*) FROM $BQ_DATASET.events UNION ALL
SELECT 'inventory_items', COUNT(*) FROM $BQ_DATASET.inventory_items UNION ALL
SELECT 'orders', COUNT(*) FROM $BQ_DATASET.orders UNION ALL
SELECT 'order_items', COUNT(*) FROM $BQ_DATASET.order_items ORDER BY table_name;
EOF
```

## Challenge 3: Automation

### Notes & Guidance

Installing the tool should be rather trivial.

```shell
curl -L https://raw.githubusercontent.com/GoogleCloudPlatform/application-integration-management-toolkit/main/downloadLatest.sh | sh -
export PATH=$PATH:$HOME/.integrationcli/bin
```

Once it's installed, clone/download/unzip the pipeline definition.

```shell
wget -O httf-data-app-int.zip https://github.com/meken/gcp-httf-data-app-int/archive/refs/heads/main.zip
unzip httf-data-app-int.zip
```

And publish it.

> **Note**  
> When the following command runs, it first emits an error indicating that the connection is not found. This error can be ignored as the configuration also contains connection information that is used to create that connection.

```shell
cd gcp-httf-data-app-int-main
integrationcli integrations apply \
    -p $GOOGLE_CLOUD_PROJECT \
    -r $REGION \
    -f cleanup-integration \
    -e dev \
    --default-token \
    --grant-permission \
    --wait
```

Running the pipeline from the UI should be straight-forward, just make sure to stick to the default parameters. See below for the alternative CLI command to run it.

```shell
URL="https://integrations.googleapis.com/v1/projects/$GOOGLE_CLOUD_PROJECT/locations/$REGION/integrations/cleanup-spanner:execute"
TOKEN=`gcloud auth print-access-token`
curl \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data '{"triggerId": "api_trigger/delete_order_items"}' \
    $URL
```

Verifying whether the rows have been deleted can be done using the following SQL in Spanner Studio. It should return `0` for both `orders` and `order_items` tables.

```sql
SELECT  * FROM (
  SELECT
    'order_items' AS table_name,
    COUNT(id) AS num_rows_to_delete
  FROM
    order_items
  WHERE
    created_at < '2024-01-31'
  UNION ALL
  SELECT
    'orders' AS table_name,
    COUNT(order_id) AS num_rows_to_delete
  FROM
    orders
  WHERE
    created_at < '2024-01-31' 
)
ORDER BY
  table_name;
```

## Challenge 4: Generating text and embeddings

### Notes & Guidance

Let's start with adding the columns to the `products` table in the BigQuery dataset.

```shell
bq query --use_legacy_sql=false <<EOF
ALTER TABLE $BQ_DATASET.products
    ADD COLUMN product_description STRING,
    ADD COLUMN product_description_embeddings ARRAY<FLOAT64>;
EOF
```

Now, before we can create and use models we'll need to create a connection and set up the required roles for the underlying service account.

```shell
CONN_ID=vertex_ai
bq mk --connection --location=us \
    --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json us.$CONN_ID | \
    jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:$SA_CONN" \
    --role="roles/aiplatform.user" --condition=None
```

> **Note**  
> It might take up to a minute or two to propagate the IAM changes, so if after granting permissions you still get *Permission Denied* errors, try it a few more times.

Now we can create the models (the versions in the endpoints are the latest versions at the time of writing this, you can use whatever version is the latest if those are obsolete).

> **Note**  
> If you're copying the SQL statements to BigQuery Studio, make sure to remove the backslashes in front of the backticks. Those backslashes are needed to escape the backticks when you run the statements from the CLI.

```shell
bq query --use_legacy_sql=false <<EOF
CREATE OR REPLACE MODEL $BQ_DATASET.text_embeddings
REMOTE WITH CONNECTION \`us.$CONN_ID\`
OPTIONS (ENDPOINT = 'text-embedding-005');

CREATE OR REPLACE MODEL $BQ_DATASET.text_generation
REMOTE WITH CONNECTION \`us.$CONN_ID\`
OPTIONS (ENDPOINT = 'gemini-2.0-flash');
EOF
```

Generating the product description will involve designing a prompt, which is an art by itself. It's sufficient to ensure that the prompt is common sense and includes the columns mentioned in the instructions.

```shell
bq query --use_legacy_sql=false <<EOF
UPDATE $BQ_DATASET.products AS t1
SET product_description = t2.ml_generate_text_llm_result
FROM ML.GENERATE_TEXT(
    MODEL $BQ_DATASET.text_generation,
    (
        SELECT id,
        CONCAT(
          'You work for an online boutique as a product marketing and retail strategy specialist, and you are writing product descriptions that will improve discoverability and boost sales for items in your product catalog. \n\n', 
          'Write a creative, eye-catching product description for the following product: \n',
          '- Name: ', name, ' \n',
          '- Brand: ', brand, ' \n',
          '- Category: ', category, ' \n',
          '- Department: ', department, ' \n',
          '- Price: ', retail_price, ' \n\n',
          'Limit your response to 250 words or less.'
        ) AS prompt
        FROM $BQ_DATASET.products p
        WHERE p.product_description IS NULL
        LIMIT 100 
    ),
    STRUCT(
      TRUE AS flatten_json_output,
      0.8 AS temperature,
      1024 AS max_output_tokens
    )
) AS t2
WHERE t1.id = t2.id;
EOF
```

Run the following command to generate the embeddings for the descriptions.

```shell
bq query --use_legacy_sql=false <<EOF
UPDATE $BQ_DATASET.products AS t1
SET product_description_embeddings = t2.ml_generate_embedding_result
FROM ML.GENERATE_EMBEDDING(
    MODEL $BQ_DATASET.text_embeddings,
    (
      SELECT id, product_description as content
      FROM $BQ_DATASET.products
      WHERE product_description IS NOT NULL
      LIMIT 100 
    ),
    STRUCT(
      TRUE AS flatten_json_output
    )
) AS t2
WHERE t1.id = t2.id;
EOF
```

Verifying things could be done by doing a basic count on the number of non-empty rows, which should be greater than or equal to 100 for both columns.

```shell
bq query --use_legacy_sql=false <<EOF
SELECT COUNT(*) FROM $BQ_DATASET.products WHERE product_description IS NOT NULL UNION ALL
SELECT COUNT(*) FROM $BQ_DATASET.products WHERE ARRAY_LENGTH(product_description_embeddings) > 0;
EOF
```

## Challenge 5: Semantic search

### Notes & Guidance

You can run the workflow from the UI, but again for the sake of simplicity we'll be using CLI commands. Keep in mind that the parameter `embeddings_model_name` is how the embeddings model has been named in BigQuery (without the dataset name).

```shell
gcloud workflows run prep-semantic-search \
  --location=$REGION \
  --data='{"embeddings_model_name": "text_embeddings"}'
```

Next task is to do the reverse ETL. Before we copy the data we need to create the corresponding columns in the products table in Spanner.

```sql
ALTER TABLE products ADD COLUMN product_description STRING(MAX);
ALTER TABLE products ADD COLUMN product_description_embeddings ARRAY<FLOAT64>;
```

Now we can export the data (note that this requires a BigQuery Enterprise Edition configuration, but the setup scripts should have taken care of that).

```shell
bq query --use_legacy_sql=false <<EOF
EXPORT DATA OPTIONS (
    uri='https://spanner.googleapis.com/projects/$GOOGLE_CLOUD_PROJECT/instances/onlineboutique/databases/ecom',
    format='CLOUD_SPANNER',
    spanner_options='{"table": "products"}'
  )
  AS SELECT * FROM $BQ_DATASET.products;
EOF
```

This should replicate the data in Spanner. Let's create the model in Spanner (make sure that the model versions match with what was chosen in BigQuery, and replace the variables with their literal values).

```sql
CREATE MODEL IF NOT EXISTS text_embeddings 
    INPUT( 
        content STRING(MAX),  
    ) OUTPUT(  
        embeddings STRUCT<statistics STRUCT<truncated BOOL, token_count FLOAT64>, values ARRAY<FLOAT64>>  
    ) REMOTE OPTIONS (
        endpoint = '//aiplatform.googleapis.com/projects/$GOOGLE_CLOUD_PROJECT/locations/$REGION/publishers/google/models/text-embedding-005'
    )
```

With the model you can then do searches using natural language.

```sql
WITH embedding AS (
    SELECT embeddings.values
    FROM ML.PREDICT(
        MODEL text_embeddings, 
        (
            SELECT 'Luxury items for women' as content
        )
    )
) 
SELECT COSINE_DISTANCE(
    product_description_embeddings, 
    embedding.values
  ) as dist,
  id,
  name, 
  department
FROM products, embedding
ORDER BY dist
LIMIT 5;
```

## Challenge 6: Generating images

### Notes & Guidance

Create the bucket to hold the images.

```shell
BUCKET="gs://$GOOGLE_CLOUD_PROJECT-images"
gsutil mb -l $REGION $BUCKET
```

Add the additional columns to BigQuery.

```shell
bq query --use_legacy_sql=false <<EOF
ALTER TABLE $BQ_DATASET.products
    ADD COLUMN image_uri STRING,
    ADD COLUMN image_url STRING;
EOF
```

If the Python code is not available download/clone/unzip it.

```shell
wget -O httf-data-kfp.zip https://github.com/meken/gcp-httf-data-kfp/archive/refs/heads/main.zip
unzip httf-data-kfp.zip
```

Now you can install the dependencies and run it (you could optionally create and activate a virtual environment first).

```shell
cd gcp-httf-data-kfp-main
pip install -r requirements.txt
python3 genai-imagen-pipeline.py
```

Easiest option to make the generated `yaml` file to Vertex AI Pipelines is to upload it to the newly created bucket.

```shell
gsutil cp image-generation-pipeline.yaml $BUCKET
```

Now you can pick the `yaml` file from the UI, and provide the following parameters (replace the variables with their values).

| Parameter | Value |
| ---       | --- |
| dataset_id | `$BQ_DATASET` |
| location | `$REGION` |
| output_bucket | `$BUCKET/product_images` |
| project_id | `$GOOGLE_CLOUD_PROJECT` |
| table_id | products |
| record_limit | 1 |
| token_limit | 480 |

If you want to do this from the command line, you can use the following.

```shell
cat <<EOF > submit.py
from google.cloud import aiplatform
job = aiplatform.PipelineJob(
    display_name="generate-product-images",
    template_path="image-generation-pipeline.yaml",
    pipeline_root="$BUCKET/pipelines",
    project="$GOOGLE_CLOUD_PROJECT",
    location="$REGION",
    parameter_values={
        "project_id": "$GOOGLE_CLOUD_PROJECT",
        "location": "$REGION",
        "dataset_id": "$BQ_DATASET",
        "table_id": "products",
        "output_bucket": "$BUCKET"
    },
    enable_caching=False
)
job.submit()
EOF
python3 submit.py

```

> **Note** Running this to completion will take >30 minutes, however first results should be visible in the output bucket after 5 minutes if everything goes well.
