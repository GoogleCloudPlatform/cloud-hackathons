# Open Lakehouse with Apache Iceberg

## Introduction

Many tasks can be accomplished through the Google CLoud UI. The below challenge solutions however, mostly rely on Google Cloud CLI. These commands still give hints on how to accomplish the same through the UI, such as configuration settings needed.

## Coach's Guides

- Challenge 1: The open foundation
- Challenge 2: Data interoperability across Lakehouse
- Challenge 3: Schema evolution and time travel
- Challenge 4: Fine-grained access control
- Challenge 5: Multi-engine polyglot
- Challenge 6: AI with multi-modal analysis

## Challenge 1: The open foundation

### Notes & Guidance

In this challenge the participants are tasked with creating BigQuery tables for `products`, `orders` and `order_items`, which are backed by the Iceberg table format.

This can be accomplished through the following steps:

1. Create a bucket to hold the Iceberg tables
2. Create a connection for BigQuery to use when accessing GCS (along with proper access rights to the associated service account)
3. Create the _sales_ dataset in BigQuery
4. Create Iceberg-format tables in the BigQuery dataset
5. Load the data into these Iceberg tables

### 0. Set variables

To use the code snippets below, please set these environment variables:

```shell
export PROJECT_ID=$(gcloud config get-value project)

# Optional: Add a check to ensure a project is actually set
if [ -z "$PROJECT_ID" ]; then
    echo "Error: No project ID found in gcloud config. Run 'gcloud config set project [ID]' first."
    exit 1
fi

echo "Using Project: $PROJECT_ID"

# The bucket which contains the data to be loaded
RAW_BUCKET_NAME="${PROJECT_ID}-raw"

# The bucket that will hold the Iceberg tables
DATA_BUCKET_NAME="${PROJECT_ID}-sales-data"
LOCATION="us-central1"

# Dataset name
DATASET_ID="sales"

# Table names
ORDERS_TABLE_NAME="orders"
ORDER_ITEMS_TABLE_NAME="order_items"
PRODUCTS_TABLE_NAME="products"

```

### 1. Create a data bucket

```shell
gcloud storage buckets create "gs://${DATA_BUCKET_NAME}" \
    --project="${PROJECT_ID}" \
    --location="${LOCATION}" \
    --public-access-prevention \
    --uniform-bucket-level-access
```

### 2. Setup BigQuery Connection

#### Create a cloud resource connection to access the bucket

```shell
BQ_CONNECTION_NAME="gcs-connection"
bq mk --connection --location="${LOCATION}" --project_id="${PROJECT_ID}" \
    --connection_type=CLOUD_RESOURCE "${BQ_CONNECTION_NAME}" < /dev/null
```

#### Give resource connection service account GCS permissions

```shell
CONNECTION_SA="$(bq show --format=prettyjson --connection "${PROJECT_ID}"."${LOCATION}"."${BQ_CONNECTION_NAME}" | jq -r '.cloudResource.serviceAccountId')"

gcloud storage buckets add-iam-policy-binding gs://"${DATA_BUCKET_NAME}" \
    --member=serviceAccount:"${CONNECTION_SA}" \
    --role=roles/storage.objectAdmin

gcloud storage buckets add-iam-policy-binding gs://"${DATA_BUCKET_NAME}" \
    --member=serviceAccount:"${CONNECTION_SA}" \
    --role=roles/storage.legacyBucketReader
```

### 3. Create dataset in BigQuery

```shell
bq mk -d --location="${LOCATION}" "${PROJECT_ID}:${DATASET_ID}" < /dev/null
```

### 4. Create Iceberg-format tables in BigQuery

You can download the schema of these tables by using the following links. The schemas are in JSON format:

```shell
curl -L -O https://github.com/pbavinck/ghacks-olh-data/releases/download/v1.0.0/orders.json
curl -L -O https://github.com/pbavinck/ghacks-olh-data/releases/download/v1.0.0/order_items.json
curl -L -O https://github.com/pbavinck/ghacks-olh-data/releases/download/v1.0.0/products.json
```

