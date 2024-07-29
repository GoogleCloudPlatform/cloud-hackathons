# Modernizing Classic Data Warehousing with BigQuery

## Introduction

In this hack we'll implement a classic data warehouse using modern tools, such as Cloud Storage, BigQuery, Dataform and Looker Studio. We'll start with a modified version of the well known AdventureWorks OLTP database, and we'll implement a dimensional model to report on business questions using a BI visualization tool.

![Architecture of the solution](./images/bq-dwh-arch.png)

In our scenario, the data has already been copied from the database to a landing bucket in Cloud Storage as CSV files. In the first challenge we'll create BigLake tables in BigQuery to make the data accessible in BigQuery. In the second challenge we'll apply some basic transformations to load the data in staging tables. In the third challenge we're going to automate this process using Dataform. The fourth challenge is all about creating the dimensional model and the fact table. And in the fifth challenge we'll introduce the OBT concept and use Looker Studio to build reports.The 6th challenge is for the data scientists, using interactive notebooks to analyze data and finally we'll automate and orchestrate the whole process by tapping into Cloud Composer.

TODO Decide on the landing bucket content

## Learning Objectives

This hack will help you explore the following tasks:

- BigQuery as a classic Data warehouse
- BigLake for accesing data in an object store and applying table semantics
- Dataform for automating data transformation steps
- Dimensional modeling
- Looker Studio for visualizing data
- Cloud Composer for orchestration

## Challenges

- Challenge 1: Loading the source data
- Challenge 2: Staging tables
- Challenge 3: Dataform for automation
- Challenge 4: Dimensional modeling
- Challenge 5: Business Intelligence
- Challenge 6: Notebooks for data scientists
- Challenge 7: Cloud Composer for orchestration

## Prerequisites

- Basic knowledge of GCP
- Basic knowledge of Python
- Basic knowledge of SQL
- Access to a GCP environment

## Contributors

- Murat Eken

## Challenge 1: Loading the source data

### Introduction 

This first step is all about getting started with the source data. Typically data is copied periodically from operational data stores, such as OLTP databases, CRM systems etc. to an analytics data platform. Many different methods exist for getting that data, either through pushes (change data capture streams, files being generated and forwarded), or pulls (running a query periodically to get the data), but for now we'll ignore all that and assume that somehow data has been collected from the source systems and put into Google Cloud Storage.

> Note For the sake of simplicity, we'll implement full loads. In real world applications with larger datasets you might want to consider incremental loads.

### Description

We have already copied the data from the underlying database to a specific Cloud Storage bucket. Go ahead and find that bucket, and have a look at its contents. Create a new BigQuery dataset called `raw` in the same region as that storage bucket, and create BigLake tables for the following entities, `person`, `sales_order_header` and `sales_order_detail`. You can ignore the other files for now.

### Success Criteria

- There is a new BigQuery dataset `raw` in the same region as the landing bucket.
- There are 3 BigLake tables with content in the `raw` dataset: `person`, `sales_order_header` and `sales_order_detail`.

### Learning Resources

