# Challenge 7: Close the loop

[< Previous Challenge](solution-06.md) - **[Home](../README.md)**

## Notes & Guidance

Users need to make sure that Cloud Logging is enabled.

```shell
JOB_ID=`gcloud ai model-monitoring-jobs list --region=$REGION --format="value(name)"`
```

Note that the following command will only successfully run if a monitoring job has been completed previously (which might take up to an hour)

```shell
gcloud ai model-monitoring-jobs update $JOB_ID --region=$REGION --anomaly-cloud-logging

```

In order to verify if Cloud Logging is enabled

```shell
gcloud ai model-monitoring-jobs describe $JOB_ID --region=$REGION
```

The following conditions are needed to filter the logs for alerting.

```text
logName="projects/QWIKLAB_PROJECT_ID/logs/aiplatform.googleapis.com%2Fmodel_monitoring_anomaly"
resource.labels.model_deployment_monitoring_job=JOB_ID
```

> Note that completing this might take a few hours as monitoring jobs only run once every hour. It's sufficient to see if things are configured properly than the full trigger of the pipeline.
