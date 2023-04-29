# Implementing MLOps on GCP

## Introduction

We'll be assuming that all necessary services have been enabled and the (default) service accounts have the right permissions. You can use the provided `Terraform` scripts to set up things properly if you're not using Qwiklabs.

> Qwiklabs: for every team only a single person needs to start the lab. A single lab instance provides 5 users with _Owner_ permissions so people can work in parallel. The person starting the lab can share the usernames & passwords for the team members. 

## Coach's Guides

- Challenge 1: Let’s start exploring!
- Challenge 2: If it isn’t in version control, it doesn’t exist
- Challenge 3: You break the build, you buy cake
- Challenge 4: Automagic training with pipelines
- Challenge 5: Make it work and make it scale
- Challenge 6: Monitor your models
- Challenge 7: Close the loop

## Challenge 1: Let’s start exploring!

### Notes & Guidance

For Qwiklabs users the only option is User-Managed Notebooks as the Managed Notebooks option is not available. 

The Notebook can run anywhere, but a region close to the participants is preferred. For User-Managed Notebooks, a vanilla Python image is faster than the other options, so that should be chosen. And the _Permissions_&rarr;_Single user only_ option must be chosen (which is the default for Managed Notebooks), which requires to enter the Advanced Setting section for User-Managed Notebooks.

Creating a virtual environment is essential otherwise things might break due to dependency conflicts. The instructions point to a gist that works with `pip` and both standard and User-Managed Notebooks have that installed. However, `conda` virtual environments would work fine too (and might give better control of the Python version).

```shell
python3 -m venv .playground
source .playground/bin/activate
```

The easiest way to get the zip file is through `curl` or `wget`. But download & upload is also fine.

```shell
curl -JLO https://github.com/meken/gcp-mlops-demo/archive/refs/heads/main.zip
```

Once the archive is extracted, the notebook should be opened and the cells must be executed one by one. Note that restarting the kernel takes a few moments, users need to wait for it before continuing with the next steps. 

No changes are needed for the notebook, the GCS bucket is created by default in the selected region `us-central1`. No need to change that. But if users change that, they need to make sure that the new region is also used in other challenges.

## Challenge 2: If it isn’t in version control, it doesn’t exist

### Notes & Guidance

Keep in mind that the users need the _Owner_ permission to create a new Cloud Source Repository.

Git requires users to set up their identity before anything can be committed. So users need do the following:

```shell
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"
```

If users miss this step, they'll be prompted the first time they want to do a commit and they can complete it by that time.

After that a local git repository in the root of the extracted archive needs to be created, cd to `gcp-mlops-demo-main` (if the archive is downloaded as a zip file and extracted with default options) and run the following commands.

```shell
git init .
git add .
git commit -m "initial commit"
```

> **Warning**  
> If participants initialize the repo in their home directory instead of in the root of the extracted archive, that will cause problems in the next challenges.

If users ignored the instructions and cloned the repo, they can skip the local Git repo creation, but they'll have to do the following steps.

Creating a Cloud Source Repository should be trivial, it should be created in the lab project when Qwiklabs is used. And then an SSH key should be added (see the vertical ellipsis on the right side of the top bar for Cloud Source Repositories).

The following command will generate an SSH key pair and show the contents of the public key to be copied to the Cloud Source Repositories.

```shell
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub
```

Then users need to add the Cloud Source Repository as a remote. This is all documented on the landing page of the newly created repository if users choose the _Push code from a local Git repository_ option.

```shell
git remote add google ssh://STUDENT...@ORGANIZATION...@source.developers.google.com:2022/p/PROJECT/r/gcp-mlops-demo
```

And finally push the changes.

```shell
git push --all google
```

> **Note**  
> The Cloud Source Repositories still defaults to `master` branch, you might need to switch to a different branch to see the contents if you've used `main` as your default branch.

> **Warning**  
> It's possible to use `gcloud` authentication instead of SSH but that's not the challenge :)

## Challenge 3: You break the build, you buy cake

### Notes & Guidance

Any region can be selected to do the build (with Qwiklabs you might need to choose the global option). Users need to point to the right build file, and that's `/build/cloudbuild.yaml`, note the `/build/` prefix.

There's trailing whitespace in one of the files, which causes the linter to fail. That needs to be removed, and when the changes are pushed, the push trigger will yield a succesfull build.

## Challenge 4: Automagic training with pipelines

### Notes & Guidance

The `pipeline` module can be used to generate the pipeline definition. Assuming that the user is in the right environment:

```shell
python -m trainer.pipeline
```

The generated json file can be copied to the default GCS bucket (created as part of the first challenge) or downloaded locally.

The parameters for the Vertex AI Pipeline Job:

| Parameter            | Value |
| ---                  | ---   |
| GCS output directory | `gs://{PROJECT_ID}/pipelines`|
| endpoint             | `[none]`  |
| location             | `us-central1` |
| project\_id          | `{PROJECT_ID}`|
| python\_pkg          | `gcp-mlops-demo-0.8.0.dev0.tar.gz`|

The `python_pkg` parameter can also be the full path to the package, and also works without the `tar.gz` extension. `GCS output directory` could also be any folder in the bucket (no trailing `/` characters though).

## Challenge 5: Make it work and make it scale

### Notes & Guidance

#### Online Inferencing

During model deployment the smallest instance size (`n1-standard-2`) should be chosen, with the minimum number of instances set to 1 and the maximum number of instances set to >1 for autoscaling to work.

Once the model is deployed the following request payload can be used to verify things. Sample data contains valid values but participants need to make sure that they don't copy the target column.

```json
{
    "instances": [
        [7,11,4,6,44,0,1,193,193],
        [7,25,4,23,1680,18.37,0,132,262]
    ]
}
```

