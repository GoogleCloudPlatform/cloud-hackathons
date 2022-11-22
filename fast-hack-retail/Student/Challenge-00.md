# Challenge 0 - Installing Prerequisites and Preparing Your Environment

**[Home](../readme.md)** - [Next Challenge>](./Challenge-01.md)

## Introduction

Throughout this game, you will be using a number of different tools and products within Google Cloud. Our focus in this first challenge will be installing the necessary technologies in your Google Cloud environment to ensure your success throughout the hack.

## Description

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

## Success Criteria

- You have a Google Cloud Project that all team members have access to, has billing enabled, has a VPC named default created and the Compute Engine, Datastream, Dataflow and Pub/Sub APIs are enabled.
- You've created a Google Storage bucket
- You've created an Oracle instance
- You've created a Pub/Sub and BigQuery instance