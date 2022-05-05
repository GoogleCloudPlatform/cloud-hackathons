# Challenge 2 - Creating a Dataflow Job using the Datastream to BigQuery Template

[< Previous Challenge](./Challenge-01.md) - **[Home](../readme.md)** - [Next Challenge>](./Challenge-03.md)

## Introduction

Now that you have a Datastream stream configured to capture changes from the source and send them to GCS, it’s time to create a Dataflow job which will read from GCS and update BigQuery.

You can deploy the pre-built [Datastream to BigQuery](https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming#datastream-to-bigquery) Dataflow streaming template to capture these changes and replicate them into BigQuery.

You can extend the functionality of this template by including User Defined Functions (UDFs). UDFs are functions written in JavaScript that are applied to each incoming record and can do operations such as enriching, filtering and transforming data.

## Description
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

        ***HACK NOW!*** *You can find information to hack this challenge [at this link.](https://cloud.google.com/dataflow/docs/guides/using-monitoring-intf)*

    - Go back to the Cloud Shell. **Run** this command to start your Datastream stream:

        ```bash
        gcloud datastream streams update oracle-cdc --location=us-central1 --state=RUNNING --update-mask=state
        ```

    - **Run** the following command to list your stream status. After about 30 seconds, the oracle-cdc stream status should change to `RUNNING`:

        ```bash
        gcloud datastream streams list --location=us-central1
        ```

    - Return to the Datastream console to validate the progress of the `ORDERS` table backfill as shown here:

        ![Datastream Console](../images/datastream-console.png)

        Because this task is an initial load, Datastream reads from the `ORDERS` object. It writes all records to the JSON files located in the Cloud Storage bucket that you specified during the stream creation. It will take about 10 minutes for the backfill task to complete.

        ***HACK NOW!*** *You can find information to hack this challenge [at this link.](https://cloud.google.com/datastream/docs/monitor-a-stream)*
        

## Success Criteria

- **TODO**: Need success criteria

## Learning Resources

- **TODO**: Need learning resources

*List of relevant links and online articles that should give the attendees the knowledge needed to complete the challenge.*

- link 1
- link 2
- link 3