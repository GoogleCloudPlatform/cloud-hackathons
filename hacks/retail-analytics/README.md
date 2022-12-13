# Retail Analytics
## Introduction
This gHack will take you through replicating and processing operational data from an Oracle database into Google Cloud in real time. You'll also figure out how to forecast future demand, and how to visualize this forecast data as it arrives.

This tutorial uses a fictitious retail store named FastFresh to help demonstrate the concepts we'll be dealing with. FastFresh specializes in selling fresh produce, and wants to minimize food waste and optimize stock levels across all stores. You will use fictitious sales transactions from FastFresh as the operational data in this tutorial.

![Architecture](images/arch-diagram.png)

The above diagram showcases the flow of operational data through Google Cloud, which is as follows:

- Incoming data from an Oracle source is captured and replicated into Cloud Storage through Datastream.
- This data is processed and enriched by Dataflow templates, and is then sent to BigQuery.
- BigQuery ML is used to forecast demand for your data, which is then visualized in Looker.

## Learning Objectives
- Replicate and process data from Oracle into BigQuery in real time.
- Run demand forecasting against  data that has been replicated and processed from Oracle in BigQuery.
- Learn how to visualize forecasted demand and operational data in real time in Looker.

You'll be using a variety of Google Cloud offerings to achieve this including:

1. Oracle
1. BigQuery
1. Datastream
1. Dataflow
1. BigQuery ML
1. Looker

## Challenges
- Challenge 0: Installing Prerequisites and Preparing Your Environment
   - Get yourself ready to develop our FastFresh solution
- Challenge 1: Replicating Oracle Data Using Datastream
   - Backfill the Oracle FastFresh schema and replicate updates to Cloud Storage in real time.
- Challenge 2: Creating a Dataflow Job using the Datastream to BigQuery Template
   - Now it’s time to create a Dataflow job which will read from GCS and update BigQuery. You will deploy the pre-built Datastream to BigQuery Dataflow streaming template to capture these changes and replicate them into BigQuery.
- Challenge 3: Analyzing Your Data in BigQuery
   - A real time view of the operational data is now available in BigQuery. In this challenge you will run queries such as comparing the sales of a particular product in real time, or combining sales and customer data to analyze spending habits.
- Challenge 4: Building a Demand Forecast
   - In this challenge you will use BigQuery ML to build a model to forecast the demand for products in store.