The Iceberg table is created in its own folder within the bucket

```shell
bq --project_id="${PROJECT_ID}" mk \
    --table \
    --file_format=PARQUET \
    --table_format=ICEBERG \
    --connection_id="projects/${PROJECT_ID}/locations/${LOCATION}/connections/${BQ_CONNECTION_NAME}" \
    --storage_uri="gs://${DATA_BUCKET_NAME}/${ORDERS_TABLE_NAME}" \
    --schema=./orders.json \
    "${DATASET_ID}"."${ORDERS_TABLE_NAME}" < /dev/null


bq --project_id="${PROJECT_ID}" mk \
    --table \
    --file_format=PARQUET \
    --table_format=ICEBERG \
    --connection_id="projects/${PROJECT_ID}/locations/${LOCATION}/connections/${BQ_CONNECTION_NAME}" \
    --storage_uri="gs://${DATA_BUCKET_NAME}/${ORDER_ITEMS_TABLE_NAME}" \
    --schema=./order_items.json \
    "${DATASET_ID}"."${ORDER_ITEMS_TABLE_NAME}" < /dev/null

bq --project_id="${PROJECT_ID}" mk \
    --table \
    --file_format=PARQUET \
    --table_format=ICEBERG \
    --connection_id="projects/${PROJECT_ID}/locations/${LOCATION}/connections/${BQ_CONNECTION_NAME}" \
    --storage_uri="gs://${DATA_BUCKET_NAME}/${PRODUCTS_TABLE_NAME}" \
    --schema=./products.json \
    "${DATASET_ID}"."${PRODUCTS_TABLE_NAME}" < /dev/null
```

