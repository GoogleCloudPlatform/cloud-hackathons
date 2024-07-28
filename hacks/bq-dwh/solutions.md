# Modernizing Classic Data Warehousing with BigQuery

## Introduction

## Coach's Guides

- Challenge 1: Loading the source data
- Challenge 2: Staging tables
- Challenge 3: Dataform for automation
- Challenge 4: Dimensional modeling
- Challenge 5: Business Intelligence
- Challenge 6: Notebooks for data scientists
- Challenge 7: Cloud Composer for orchestration

## Challenge 1: Loading the source data

### Notes & Guidance

```shell
REGION=...
BQ_DATASET=raw
bq mk --location=$REGION -d $BQ_DATASET
```

```shell
CONN_ID=conn
bq mk --connection --location=$REGION --connection_type=CLOUD_RESOURCE $CONN_ID

SA_CONN=`bq show --connection --format=json $REGION.$CONN_ID | jq -r .cloudResource.serviceAccountId`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SA_CONN" \
    --role="roles/storage.objectViewer" --condition=None
```

```sql
CREATE OR REPLACE EXTERNAL TABLE raw.person
  WITH CONNECTION `$REGION.$CONN_ID`
  OPTIONS (
    format = "CSV",
    uris = ['gs://${PROJECT_ID}-landing/person/*.csv']
  );
```

## Challenge 2: Staging tables

### Notes & Guidance

```shell
BQ_DATASET=curated
bq mk --location=$REGION -d $BQ_DATASET
```

```sql
CREATE TABLE curated.stg_sales_order_header AS
  SELECT DISTINCT * EXCEPT(comment, order_date, ship_date, due_date), 
    DATE(order_date) AS order_date, 
    DATE(ship_date) AS ship_date,
    DATE(due_date) AS due_date 
  FROM raw.sales_order_header
```

## Challenge 3: Dataform for automation

### Notes & Guidance


## Challenge 4: Dimensional modeling

### Notes & Guidance

```sql
config {
    type: "table",
    schema: "dwh",
    tags: ["fact"]
}
SELECT
  ${keys.surrogate("sod.sales_order_id", "sod.sales_order_detail_id")} AS sales_key,
  ${keys.surrogate("sod.product_id")} AS product_key,
  ${keys.surrogate("customer_id")} AS customer_key,
  ${keys.surrogate("credit_card_id")} AS credit_card_key,
  ${keys.surrogate("ship_to_address_id")} AS ship_address_key,
  ${keys.surrogate("status")} AS order_status_key,
  ${keys.surrogate("order_date")} AS order_date_key,
  sod.sales_order_id,
  sod.sales_order_detail_id,
  sod.unit_price,
  sod.unit_price_discount,
  p.standard_cost as cost_of_goods_sold,
  sod.order_qty as order_quantity,
  sod.order_qty * sod.unit_price AS gross_revenue,
  (sod.order_qty * (sod.unit_price - sod.unit_price_discount)) - (p.standard_cost) as gross_profit
FROM
  ${ref("stg_sales_order_detail")} sod,
  ${ref("stg_sales_order_header")} soh,
  ${ref("stg_product")} p
WHERE
  sod.sales_order_id = soh.sales_order_id AND sod.product_id = p.product_id
```

## Challenge 5: Business Intelligence

### Notes & Guidance

```sql
config {
    type: "table",
    schema: "dwh",
    tags: ["obt"]
}
SELECT
  a.* EXCEPT(address_key),
  d.* EXCEPT(date_key),
  p.* EXCEPT(product_key),
  cc.* EXCEPT(credit_card_key),
  o.* EXCEPT(order_status_key),
  c.* EXCEPT(customer_key),
  f.* EXCEPT(sales_key, customer_key, order_date_key, order_status_key, credit_card_key, ship_address_key, product_key)
FROM
  ${ref("fact_sales")} f,
  ${ref("dim_address")} a,
  ${ref("dim_date")} d,
  ${ref("dim_product")} p,
  ${ref("dim_credit_card")} cc,
  ${ref("dim_order_status")} o,
  ${ref("dim_customer")} c
WHERE
  f.product_key = p.product_key
  AND f.customer_key = c.customer_key
  AND f.credit_card_key = cc.credit_card_key
  AND f.order_status_key = o.order_status_key
  AND f.ship_address_key = a.address_key
  AND f.order_date_key = d.date_key
```

## Challenge 6: Notebooks for data scientists

### Notes & Guidance


## Challenge 7: Cloud Composer for orchestration

### Notes & Guidance