## Prerequisites
- Your own GCP project with Owner IAM role.
- gCloud CLI
- Visual Studio Code
- Successfully complete the following FastStarts:
   - [BigQuery Console](https://cloud.google.com/bigquery/docs/quickstarts/load-data-console)
   - [BigQuery ML](https://cloud.google.com/bigquery-ml/docs/linear-regression-tutorial)
   - [Vertex AI Workbench](https://cloud.google.com/vertex-ai/docs/workbench/user-managed/create-user-managed-notebooks-instance-console-quickstart)
   - [Dataflow](https://cloud.google.com/dataflow/docs/quickstarts/quickstart-templates)

## Contributors
- Carlos Augusto
- Gino Filicetti
- Murat Eken

## Challenge 0: Installing Prerequisites and Preparing Your Environment

### Introduction

Throughout this game, you will be using a number of different tools and products within Google Cloud. Our focus in this first challenge will be installing the necessary technologies in your Google Cloud environment to ensure your success throughout the hack.

### Description

1. Select or create a Google Cloud project.
    - Make sure all team members have access to the project as Project Editor and at least one member has the Project Owner role.
    - Make sure billing is enabled for your project
        - Hack now! You can find information to hack this task here: <https://cloud.google.com/apis/docs/getting-started#enabling_billing>

1. Enable the Compute Engine, Datastream, Dataflow and Pub/Sub APIs.
    - Hack now! You can find information to hack this task here: <https://cloud.google.com/apis/docs/getting-started>

1. Create a new auto-mode VPC named default
    - Hack now! You can find information to hack this task here: <https://cloud.google.com/vpc/docs/using-vpc#create-auto-network>

1. In Cloud Shell, define the following environment variables:
    ```bash
    export PROJECT_NAME="YOUR_PROJECT_NAME"
    export PROJECT_ID="YOUR_PROJECT_ID"
    export PROJECT_NUMBER="YOUR_PROJECT_NUMBER"
    export BUCKET_NAME="${PROJECT_ID}-oracle_retail"
    ```
- Replace the following:
    - `YOUR_PROJECT_NAME`: the name of your project
    - `YOUR_PROJECT_ID`: the ID of your project
    - `YOUR_PROJECT_NUMBER`: the number of your project

5. Run the following:
    ```bash
    gcloud config set project ${PROJECT_ID}
    ```

6. Clone the GitHub tutorial repository which contains the scripts and utilities that you use in this tutorial:
    ```bash
    git clone \
    https://github.com/caugusto/datastream-bqml-looker-tutorial.git
    ```

7. Extract the comma-delimited file containing sample transactions to be loaded into Oracle:
    ```bash
    bunzip2 \
    datastream-bqml-looker-tutorial/sample_data/oracle_data.csv.bz2
    ```

8. Create a sample Oracle XE 11g docker instance on Compute Engine by doing the following:
    - In Cloud Shell, change the directory to build_docker:
        ```bash
        cd datastream-bqml-looker-tutorial/build_docker
        ```
    - Execute the following build_orcl.sh script:
        ```bash
        ./build_orcl.sh \
        -p <YOUR_PROJECT_ID> \
        -z <GCP_ZONE> \
        -n <GCP_NETWORK_NAME> \
        -s <GCP_SUBNET_NAME> \
        -f Y \
        -d Y
        ```

        - Replace the following:
            - `YOUR_PROJECT_ID`: Your Cloud project ID
            - `GCP_ZONE`: The zone where the compute instance will be created
            - `GCP_NETWORK_NAME`: The network name where VM and firewall entries will be created
            - `GCP_SUBNET_NAME`: The network subnet where VM and firewall entries will be created
            - `Y or N`: A choice to create the FastFresh schema and ORDERS table (Y or N). Use Y for this tutorial.
            - `Y or N`: A choice to configure the Oracle Database for Datastream usage (Y or N). Use Y for this tutorial.

        - The script does the following:
            - Creates a new Google Cloud Compute instance.
            - Configures an Oracle 11g XE docker container.
            - Pre-loads the FastFresh schema and the Datastream prerequisites.

        - After the script executes, the `build_orcl.sh` script gives you a summary of the connection details and credentials (`DB Host`, `DB Port`, and `SID`). Make a copy of these details because you use them later in this tutorial.

9. Create a Cloud Storage bucket to store your replicated data:
    ```bash
    gsutil mb gs://${BUCKET_NAME}
    ```
    Make a copy of the bucket name because you use it in a later step.

10. Configure your bucket to send notifications about object changes to a Pub/Sub topic. This configuration is required by the Dataflow template. Do the following:
    - In Cloud Shell, run the following command: 
        ```bash
        gsutil notification create -t projects/${PROJECT_ID}/topics/oracle_retail -f \ 
        json gs://${BUCKET_NAME}
        ```
        This command creates a new topic called oracle_retail which sends notifications about object changes to the Pub/Sub topic.

    - Next, run the following command:
        ```bash
        gcloud pubsub subscriptions create oracle_retail_sub \
        --topic=projects/${PROJECT_ID}/topics/oracle_retail
        ```
        This command creates a Pub/Sub subscription to receive messages which are sent to the oracle_retail topic.

11. Create a BigQuery dataset named `retail`:
    ```bash
    bq mk --dataset ${PROJECT_ID}:retail
    ```

12. Assign the BigQuery Admin role to your Compute Engine service account.
    ```bash
    gcloud projects add-iam-policy-binding ${PROJECT_ID}  \
    --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
    --role='roles/bigquery.admin'
    ```

> **NOTE:** When you finish this tutorial, you can avoid continued billing by deleting the resources you created. See [cleaning up](https://docs.google.com/document/d/1xxb7B7nZ7fQaHo8TdPDsxurZ7u1-wzAfgWwXQyt-r4k/edit#heading=h.mlrdlgcohh7k) for more detail.

### Success Criteria

- You have a Google Cloud Project that all team members have access to, has billing enabled, has a VPC named default created and the Compute Engine, Datastream, Dataflow and Pub/Sub APIs are enabled.
- You've created a Google Storage bucket
- You've created an Oracle instance
- You've created a Pub/Sub and BigQuery instance

## Challenge 1: Replicating Oracle Data Using Datastream

### Introduction

Datastream supports the synchronization of data to Google Cloud databases and storage solutions from sources such as MySQL and Oracle.

In this challenge, Datastream backfills the Oracle FastFresh schema and replicates updates from the Oracle database to Cloud Storage in real time.

### Description

1. In Cloud Console, navigate to Datastream and click **Create Stream**. A form is generated. Populate the form as follows and click **Continue**:
    - **Stream name**: `oracle-cdc`
    - **Stream ID**: `oracle-cdc`
    - **Source type**: `Oracle`
    - **Destination Type**: `Cloud Storage`
    - **All other fields**: `Keep the default value`

1. In the **Define & Test Source** section, select **Create new connection profile**. A form is generated. Populate the form as follows:
    - **Connection profile name**: `orcl-retail-source`
    - **Connection profile ID**: `orcl-retail-source`
    - **Hostname**: `Hack Now! Find the database host name!`
    - **Port**: `1521`
    - **Username**: `datastream`
    - **Password**: `tutorial_datastream`
    - **System Identifier (SID)**: `XE`

1. Choose the connectivity method **IP allowlisting**, and then click **Continue**.

1. Click **Run Test** to validate the connection to the Oracle database, and then click **Create & Continue**.

1. The **Select Objects to Include** defines the objects to replicate, specific schemas, tables and columns and be included or excluded.
Select the `FASTFRESH > ORDERS` table:

    ![Select Objects](images/select-objects-to-include.png)

1. To load existing records, set the **Backfill mode** to Automatic,  and then click **Continue**.

1. In the **Define Destination** section, select **Create new connection profile**. A form is generated. Populate the form as follows, and then click **Create & Continue**:
    - **Connection Profile Name**: `oracle-retail-gcs`
    - **Connection Profile ID**: `oracle-retail-gcs`
    - **Bucket Name**: *The equivalent to `gs://${PROJECT_ID}-oracle_retail`. This is the bucket you created earlier*

1. Leave the Stream path prefix blank and select **JSON** for **Output format**. Click **Continue**.

1. Click **Run Validation** and, assuming no issues were found, click **Create**.

### Success Criteria

- You've created a Datastream stream named **oracle-cdc** 
- The oracle-cdc stream is setup to replicate the **ORDERS** table
- The oracle-cdc stream is pointing to bucket **gs://${PROJECT_ID}-oracle_retail**

### Learning Resources

- [Datastream Overview](https://cloud.google.com/datastream/docs/overview)
- [Creating a new Stream](https://cloud.google.com/datastream/docs/create-a-stream)
- [Creating a new Connection Profile](https://cloud.google.com/datastream/docs/create-connection-profiles)

## Challenge 2 - Creating a Dataflow Job using the Datastream to BigQuery Template

### Introduction

Now that you have a Datastream stream configured to capture changes from the source and send them to GCS, it’s time to create a Dataflow job which will read from GCS and update BigQuery.

You can deploy the pre-built [Datastream to BigQuery](https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming#datastream-to-bigquery) Dataflow streaming template to capture these changes and replicate them into BigQuery.

You can extend the functionality of this template by including User Defined Functions (UDFs). UDFs are functions written in JavaScript that are applied to each incoming record and can do operations such as enriching, filtering and transforming data.

### Description
1. Create a UDF file for processing the incoming data. The logic below just quickly masks the `PAYMENT_METHOD` column.
    - In the Cloud Shell session, **copy and save** the following code to a new file named `retail_transform.js`:

        ```javascript
        function process(inJson) {
            var obj = JSON.parse(inJson),
                includePubsubMessage = obj.data && obj.attributes,
                data = includePubsubMessage ? obj.data : obj;

            data.PAYMENT_METHOD = data.PAYMENT_METHOD.split(':')[0].concat("XXX");

            data.ORACLE_SOURCE = data._metadata_schema.concat('.', data._metadata_table);

            return JSON.stringify(obj);  
        }
        ```

    - Create a new bucket to store the Javascript and upload the `retail_transform.js` to Cloud Storage using the `gsutil cp` command. **Run**:

        ```bash
        gsutil mb gs://js-${BUCKET_NAME}
        gsutil cp retail_transform.js gs://js-${BUCKET_NAME}/utils/retail_transform.js
        ```

1. Create a Dataflow Job
    - Create a Dead Letter Queue (DLQ) bucket to be used by Dataflow. **Run**: 

        ```bash
        gsutil mb gs://dlq-${BUCKET_NAME}
        ```
        
    - Create a service account for the Dataflow execution and assign the account the following roles: Dataflow Worker, Dataflow Admin, Pub/Sub Admin, BigQuery Data Editor,BigQuery Job User, and Datastream Admin

        ```bash
        gcloud iam service-accounts create df-tutorial

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/dataflow.admin"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/dataflow.worker"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/pubsub.admin"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/bigquery.dataEditor"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/bigquery.jobUser"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/datastream.admin"

        gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:df-tutorial@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/storage.admin"
        ```

    - Run the following command:

        ```bash
        gcloud compute firewall-rules create fw-allow-inter-dataflow-comm --action=allow --direction=ingress --network=GCP_NETWORK_NAME  --target-tags=dataflow --source-tags=dataflow --priority=0 --rules tcp:12345-12346
        ```

        This command creates a firewall egress rule which lets Dataflow VMs connect, send and receive network traffic on TCP ports 12345 and 12346 when auto scaling is enabled.

    - Run the Dataflow job. Using Cloud Shell:

        ```bash
        cd ~/datastream-bqml-looker-tutorial/udf
        chmod +x run_dataflow.sh
        ./run_dataflow.sh
        ```

        In the Google Cloud Console, find the Dataflow service and verify that a new streaming job has started.

        **NOTE:** Look at the **Use the Dataflow Monitoring Interface** documentation in the [Learning Resources](#learning-resources) section below.

    - Go back to the Cloud Shell. **Run** this command to start your Datastream stream:

        ```bash
        gcloud datastream streams update oracle-cdc --location=us-central1 --state=RUNNING --update-mask=state
        ```

    - **Run** the following command to list your stream status. After about 30 seconds, the oracle-cdc stream status should change to `RUNNING`:

        ```bash
        gcloud datastream streams list --location=us-central1
        ```

    - Return to the Datastream console to validate the progress of the `ORDERS` table backfill as shown here:

        ![Datastream Console](images/datastream-console.png)

        Because this task is an initial load, Datastream reads from the `ORDERS` object. It writes all records to the JSON files located in the Cloud Storage bucket that you specified during the stream creation. It will take about 10 minutes for the backfill task to complete.

        **NOTE:** Look at the **Monitor a Stream** documentation in the [Learning Resources](#learning-resources) section below.
        

### Success Criteria

- Buckets for the javascript (retail_transform.js) and the dead letter queues created
- retail_transform.js uploaded to gs://js-${BUCKET_NAME}/utils
- A service account created for the Dataflow job execution
- IAM roles assigned to the Dataflow service account
- Firewall rule created to allow Dataflow processes intercommunication
- Dataflow job running
- Datastream stream oracle-cdc running


### Learning Resources

- [Creating Storage Buckets](https://cloud.google.com/storage/docs/creating-buckets)
- [Creating Service Accounts](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts)
- [Adding IAM Policy Bindings](https://cloud.google.com/sdk/gcloud/reference/projects/add-iam-policy-binding)
- [Configuring Firewall Rules](https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules)
- [Starting Dataflow Jobs](https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run)
- [Datastream Stream Update](https://cloud.google.com/sdk/gcloud/reference/datastream/streams/update)
- [Use the Dataflow Monitoring Interface](https://cloud.google.com/dataflow/docs/guides/using-monitoring-intf)
- [Monitor a Stream](https://cloud.google.com/datastream/docs/monitor-a-stream)

## Challenge 3: Analyzing Your Data in BigQuery

### Introduction

After a few minutes, your backfilled data replicates into BigQuery. Any new incoming data streams into your datasets in (near) real-time. Each record  is processed by the UDF logic that you defined as part of the Dataflow template.

A real time view of the operational data is now available in BigQuery. You can run queries such as  comparing the sales of a particular product across stores in real time, or to combine sales and customer data to analyze the spending habits of customers in particular stores.

The following two new tables in the retail dataset are created by the Dataflow job:

- `ORDERS`: This output table is a replica of the Oracle table and include the transformations applied to the data as part of the Dataflow template:
- `ORDERS_log`: This staging table records all the changes from your Oracle source. The table is partitioned, and stores the updated record alongside some metadata change information, such as whether the change is an update, insert, or delete.

### Description

1. In BigQuery Console, run the following SQL to query the top three selling products:

    ```sql
    SELECT product_name, SUM(quantity) as total_sales
    FROM `retail.ORDERS`
    GROUP BY product_name
    ORDER BY total_sales desc
    LIMIT 3
    ```

    The output should be similar to the following:

    ![Query results](images/query-results.png)

1. In BigQuery, execute the following SQL statements to query the number of rows on both the `ORDERS` and `ORDERS_log` tables:

    ```sql
    SELECT count(*) FROM `hackfast.retail.ORDERS_log`;
    SELECT count(*) FROM `hackfast.retail.ORDERS`;
    ```

    **NOTE:** With the backfill completed, both statements return the number `520217`. Please wait until the backfill is done before closing this challenge.

### Success Criteria

- BigQuery tables **hackfast.retail.ORDERS_log** and **hackfast.retail.ORDERS** created and populated successfully
- Select count(*) on both tables (**hackfast.retail.ORDERS_log** and **hackfast.retail.ORDERS**) return the number 520217

### Learning Resources

- [Getting Started with BigQuery](https://cloud.google.com/bigquery/docs/quickstarts/query-public-dataset-console)
- [Preview BigQuery Data](https://cloud.google.com/bigquery/docs/quickstarts/load-data-console#preview_table_data)

## Challenge 4: Building a Demand Forecast

### Introduction

BigQuery ML can be used to build and deploy [demand forecasting](https://cloud.google.com/architecture/demand-forecasting-overview) models using the [ARIMA_PLUS](https://cloud.google.com/bigquery-ml/docs/reference/standard-sql/bigqueryml-syntax-create-time-series) algorithm. In this section, you use BigQuery ML to build a model to forecast the demand for products in store.

### Description

#### Prepare your training data
Here you will use parts of the replicated data as training data to your model.

The training data  describes for each product (`product_name`), how many units were sold (`total_sold`) per hour (`hourly_timestamp`).

1. Using the BigQuery console, **run** the following SQL to create and save the training data to a new `training_data` table:

    ```sql
    CREATE OR REPLACE TABLE `retail.training_data`
    AS
        SELECT
            TIMESTAMP_TRUNC(time_of_sale, HOUR) as hourly_timestamp, product_name, 
            SUM(quantity) AS total_sold
        FROM `retail.ORDERS`
        GROUP BY hourly_timestamp, product_name
        HAVING hourly_timestamp 
        BETWEEN TIMESTAMP_TRUNC('2021-11-22', HOUR) AND TIMESTAMP_TRUNC('2021-11-28', HOUR)
    ORDER BY hourly_timestamp
    ```

1. **Run** the following SQL to verify the training_data table:

    ```sql
    SELECT * FROM `retail.training_data` LIMIT 10;
    ```

    ![Training Query Results](images/training-query-results.png)

#### Forecast Demand
1. Still In BigQuery, execute the following SQL to create a time-series model that uses the ARIMA_PLUS algorithm:

    Options to use for model named: `retail.arima_plus_model`:

    ```sql
    MODEL_TYPE='ARIMA_PLUS',
    TIME_SERIES_TIMESTAMP_COL='hourly_timestamp',
    TIME_SERIES_DATA_COL='total_sold',
    TIME_SERIES_ID_COL='product_name'
    ```

    SQL to use: 
    
    ```sql
    QUERY hourly_timestamp, product_name AND total_sold FROM OBJECT retail.training_data
    ```

    **NOTE:** Look at the **Creating ARIMA_PLUS Model** documentation in the [Learning Resources](#learning-resources) section below.


1. Run the following SQL to forecast the demand for organic bananas over the next 30 days:

    **NOTE:** The [`ML.FORECAST`](https://cloud.google.com/bigquery-ml/docs/reference/standard-sql/bigqueryml-syntax-forecast) function is used to forecast the expected demand over a horizon of n hours.

    ```sql
    SELECT * FROM ML.FORECAST(MODEL retail.arima_plus_model, STRUCT(720 AS horizon))
    ```

    The output should be similar to:

    ![Banana Query Results](images/banana-query-results.png)

    Because the training data is hourly, the horizon value will use the same unit of time when forecasting (hours). A horizon value of 720 hours will return forecast results over the next 30 days.

    **NOTE:** Since this is a small sample dataset, further investigation into the accuracy of the model is out of scope for this tutorial.

#### Create a view for easier visualization
1. In BigQuery, **run** the following SQL query to create a view, joining the actual and forecasted sales for a given product:

    ```sql
    CREATE OR REPLACE VIEW retail.orders_forecast AS (
    SELECT
    timestamp,
    product_name,
    SUM(forecast_value) AS forecast,
    SUM(actual_value) AS actual
    FROM
    (
    SELECT
        TIMESTAMP_TRUNC(TIME_OF_SALE, HOUR) AS timestamp,
        product_name,
        SUM(QUANTITY) as actual_value,
        NULL AS forecast_value
        FROM retail.ORDERS
        GROUP BY timestamp, product_name
    UNION ALL
    SELECT
        forecast_timestamp AS timestamp,
        product_name,
        NULL AS actual_value,
        forecast_value,
            FROM ML.FORECAST(MODEL retail.arima_plus_model,
                STRUCT(720 AS horizon))
        ORDER BY timestamp
    )
    GROUP BY timestamp, product_name
    ORDER BY timestamp
    )    
    ```

    **NOTE:** This view lets Looker query the relevant data when you explore the actual and forecasted data.

1. Still in BigQuery, **run** the following SQL to validate the view:

    ```sql
    SELECT * FROM retail.orders_forecast
    WHERE PRODUCT_NAME='Bag of Organic Bananas'
    AND TIMESTAMP_TRUNC(timestamp, HOUR) BETWEEN TIMESTAMP_TRUNC('2021-11-28', HOUR) AND TIMESTAMP_TRUNC('2021-11-30', HOUR)
    LIMIT 100;
    ```

    You see an output that is similar to the following:

    ![Looker Query Results](images/looker-query-results.png)

    As an alternative to BigQuery views, you can also use Looker’s built-in derived tables capabilities. These include built-in derived tables and SQL-based derived tables. For more information, see [Derived Tables in Looker](https://docs.looker.com/data-modeling/learning-lookml/derived-tables).

### Success Criteria

- Table **retail.training_data** created
- ARIMA model **retail.arima_plus_model** created
- View **retail.orders_forecast** created

### Learning Resources

- [Creating and Using BigQuery Tables](https://cloud.google.com/bigquery/docs/tables)
- [Creating Views in BigQuery](https://cloud.google.com/bigquery/docs/views)
- [Creating ARIMA_PLUS Model](https://cloud.google.com/bigquery-ml/docs/reference/standard-sql/bigqueryml-syntax-create-time-series)