Assuming that the payload is stored in a file `request.json` and there's only one `Endpoint` in the project.

```shell
REGION=...
PROJECT_ID=`gcloud config list --format="value(core.project)"`
ENDPOINT_ID=`gcloud ai endpoints list --region=${REGION} --format="value(ENDPOINT_ID)"`
TOKEN=`gcloud auth print-access-token`
URL="https://${REGION}-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/endpoints/${ENDPOINT_ID}:predict"

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN"  -d @request.json $URL
```

The following commands will install & run `apache-bench` load tool. The parameters 30000 requests and 100 connections will generate sufficient throughput for the endpoint to scale (assuming that the smallest instance size, `n1-standard-2`, is chosen). 

```shell
sudo apt-get -y install apache2-utils
ab -n 30000 -c 100 -p request.json -T "application/json" -H "Authorization: Bearer $TOKEN" $URL
```

> **Warning**  
> Participants need to make sure that the output of `ab` doesn't contain any non 2XX responses or failed requests.

This exercise can be completed either on the notebook terminal or Cloud Shell.

#### Batch Inferencing

```sql
CREATE OR REPLACE TABLE 
    taxi_batch.sample10K AS 
SELECT
    EXTRACT(MONTH from pickup_datetime) as trip_month,
    EXTRACT(DAY from pickup_datetime) as trip_day,
    EXTRACT(DAYOFWEEK from pickup_datetime) as trip_day_of_week,
    EXTRACT(HOUR from pickup_datetime) as trip_hour,
    TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration,
    trip_distance,
    payment_type,
    pickup_location_id as pickup_zone,
    pickup_location_id as dropoff_zone
FROM 
    bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2017 TABLESAMPLE SYSTEM (1 PERCENT) 
LIMIT 
    10000
```

Make sure that the target column (`tip_bin`) is not included as a column, as the model uses all the columns from the table and any additional column will raise an error. 

The output table should be a _new_ table, so you should either just give the name of the dataset or the URI of a table that doesn't exist yet.

## Challenge 6: Monitor your models

### Notes & Guidance

#### Online Monitoring

Once the Endpoint is up and running, it's possible to edit it from the UI and turn on Monitoring. The sample data is in `gs://$PROJECT_ID/data/sample/sample.csv`. Stick to the defaults for the things that are not in the instructions. Creating the notification channel and the Pub/Sub topic should be trivial from the UI.

#### Batch Monitoring

Setting this up through the UI should be trivial, the training sample data uri should be `gs://${PROJECT_ID}/data/sample/sample.csv`. Creating the notification channel and the Pub/Sub topic should be trivial from the UI.

## Challenge 7: Close the loop

### Notes & Guidance

#### Online Loop

> **Warning**  
> Updating a monitoring job is only possible when the job is running, which might take some time, so if the job status is `PENDING` you might not be able to update it. Typically this would only happen if the participants are very quick with the challenges, in that case they could consider deleting the monitoring job and recreate it with the proper configuration.

> **Note** Completing this might take a few hours as monitoring jobs only run once every hour. It's sufficient to see if things are configured properly than the full trigger of the pipeline.

> **Note** In case a non global region is chosen for the Cloud Build pipeline, the displayed webhook URL might not be correct. If you run into 404s while calling that webhook, you can try `https://cloudbuild.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/triggers/${TRIGGER_NAME}:webhook?key=${API_KEY}&secret=${SECRET_VALUE}&trigger=${TRIGGER_NAME}&projectId=${PROJECT_ID}"` as described in the [docs](https://cloud.google.com/build/docs/automate-builds-webhook-events#creating_webhook_triggers). Also, if you run it with cURL don't forget to set the _Content-Type_ to _application/json_. 

The _retraining_ (`clouddeploy.yaml`) build pipeline requires the following variables to be set.

| Variable                  | Value |
| ---                       | ---   |
| \_PYTHON\_PKG             | `gcp-mlops-demo-0.8.0.dev0` |
| \_ENDPOINT                | `ep-taxi-tips` |
| \_LOCATION                | `us-central1` |

The _retraining_ pipeline must respond to a _Pub/Sub message_ using the topic created for the notification channel.

#### Batch Loop

The main challenge is to configure the build pipelines properly. You'll need the following variables for the _batch predictions_ (`batchdeploy.yaml`) pipeline. This pipeline must have a _webhook event_ trigger.

| Variable                  | Value |
| ---                       | ---   |
| \_PYTHON\_PKG             | `gcp-mlops-demo-0.8.0.dev0` |
| \_MODEL\_NAME             | `taxi-tips`   |
| \_SOURCE\_TABLE\_URI      | `bq://{PROJECT_ID}.{DATASET}.{TABLE}` |
| \_TRAINING\_SAMPLE\_URI   | `gs://{PROJECT_ID}/data/sample/sample.csv`|
| \_LOCATION                | `us-central1` |

The Cloud Scheduler cron job configuration should be: `30 3 * * 7` with HTTP target type and webhook URL from the previous build configuration, using the POST method (see the note around the webhook URL in [Online Loop](#online-loop) section if you get 404s). One thing to remember is to set the _Content-Type_ header to _application/json_ otherwise the execution will fail.

You can verify the Cloud Scheduler job by a _Force run_.

Similarly the _retraining_ (`clouddeploy.yaml`) build pipeline requires the following variables to be set.

| Variable                  | Value |
| ---                       | ---   |
| \_PYTHON\_PKG             | `gcp-mlops-demo-0.8.0.dev0` |
| \_ENDPOINT                | `[none]` |
| \_LOCATION                | `us-central1` |

The _retraining_ pipeline must respond to a _Pub/Sub message_ using the topic created for the notification channel.

