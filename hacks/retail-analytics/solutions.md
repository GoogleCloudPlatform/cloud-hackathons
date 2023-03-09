# Real-time analytics with CDC

## Introduction

Welcome to the coach's guide for the Real-time analytics with CDC gHack. Here you will find links to specific guidance for coaches for each of the challenges.

Remember that this hack includes a [lecture presentation](resources/lectures.pdf) that introduces key topics associated with each challenge. It is recommended that the host present this presentation before attendees kick off the hack.

## Coach's Guides

- Challenge 0: Installing Prerequisites and Preparing Your Environment
   - Get yourself ready to develop our FastFresh solution
- Challenge 1: Replicating Oracle Data Using Datastream
   - Backfill the Oracle FastFresh schema and replicate updates to Cloud Storage in real time.
- Challenge 2: Creating a Dataflow Job using the Datastream to BigQuery Template
   - Now it’s time to create a Dataflow job which will read from GCS and update BigQuery. You will deploy the pre-built Datastream to BigQuery Dataflow streaming template to capture these changes and replicate them into BigQuery.
- Challenge 3: Building a Demand Forecast
   - In this challenge you will use BigQuery ML to build a model to forecast the demand for products in store.
- Challenge 4: Visualizing the results
   - In this challenge you will use your favourite visualization tool to display the predictions from the previous challenge

## Challenge 0: Installing Prerequisites and Preparing Your Environment

### Notes & Guidance

Create a Cloud Storage bucket to store the replicated data

```bash
gsutil mb -l ${REGION} gs://${BUCKET_NAME}
```

Create a new topic called `oracle_retail` which sends notifications about object changes to the Pub/Sub topic

```shell
gsutil notification create -t projects/${PROJECT_ID}/topics/oracle_retail -f json gs://${BUCKET_NAME}
```

Create a Pub/Sub subscription to receive messages which are sent to the `oracle_retail` topic

```shell
gcloud pubsub subscriptions create oracle_retail_sub --topic=projects/${PROJECT_ID}/topics/oracle_retail
```

Create a BigQuery dataset named `retail`:

```shell
bq mk --dataset ${PROJECT_ID}:retail
```

Assign the BigQuery Admin role to your Compute Engine service account.

```shell
gcloud projects add-iam-policy-binding ${PROJECT_ID}  \
--member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
--role='roles/bigquery.admin'
```

## Challenge 1: Replicating Oracle Data Using Datastream - Coach's Guide

### Notes & Guidance

In Cloud Console, navigate to Datastream and click **Create Stream**. A form is generated. Populate the form as follows and click **Continue**:
   - **Stream name**: `oracle-cdc`
   - **Stream ID**: `oracle-cdc`
   - **Source type**: `Oracle`
   - **Destination Type**: `Cloud Storage`
   - **All other fields**: `Keep the default value`

In the **Define & Test Source** section, select **Create new connection profile**. A form is generated. Populate the form as follows:
   - **Connection profile name**: `orcl-retail-source`
   - **Connection profile ID**: `orcl-retail-source`
   - **Hostname**: `Hack Now! Find the database host name!`
   - **Port**: `1521`
   - **Username**: `datastream`
   - **Password**: `tutorial_datastream`
   - **System Identifier (SID)**: `XE`

Choose the connectivity method **IP allowlisting**, and then click **Continue**.

Click **Run Test** to validate the connection to the Oracle database, and then click **Create & Continue**.

The **Select Objects to Include** defines the objects to replicate, specific schemas, tables and columns and be included or excluded.
Select the `FASTFRESH > ORDERS` table:

    ![Select Objects](images/select-objects-to-include.png)

To load existing records, set the **Backfill mode** to Automatic,  and then click **Continue**.

In the **Define Destination** section, select **Create new connection profile**. A form is generated. Populate the form as follows, and then click **Create & Continue**:
    - **Connection Profile Name**: `oracle-retail-gcs`
    - **Connection Profile ID**: `oracle-retail-gcs`
    - **Bucket Name**: *The equivalent to `gs://${PROJECT_ID}-oracle_retail`. This is the bucket you created earlier*

Leave the Stream path prefix blank and select **JSON** for **Output format**. Click **Continue**.

Click **Run Validation** and, assuming no issues were found, click **Create**.

## Challenge 2: Creating a Dataflow Job using the Datastream to BigQuery Template - Coach's Guide

### Notes & Guidance

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

        > **Note** Look at the **Use the Dataflow Monitoring Interface** documentation in the [Learning Resources](#learning-resources) section below.

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

        > **Note** Look at the **Monitor a Stream** documentation in the [Learning Resources](#learning-resources) section below.

After a few minutes, your backfilled data replicates into BigQuery. Any new incoming data streams into your datasets in (near) real-time. Each record  is processed by the UDF logic that you defined as part of the Dataflow template.

A real time view of the operational data is now available in BigQuery. You can run queries such as  comparing the sales of a particular product across stores in real time, or to combine sales and customer data to analyze the spending habits of customers in particular stores.

The following two new tables in the retail dataset are created by the Dataflow job:

- `ORDERS`: This output table is a replica of the Oracle table and include the transformations applied to the data as part of the Dataflow template:
- `ORDERS_log`: This staging table records all the changes from your Oracle source. The table is partitioned, and stores the updated record alongside some metadata change information, such as whether the change is an update, insert, or delete.

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

    > **Note** With the backfill completed, both statements return the number `520217`. Please wait until the backfill is done before closing this challenge.

## Challenge 3: Building a Demand Forecast - Coach's Guide

### Notes & Guidance

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

    > **Note** Look at the **Creating ARIMA_PLUS Model** documentation in the [Learning Resources](#learning-resources) section below.


1. Run the following SQL to forecast the demand for organic bananas over the next 30 days:

    > **Note** The [`ML.FORECAST`](https://cloud.google.com/bigquery-ml/docs/reference/standard-sql/bigqueryml-syntax-forecast) function is used to forecast the expected demand over a horizon of n hours.

    ```sql
    SELECT * FROM ML.FORECAST(MODEL retail.arima_plus_model, STRUCT(720 AS horizon))
    ```

    The output should be similar to:

    ![Banana Query Results](images/banana-query-results.png)

    Because the training data is hourly, the horizon value will use the same unit of time when forecasting (hours). A horizon value of 720 hours will return forecast results over the next 30 days.

    > **Note** Since this is a small sample dataset, further investigation into the accuracy of the model is out of scope for this tutorial.


## Challenge 4: Visualizing the results - Coach's Guide

### Notes & Guidance

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

    > **Note** This view lets Looker query the relevant data when you explore the actual and forecasted data.

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