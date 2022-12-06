
[< Previous Challenge](challenge-04.md) - **[Home](../README.md)** - [Next Challenge >](challenge-06.md)
## Introduction

Having a model is only the first step, in order to use the model it has to be deployed to an endpoint. Vertex AI Endpoints provide a managed service for serving predictions.

## Description

Create a new Vertex AI Endpoint and deploy the freshly trained model. Use the smallest instance size but make sure that it can scale to more than 1 instance. 

<ql-infobox>
The deployment of the model will take ~10 minutes to complete.
</ql-infobox>

<ql-warningbox>
Note that the Qwiklab environment we're using has a quota on the endpoint throughput (30K requests per minute), **do not exceed that**.
</ql-warningbox>

## Success Criteria

1. The model has been deployed to an endpoint and can serve requests
2. Show that the Endpoint has scaled to more than 1 instance under load
3. No code change is needed for this challenge

## Tips

- In order to generate load you can use any tool you want, but the easiest approach would be to install [apache-bench](https://httpd.apache.org/docs/2.4/programs/ab.html) on Cloud Shell or your notebook environment.

## Learning Resources

- Documentation on [Vertex AI Endpoints](https://cloud.google.com/vertex-ai/docs/predictions/overview)
- More info on the [request data format](https://cloud.google.com/vertex-ai/docs/predictions/get-predictions#request-body-details)

