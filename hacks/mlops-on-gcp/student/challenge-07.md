
[< Previous Challenge](challenge-06.md) - **[Home](../README.md)**
## Introduction

If you’ve completed all of the previous challenges, you’re now ready to bring it all together. This task is all about automating the whole process, so that when Model Monitoring raises an alert, a new model is trained and deployed. 

## Description

<ql-infobox>
For this challenge we’ll keep things simple, we’ll re-use the original training data to re-train and won’t do anything if the model is not better, but in real world you’d be using a combination of existing data with the new data, and take manual actions if automatic re-training doesn’t yield better results. Note also that Vertex AI Endpoints allow deploying multiple versions of a model to enable blue-green style deployments, but we’ll ignore that too, the latest version will get all the traffic for this task.
</ql-infobox>

Use the provided build pipeline (`clouddeploy.yaml`) to create a new build configuration. Make sure that it’s only triggered when a webhook is called. Also provide the necessary variables, such as the model training code version, endpoint name etc. Configure Log based alerts for Model Monitoring, and use webhooks as a notification channel to trigger the build.

## Success Criteria

1. There’s a correctly configured build pipeline that can be triggered through webhooks only
2. Model Monitoring alerts can trigger the mentioned build through Log based alerts.
3. There’s at least one successful build

## Tips

- Cloud Build supports inline yaml as well
- You can create/update a Monitoring Job with the `gcloud` cli which has more configuration options than the UI

## Learning Resources

- [Log based alerts](https://cloud.google.com/logging/docs/alerting/log-based-alerts) for Cloud Logging
- [Webhook notifications](https://cloud.google.com/monitoring/support/notification-options#webhooks) for Cloud Logging
- [Log based alerts](https://cloud.google.com/vertex-ai/docs/model-monitoring/using-model-monitoring#set-up-alerts) for Vertex AI Model Monitoring feature anomaly detection
- [Triggering Cloud Build with webhooks](https://cloud.google.com/build/docs/automate-builds-webhook-events)