Iceberg managed tables also support partitioning, clustering and combining clustered and partitioned tables (in Preview). See [here](https://docs.cloud.google.com/bigquery/docs/biglake-iceberg-tables-in-bigquery#use_partitioning) for more information:

Partition flags:

```shell
    --time_partitioning_field=created_at \
    --time_partitioning_type=DAY \
```

Clustering flag:

```shell
    --clustering_fields=CLUSTER_COLUMN_LIST \
```

### 5. Load the data into the Iceberg tables

```shell
bq --project_id="${PROJECT_ID}" load \
    --source_format=PARQUET \
    --parquet_enable_list_inference=true \
    "${DATASET_ID}.${ORDERS_TABLE_NAME}" \
    "gs://${RAW_BUCKET_NAME}/${ORDERS_TABLE_NAME}/${ORDERS_TABLE_NAME}-*.parquet" < /dev/null


bq --project_id="${PROJECT_ID}" load \
    --source_format=PARQUET \
    --parquet_enable_list_inference=true \
    "${DATASET_ID}.${ORDER_ITEMS_TABLE_NAME}" \
    "gs://${RAW_BUCKET_NAME}/${ORDER_ITEMS_TABLE_NAME}/${ORDER_ITEMS_TABLE_NAME}-*.parquet" < /dev/null

bq --project_id="${PROJECT_ID}" load \
    --source_format=PARQUET \
    --parquet_enable_list_inference=true \
    "${DATASET_ID}.${PRODUCTS_TABLE_NAME}" \
    "gs://${RAW_BUCKET_NAME}/${PRODUCTS_TABLE_NAME}/${PRODUCTS_TABLE_NAME}-*.parquet" < /dev/null
```

## Challenge 2: Data interoperability across Lakehouse

### Notes & Guidance

In this challenge the participants will:

1. Create a BigQuery native storage table `users` by directly importing the table and data from a parquet file.
2. Create a SQL statement that joins data from both

### 1. Create Users table

Create a native BigQuery table called `users` from the parquet file.
You should not need to define the table schema since BigQuery can automatically discover it from the parquet file.

```sql
LOAD DATA OVERWRITE marketing.users
FROM FILES (
  format = 'PARQUET',
  uris = ['gs://${RAW_BUCKET_NAME}/${USERS_TABLE_NAME}/${USERS_TABLE_NAME}-*.parquet']);
```

### 2. Create a join SQL statement

The Open Lakehouse enables you to seamlessly access data across Iceberg tables that are stored on GCS as well as BigQuery native table.

Create a single SQL query that calculates for every country the (1) total number of orders (2) total number of ordered items and (3) total sales price.

```sql
SELECT
  users.country,
  COUNT(orders.order_id) AS number_of_order,
  SUM(orders.num_of_item) AS total_order_items,
  SUM(order_items.sale_price) AS total_sales_price
FROM
  `marketing.users` AS users INNER JOIN `sales.orders` AS orders ON users.id = orders.user_id
INNER JOIN
  `sales.order_items` AS order_items ON orders.order_id = order_items.order_id
GROUP BY
  users.country
ORDER BY
  users.country;
```

## Challenge 3: Schema evolution and time travel

### Notes & Guidance

In traditional data lakes, changing a schema (like renaming a column) or updating specific rows often requires rewriting the entire dataset. Apache Iceberg solves this by handling metadata changes efficiently and supporting ACID transactions. Thanks to BigQuery, you can easily perform the changes using BigQuery SQL with its rich syntax.

### 1. Clean up the product category

It seems like the category column in products table has overlap and inconsistent naming conventions. Change the following:

Step 1. The category 'Socks & Hosiery' and 'Socks' are overlapping. Rename all records with 'Socks & Hosiery' to 'Socks'.

```sql
UPDATE `sales.products`
SET
  category = 'Socks'
WHERE
  category = 'Socks & Hosiery';
```

Step 2. The category 'Pants & Capris' and 'Pants' are overlapping. Rename all records with 'Pants & Capris' to 'Pants'.

```sql
UPDATE `sales.products`
SET
  category = 'Pants'
WHERE
  category = 'Pants & Capris';
```

### 2. Add a new column and set its value

The company decides to investigate all orders that were returned. Create a new column in orders table called 'is_verified' (boolean) and set it to False for all returned orders and other records as True.

```sql
ALTER TABLE`sales.orders` ADD COLUMN is_verified BOOLEAN;

UPDATE `sales.orders`
SET is_verified =
  CASE
    WHEN status = 'Returned' THEN FALSE
    ELSE TRUE
  END
WHERE TRUE;
```

Demonstrate the change by listing the number of records grouped per status and is_verified.

```sql
SELECT status, is_verified, count(is_verified)
FROM `sales.orders`
GROUP BY 1, 2
LIMIT 10;
```

### 3. Time travel with Iceberg travel

Accidents happen. Data gets deleted or updated incorrectly. One of the most powerful features of Iceberg is "Time Travel" — the ability to query the table as it existed at a specific point in time using snapshots.

Run a SQL statement to calcualte average retail price of products with category = 'Pants & Capris' (which you have just updated to "Pants") as it was one hour ago.

```sql
SELECT AVG(retail_price) AS average_retail_price
FROM `sales.products`
FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
WHERE category = 'Pants & Capris';
```

### 4. Check the metadata files of the Iceberg tables

Since you just updated the table `products` and `orders`, additional metadata files have been created in the GCS folders of those tables. Have a look and can you identify the metadata changes?

## Challenge 4: Fine-grained access control

### Notes & Guidance

As the Lakehouse grows, so does the responsibility to protect sensitive information. While open standards provide flexibility, we must ensure that PII (Personally Identifiable Information) is only visible to authorized personnel. The Open Lakehouse allows you to apply fine-grained access control, such as Data Masking rules directly on Iceberg tables, ensuring that sensitive data is obscured even when queried through BigQuery.

### 1. Create the taxonomy and policy tags

Create a new taxonomy called "Sensitive Data" in the us-central1 region with 2 data policies:

- Confidential: with default masking rule
- Email: with email masking rule

### 2. Apply the data policy

1. Attach the Confidential data policy to products.retail_price.
2. Attach the Email data policy to users.email.
3. Run a SQl statement to select these columns, are you able to read the data?

### 3. Assign appropriate permission to read the columns

1. Add Masked Reader role to your user, and check if you see the masked value?
2. Add Fine-Grained Reader role to your user, and check if you see the original value?

## Challenge 5: Multi-engine polyglot

### Notes & Guidance

In this challenge the participants are tasked with creating a Notebook in BigQuery, setup a Spark session and run a simple analysis over the Iceberg tables.

### 0. Setup

A Notebook runtime template is already available (`olh-runtime`). Simply connect the new Notebook to a newly created runtime based on this template.

Setting environment variables to use in the Notebook:

```shell
PROJECT_ID = "<PROJECT_ID>"
DATASET_NAME = "sales"
LOCATION = "us-central1"
SUBNET_NAME = f"projects/{PROJECT_ID}/regions/{LOCATION}/subnetworks/olh-net-{LOCATION}"
DATA_BUCKET_NAME = "<SALES_DATA_BUCKET_NAME>"
```

Another important task to carry out is the export of the metadata to GCS/Iceberg. This can be accomplished in the Notebook using these commands:

```sql
%%bigquery --pyformat

EXPORT TABLE METADATA FROM {DATASET_NAME}.products;
EXPORT TABLE METADATA FROM {DATASET_NAME}.orders;
EXPORT TABLE METADATA FROM {DATASET_NAME}.order_items;
```

### 1. Setup Spark Session

The following should not be necessary, but just in case... Authenticate the Notebook using application defaut credentials based on the user using:

```shell
!gcloud auth application-default login --no-launch-browser
```

Create the Spark session:

```python
from google.cloud.dataproc_spark_connect import DataprocSparkSession
from google.cloud.dataproc_v1 import Session
# Create the Managed Service for Apache Spark Serverless session.
session = Session()

# Set the session configuration for Lakehouse Metastore with the Iceberg environment.
catalog="bq_catalog"

session.environment_config.execution_config.subnetwork_uri = f"{SUBNET_NAME}"
session.runtime_config.properties[f"spark.sql.catalog.{catalog}"] = "org.apache.iceberg.spark.SparkCatalog"
session.runtime_config.properties[f"spark.sql.catalog.{catalog}.catalog-impl"] = "org.apache.iceberg.gcp.bigquery.BigQueryMetastoreCatalog"
session.runtime_config.properties[f"spark.sql.catalog.{catalog}.gcp_project"] = f"{PROJECT_ID}"
session.runtime_config.properties[f"spark.sql.catalog.{catalog}.gcp_location"] = f"{LOCATION}"
session.runtime_config.properties[f"spark.sql.catalog.{catalog}.warehouse"] = f"gs://{DATA_BUCKET_NAME}-sales-data"

# session.runtime_config.properties["spark.dynamicAllocation.enabled"] = "false"

# Create the Spark Connect session.
spark = (
   DataprocSparkSession.builder
     .appName("Lakehouse Iceberg Lab")
     .dataprocSessionConfig(session)
     .getOrCreate()
)
spark.conf.set("viewsEnabled","true")

```

### 2. Load data from BigQuery into Spark dataframe

```python
products = spark.read.format('bigquery') \
  .option('table', f'{PROJECT_ID}.{DATASET_NAME}.products') \
  .load()
products.createOrReplaceTempView('products')

orders = spark.read.format('bigquery') \
  .option('table', f'{PROJECT_ID}.{DATASET_NAME}.orders') \
  .load()
orders.createOrReplaceTempView('order_items')

order_items = spark.read.format('bigquery') \
  .option('table', f'{PROJECT_ID}.{DATASET_NAME}.order_items') \
  .load()
order_items.createOrReplaceTempView('order_items')
```

### 2. Run a simple analysis over the Iceberg tables

**Objective**: For each Product Brand, calculate the total revenue, the total profit, and the "Return Rate." This will help identify which brands are the most profitable and which might have quality issues (high returns).

Requirements:

- Only include items where the order status is not 'Cancelled'.
- Revenue: Sum of sale_price from order_items.
- Profit: Sum of (sale_price from order_items minus cost from products).
- Return Rate: The percentage of items where returned_at is not null.
- Filter the final results to only show brands that have generated at least $500 in total revenue.
- Order the results by Profit in descending order.

Solution query:

```python
spark.sql(f"USE `{catalog}`;")

spark.sql(f"USE NAMESPACE`{DATASET_NAME}`;")

results = spark.sql("""SELECT
    p.brand,
    ROUND(SUM(oi.sale_price), 2) AS total_revenue,
    ROUND(SUM(oi.sale_price - p.cost), 2) AS total_profit,
    ROUND(
        (COUNT(CASE WHEN oi.returned_at IS NOT NULL THEN 1 END) * 100.0) / COUNT(oi.id),
        2
    ) AS return_rate_percentage
FROM
    order_items oi
JOIN
    products p ON oi.product_id = p.id
JOIN
    orders o ON oi.order_id = o.order_id
WHERE
    o.status != 'Cancelled'
GROUP BY
    p.brand
HAVING
    total_revenue >= 500
ORDER BY
    total_profit DESC;
""")
results.show()
# Load into Pandas data frame in order to use the visualization cell
results_pdf = results.toPandas()
```

## Challenge 6: AI with multi-modal analysis

### Notes & Guidance

In this challenge the participants are tasked with creating object tables, tables with ObjectRef columns, and using AI.GENERATE in BigQuery.

This can be accomplished through the following steps:

1. Create a bucket to hold the return images
2. Upload the images to this bucket
3. Creating a “returnimages” object table, reusing the previously created GCS connection (with updated permissions)
4. Creating a new `returns_analysis` table with ObjectRef column by joining the returns and returnimages tables
5. Use AI.GENERATE to generate a description of the damaged item

Step 1. and 2. have already done during the setup process of the lab. Participant are only tasked with steps 3. through 5.

### 1\. Create a data bucket

This is already done during setup.

```bash
gcloud storage buckets create "gs://my-bucket-name" \
      --project="my-project-id" \
      --location="us-central1" \
      --public-access-prevention \
      --uniform-bucket-level-access
```

[https://docs.cloud.google.com/storage/docs/creating-buckets\#console](https://docs.cloud.google.com/storage/docs/creating-buckets#console)

### 2\. Upload images

This is already done during setup.

[https://docs.cloud.google.com/storage/docs/uploading-objects\#upload-object-console](https://docs.cloud.google.com/storage/docs/uploading-objects#upload-object-console)

### 3\. Create object table

Give the existing connection’s service account permission to read the bucket: [https://docs.cloud.google.com/storage/docs/access-control/using-iam-permissions\#console](https://docs.cloud.google.com/storage/docs/access-control/using-iam-permissions#console)

The required permission is `Storage Object Viewer`.

```sql
CREATE EXTERNAL TABLE `sales.return_images`
WITH CONNECTION `us-central1.gcs-connection`
OPTIONS(
 object_metadata = 'SIMPLE',
 uris = ['gs://<<BUCKET_NAME>>/*.png']
);
```

### 4\. Create analysis table with ObjectRef

```sql
CREATE OR REPLACE TABLE `sales.product_analysis`
AS
SELECT p.*, ri.ref
FROM `sales.products` p
JOIN `sales.return_images` ri
  ON ri.uri LIKE CONCAT('%/', p.id, '.png');
```

### 5\. Use AI.GENERATE to analyze returns images

```sql
SELECT
  brand, name,
  ref.uri,
  AI.GENERATE(
    ("Give a short description of the damage as shown on the item", OBJ.GET_ACCESS_URL(ref, 'r'))).result AS damage
FROM `sales.product_analysis`;
```
