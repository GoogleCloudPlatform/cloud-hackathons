
[< Previous Challenge](challenge-05.md) - **[Home](../README.md)** - [Next Challenge >](challenge-07.md)
## Introduction

There are times when the training data becomes not representative anymore because of changing demographics, trends etc. To catch any skew or drift in feature distributions or even in predictions, it is necessary to monitor your model performance continuously. Luckily Vertex AI Endpoints have Model Monitoring capabilities that you can use for that purpose.

## Description

Turn on Training-serving skew detection for your model, use an hourly granularity to get alerts. Send at least 10K prediction requests to collect monitoring data.

## Success Criteria

1. Show that the Model Monitoring is running successfully for the endpoint that’s created in the previous challenge
2. By default Model Monitoring keeps request/response data in a BigQuery dataset, find and show that data

## Tips

- You can use the sample.csv file from challenge 1 as the baseline data
- You can use the same tool you’ve used for the previous challenge to generate the requests, make sure to include some data that has a different distribution than the training data.

## Learning Resources

Introduction to [Vertex AI Model Monitoring](https://cloud.google.com/vertex-ai/docs/model-monitoring/overview)