- [Creating BigQuery datasets](https://cloud.google.com/bigquery/docs/datasets#console)
- [Introduction to BigLake tables](https://cloud.google.com/bigquery/docs/biglake-intro)
- [Creating BigLake tables](https://cloud.google.com/bigquery/docs/create-cloud-storage-table-biglake)

## Challenge 2: Staging tables

### Introduction

Before we create our dimensional model we'll first do some cleanup and filter columns. There's a plethora of different approaches here, and different modeling techniques, but we'll keep things simple again. Our source data is already relational and has the correct structure (3NF), we'll stick that data model and only do some minimal cleansing.

### Description

Some of the tables have duplicate records and problematic columns that we'd like to remove. Create a new BigQuery dataset called `curated` and derive/create a new table for each BigLake table created in the previous challenge. Name the new tables by prefixing them with `stg_` and remove any **duplicate** records as well as any columns with only `null` values. Make sure that the columns `order_date`, `due_date` and `ship_date` have the data type `DATE`.

### Success Criteria

- There is a new BigQuery dataset `curated` in the same region as the other datasets.
- There are 3 BigQuery tables with content in the `curated` dataset: `stg_person`, `stg_sales_order_header` and `stg_sales_order_detail` with no duplicate records and no columns with only `null` values.

### Learning Resources

- [Creating BigQuery tables from a query result](https://cloud.google.com/bigquery/docs/tables#create_a_table_from_a_query_result)

### Tips

- Data Profile (with 100% sampling) and/or BigQuery Data Preparation can help you find `null` columns.
- [EXCEPT](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#select_except) is useful when you want to discard a few columns when selecting all columns from a table.

TODO Prepare the data to contain duplicate rows

## Challenge 3: Dataform for automation

### Introduction

Although we've only dealt with 3 tables so far, our data model has many more tables, and we have to perform multiple SQL operations to process the data. Doing this manually is error-prone and labor intensive. Wouldn't it be great if we could automate this by developing and operationalizing scalable data transformation pipelines in BigQuery using SQL? Enter Dataform 🙂

### Description

Create a new Dataform _Repository_, update its settings to use the `BQ DWH Dataform Service Account`, _override_ workspace compilation settings to ensure that _Project ID_ points to your project. Then link it to [this Github repository](TBD), using HTTPS as the protocol and the provided `git-secret` as the secret to connect.

After configuring the Dataform repository, create a new _Development Workspace_, solve any errors and execute the pipeline with the tag `staging`. Once you have a successful run, commit your changes.

> **Note** The provided `git-secret` has a dummy value, it'll be ignored when you pull from the repository. When you link a Git repository, Dataform clones that repository _locally_ (in your Dataform Development Workspace) and you can commit your changes to your local copy. Normally you'd be able to push those changes to the remote (either main or a different branch), but since the provided secret doesn't have any write permissions, you won't be able to that for this exercise.

TODO include errors?
TODO prepare BQ DWH Dataform Service Account

### Success Criteria

- There's a successful execution of the provided Dataform pipeline for the `staging` tables.
- The following 12 tables have been created in the `curated` dataset: 
  - `stg_address`
  - `stg_country_region`
  - `stg_credit_card`
  - `stg_customer`
  - `stg_order_status`
  - `stg_person`
  - `stg_product`
  - `stg_product_category`
  - `stg_product_subcategory`
  - `stg_sales_order_detail`
  - `stg_sales_order_header`
  - `stg_state_province`
  - `stg_store`

### Learning Resources

- [Creating a Dataform repository](https://cloud.google.com/dataform/docs/create-repository)
- [Connecting to a Git repository](https://cloud.google.com/dataform/docs/connect-repository)
- [Configuring Dataform workflow settings](https://cloud.google.com/dataform/docs/configure-dataform)
- [Creating a development workspace](https://cloud.google.com/dataform/docs/create-workspace)

## Challenge 4: Dimensional modeling

### Introduction

Dimensional modeling is a data warehousing technique that organizes data into fact tables containing measurements, and dimension tables, which provide context for those measurements. This structure makes data analysis efficient and intuitive, allowing users to easily understand and query data related to specific business events

### Description

We're going to create a star schema by extracting dimension tables and a _fact_ table from the staging tables that have been created in the previous challenge. First you need to create another dataset and call it `dwh`.

We have already provided the code for the dimension tables, all you need to do is create a new `fact_sales.sqlx` file, configure the tags to have `fact` and create a fact table in with the following columns:

- `sales_key`  (surrogate key built out of `sales_order_id` and `sales_order_detail_id`)
- `product_key`
- `customer_key`
- `credit_card_key`
- `ship_address_key`
- `order_status_key`
- `order_date_key`
- `unit_price`
- `unit_price_discount`
- `cost_of_goods_sold` (retrieved from `stg_products` table, `standard_cost` column)
- `order_quantity`
- `gross_revenue` (calculated by multiplying `unit_price` with `order_quantity`)
- `gross_profit` (calculated by subtracting discounts and costs of goods sold from `gross_revenue`)

Once the configuration is complete run the Dataform pipeline with the tag `fact`.

### Success Criteria

- There is a new BigQuery dataset `dwh` in the same region as the other datasets.
- There's a successful execution of the provided Dataform pipeline for the `fact` tag.
- There are dimension tables and a new fact table, `fact_sales` in the `dwh` dataset, with the columns as specified above.

### Learning Resources

- [Creating tables with Dataform](https://cloud.google.com/dataform/docs/define-table)

## Challenge 5: Business Intelligence

### Introduction

Business intelligence (BI) in data warehousing involves using tools and techniques to analyze the massive amounts of data stored in a data warehouse to extract meaningful insights, identify trends, and support better business decision-making. This essentially translates raw data into actionable information for strategic planning and operational efficiency. We can do that by running SQL queries, but also create dashboards using a visualization tool, such as Looker or Looker Studio.

### Description

We're going to create a new report in Looker Studio. Since we're keeping things simple and Looker Studio works better with an _OBT_ (one big table), we'll create that as a first step.

Create in the `dwh` dataset the new table `obt_sales` by joining all of the dimension tables with the fact table using Dataform. Once the table is created through Dataform, create a Looker Studo report with the following:

- Scorecards for `gros_revenue` and `gross_profit` with human readable numbers.
- Donut chart for `gross_revenue` broken down by product categories.
- Map chart showing `gross_profit` for every city.
- A line chart showing `gros_revenue` and `gross_profit` per quarter (e.g. Y2021Q3).

### Success Criteria

- There's a new table `obt_sales` in the `dwh` dataset that joins the dimension tables with the fact table as a result of running the Dataform pipeline with the tag `obt`.
- There's a new Looker Studio report with the abovementioned charts.

### Learning Resources

- [Using Looker Studio with BigQuery](https://cloud.google.com/bigquery/docs/visualize-looker-studio)
- [Calculated fields in Looker Studio](https://support.google.com/looker-studio/answer/6299685)

### Tips

- You'll need to create a calculated field in Looker Studio to get the quarter information in proper format.

## Challenge 6: Notebooks for data scientists

### Introduction

TODO Using Spark to create a SparkML model??? 

### Description


### Success Criteria


### Learning Resources

### Tips


## Challenge 7: Cloud Composer for orchestration

### Introduction

Running the Dataform pipelines manually works, but it's not very practical. We'd rather automate this process and run it periodically. Although Dataform provides a lot of functionality to automate and schedule running the pipelines, we're going to consider a bit more flexible orchestrator  that can also run additional steps, such as running our Spark models, that are not part of the Dataform pipelines. We're going to use Cloud Composer, which is basically a managed and serverless version of the well-known Apache Airflow framework, to schedule and run our complete pipeline.

### Description

We've already created a Cloud Composer environment for you. You need to configure and run [this DAG](#TBD) (Directed Acyclic Graph, a collection of tasks organized with dependencies and relationships) on that environment every day at 6AM local time.

TODO explain the DAG
TODO write the DAG

### Success Criteria

- There's a new DAG that's triggered every day at 6AM local time
- There's at least one successful run of the DAG.

### Learning Resources

### Tips