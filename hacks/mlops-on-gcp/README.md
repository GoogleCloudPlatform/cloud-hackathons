# Implementing MLOps on GCP

## Introduction

In this hack, you’ll implement the full lifecycle of an ML project. We’ll provide you with a sample code base and you’ll work on automating continuous integration (CI), continuous delivery (CD), and continuous training (CT) for a machine learning (ML) system. 

| ![MLOps Overview](https://cloud.google.com/static/architecture/images/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning-4-ml-automation-ci-cd.svg) |
| :--: |
| _Picture is from [this article](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)_ |

## Learning Objectives

This hack will help you explore the following tasks:

- Using Cloud Source Repositories for version control
- Using Cloud Build for automating continuous integration and delivery
- Vertex AI for 
  - Exploration through an interactive environment
  - Training on diverse hardware 
  - Model registration
  - Managed pipelines
  - Model serving
  - Model monitoring

> The instructions are minimal, meaning that you need to figure out things :) That's by design

## Challenges

- Challenge 1: Let’s start exploring!
- Challenge 2: If it isn’t in version control, it doesn’t exist
- Challenge 3: You break the build, you buy cake
- Challenge 4: Automagic training with pipelines
- Challenge 5: Make it work and make it scale
- Challenge 6: Monitor your models
- Challenge 7: Close the loop

## Prerequisites

- Knowledge of Python
- Knowledge of Git
- Basic knowledge of GCP
- Access to a GCP environment

## Contributors

- Murat Eken

## Challenge 1: Let’s start exploring!

### Introduction

As depicted in the overview diagram, the first step of any ML project is data analysis and maybe some experimentation. Jupyter notebooks are great for interactive exploration. We can run those locally, but Vertex AI provides managed environments where you get to run Jupyter with the right security controls.

### Description 

Create a User-Managed Notebook on Vertex AI. Pick a region close to you, create a simple vanilla **Python3** notebook instance (with no GPUs) and make sure that you've selected the **single user only** option.

It's a good practice to have isolated virtual environments for experiments, so create a new virtual environment and install that as a kernel. See this [gist](https://gist.github.com/meken/e6c7430997de9b3f2cf7721f8ecffc04) for the instructions. 

We’ve prepared a [sample project on Github](https://github.com/meken/gcp-mlops-demo/archive/refs/heads/main.zip), navigate there and download the project as a **zip** file and extract the contents of the zip file into your notebook environment. Open the notebook `01-tip-toe-vertex-ai.ipynb`, make sure that you've selected the newly created kernel. You should now be able to run the first notebook and get familiar with some of the Vertex AI concepts.

### Success Criteria

1. There’s a new User-Managed Notebook
2. The sample notebook `01-tip-toe-vertex-ai.ipynb` is successfully run and a model file is generated/stored in Google Cloud Storage
3. No code changes are needed for this challenge

### Tips

- Some of the required settings can be found in the _Advanced Settings_ section when you're creating a new _User-Managed Notebook_.
- You can download the zip file to your local machine and then upload it to the Notebook, but you can also get the zip URL and use the `wget` (or `curl`) command from the notebook environment.
- Not using a dedicated and isolated environment/kernel might cause dependency conflicts as _User-Managed Notebook_ instances come pre-installed with some versions of the required libraries.

### Learning Resources

- Documentation on [Vertex AI Workbench](https://cloud.google.com/vertex-ai/docs/workbench/user-managed/introduction)

## Challenge 2: If it isn’t in version control, it doesn’t exist

### Introduction

The objective of this challenge is to create and configure a Git repository so that the code can be version controlled. You could use any external Git repository (Github/BitBucket/Gitlab etc) but the easiest way for this challenge is to use a Cloud Source Repository on GCP.

### Description

If you have completed the previous challenge, you should have the source code already unpacked on your User-Managed Notebook. But you’re free to complete this challenge on another environment such as Cloud Shell or your local machine.

Create a Cloud Source Repository, configure access through **SSH**.

Make sure that the source code is pushed to the freshly created repository and can be cloned from it.

### Success Criteria

1. There’s a new Cloud Source Repository 
2. The code base is pushed to Cloud Source Repository
3. At least one team member can access the repository from the command line
4. No code changes are needed for this challenge

### Tips

- You already have a terminal available on the notebook that you’ve created as part of the previous challenge. That terminal has all the tools you need to complete this challenge.

### Learning Resources

- How-to guides for [Cloud Source Repository](https://cloud.google.com/source-repositories/docs/how-to)

## Challenge 3: You break the build, you buy cake

### Introduction

This task is all about automating things using Cloud Build.

### Description

Once things look fine locally, set up a Cloud Build that’s triggered when code is pushed to the repository. The code base already includes a build configuration (`cloudbuild.yaml`), have a look at it to understand what it does. Make sure that the trigger uses that build configuration. 

### Success Criteria

1. There’s a new Cloud Build push trigger
2. The trigger is connected to the repository created in the previous task
3. The trigger uses the provided (fully configured) build configuration from the repository
4. And there’s at least one successful build 

### Tips

- You will need to make some minor changes to the code base to have a successful run

### Learning Resources

How-to guides for [Cloud Build](https://cloud.google.com/build/docs/how-to)

## Challenge 4: Automagic training with pipelines

### Introduction

The previous challenge introduced the concept of build pipelines. But there are different types of pipelines, and this task is getting started with Vertex AI pipelines for continuous training. 

### Description

If you’ve successfully completed the previous challenge, your training code has been packaged and can be run from a pipeline.

The provided project has a `pipeline.py` file that can generate a pipeline definition. Run that to generate a pipeline definition file (JSON). Use the generated pipeline definition file to create a new Pipeline Run through the GCP Console. You'll need to fill in some parameters (you can look up the Python package location). Do not set/override the endpoint and monitoring_job parameters (keep the default values).

> **Note**  
> Once the pipeline is triggered, it will take ~10 minutes to complete.

### Success Criteria

1. There’s at least one successful Vertex AI pipeline run that has generated a Managed Model in the Model Registry
2. No code change is needed for this challenge

### Tips

- Make sure that you're running the module `trainer.pipeline` in the virtual environment you have created as part of the first challenge
- You can either upload the pipeline definition from a local machine, or put it on GCS and refer to its location
- You have already created a bucket, you can use that as the pipeline root (optionally add `pipelines` folder in it)
- For the parameters *location* and *python_pkg* check the Cloud Build pipeline to find out where and how the created package is stored
- If you're in doubt about the parameters, remember to _Use the Force and read the Source_ ;)

### Learning Resources

- Running [Python modules from the command line](https://docs.python.org/3/using/cmdline.html#cmdoption-m)
- Running [Vertex AI Pipelines](https://cloud.google.com/vertex-ai/docs/pipelines/run-pipeline#console) on the console

## Challenge 5: Make it work and make it scale

### Introduction

Having a model is only the first step, we can now make predictions using that model. This is typically called inferencing (or scoring) and can be done 

- in an **online** fashion with an HTTP endpoint that can generate predictions for incoming data in real-time, 
- or in **batch** by running the model on a large set of files or a database table. 

From this challenge onwards you'll have the option to either do online inferencing or batch. If you choose to accept the online inferencing path, read on, otherwise please skip to the [batch inferencing](#batch-inferencing) section.

### Description

So, you've chosen for online inferencing. In order to use the model to serve predictions in an online fashion it has to be deployed to an endpoint. Luckily Vertex AI has exatly what we need, Vertex AI Endpoints provide a managed service for serving predictions. 

Create a new Vertex AI Endpoint and deploy the freshly trained model. Use the smallest instance size but make sure that it can scale to more than 1 instance. 

> **Note**  
> The deployment of the model will take ~10 minutes to complete.

> **Warning**  
> Note that the Qwiklab environment we're using has a quota on the endpoint throughput (30K requests per minute), **do not exceed that**.

### Success Criteria

1. The model has been deployed to an endpoint and can serve requests
2. Show that the Endpoint has scaled to more than 1 instance under load
3. No code change is needed for this challenge

### Tips

- In order to generate load you can use any tool you want, but the easiest approach would be to install [apache-bench](https://httpd.apache.org/docs/2.4/programs/ab.html) on Cloud Shell or your notebook environment.

### Learning Resources

- Documentation on [Vertex AI Endpoints](https://cloud.google.com/vertex-ai/docs/predictions/overview)
- More info on the [request data format](https://cloud.google.com/vertex-ai/docs/predictions/get-predictions#request-body-details)

## Batch inferencing

### Description

TODO So, you've chosen for batch inferencing. 

> **Note**  
> The batch inferencing will take roughly ~25 minutes, most of that is the overhead of starting the clusters, so increasing the number of instances won't help.

### Success Criteria

1. TODO

### Tips

- TODO

### Learning Resources

-  TODO

## Challenge 6: Monitor your models

### Introduction

There are times when the training data becomes not representative anymore because of changing demographics, trends etc. To catch any skew or drift in feature distributions or even in predictions, it is necessary to monitor your model performance continuously. 

If you've chosen the online inferencing path, read on, otherwise please skip to the [batch monitoring](#batch-monitoring) section.

### Description

Vertex AI Endpoints provide Model Monitoring capabilities which needs to be turned on for this challenge. Turn on Training-serving skew detection for your model, use an hourly granularity to get alerts. Send at least 10K prediction requests to collect monitoring data.

### Success Criteria

1. Show that the Model Monitoring is running successfully for the endpoint that’s created in the previous challenge
2. By default Model Monitoring keeps request/response data in a BigQuery dataset, find and show that data

### Tips

- You can use the sample.csv file from challenge 1 as the baseline data
- You can use the same tool you’ve used for the previous challenge to generate the requests, make sure to include some data that has a different distribution than the training data

### Learning Resources

Introduction to [Vertex AI Model Monitoring](https://cloud.google.com/vertex-ai/docs/model-monitoring/overview)

### Batch monitoring

### Description

Vertex AI Batch prediction jobs provide Model Monitoring capabilities as well.

### Success Criteria

1. 

### Tips

- You can use the sample.csv file from challenge 1 as the baseline training data
- You can use the same data you’ve used for the previous challenge to run the batch predictions, make sure to include some data that has a different distribution than the training data

### Learning Resources

TODO

## Challenge 7: Close the loop

### Introduction

If you’ve completed all of the previous challenges, you’re now ready to bring it all together. This task is all about automating the whole process, so that when Model Monitoring raises an alert, a new model is trained and deployed. 

Just like the previous challenges, if you've chosen the online inferencing path, read on, otherwise please skip to the [batch loop](#batch-loop) section.

### Description

> **Note**  
> For this challenge we’ll keep things simple, we’ll re-use the original training data to re-train and won’t do anything if the model is not better, but in real world you’d be using a combination of existing data with the new data, and take manual actions if automatic re-training doesn’t yield better results. Note also that Vertex AI Endpoints allow deploying multiple versions of a model to enable blue-green style deployments, but we’ll ignore that too, the latest version will get all the traffic for this task.

Use the provided build pipeline (`clouddeploy.yaml`) to create a new build configuration. Make sure that it’s only triggered when a webhook is called. Also provide the necessary variables, such as the model training code version, endpoint name etc. Configure Log based alerts for Model Monitoring, and use webhooks as a notification channel to trigger the build.

### Success Criteria

1. There’s a correctly configured build pipeline that can be triggered through webhooks only
2. Model Monitoring alerts can trigger the mentioned build through Log based alerts.
3. There’s at least one successful build

### Tips

- Cloud Build supports inline yaml as well
- You can create/update a Monitoring Job with the `gcloud` cli which has more configuration options than the UI

### Learning Resources

- [Log based alerts](https://cloud.google.com/logging/docs/alerting/log-based-alerts) for Cloud Logging
- [Webhook notifications](https://cloud.google.com/monitoring/support/notification-options#webhooks) for Cloud Logging
- [Log based alerts](https://cloud.google.com/vertex-ai/docs/model-monitoring/using-model-monitoring#set-up-alerts) for Vertex AI Model Monitoring feature anomaly detection
- [Triggering Cloud Build with webhooks](https://cloud.google.com/build/docs/automate-builds-webhook-events)

### Batch loop

### Description

TODO 
Use the provided build pipeline (`clouddeploy.yaml`) to create a new build configuration. Make sure that it’s only triggered when a webhook is called. Also provide the necessary variables, such as the model training code version, endpoint name etc. Configure Log based alerts for Model Monitoring, and use webhooks as a notification channel to trigger the build.

### Success Criteria

1. There’s a correctly configured build pipeline that can be triggered through webhooks only
2. Model Monitoring alerts can trigger the mentioned build through Log based alerts.
3. There’s at least one successful build

### Tips

- Cloud Build supports inline yaml as well

### Learning Resources

- [Log based alerts](https://cloud.google.com/logging/docs/alerting/log-based-alerts) for Cloud Logging
- [Webhook notifications](https://cloud.google.com/monitoring/support/notification-options#webhooks) for Cloud Logging
- [Log based alerts](https://cloud.google.com/vertex-ai/docs/model-monitoring/using-model-monitoring#set-up-alerts) for Vertex AI Model Monitoring feature anomaly detection
- [Triggering Cloud Build with webhooks](https://cloud.google.com/build/docs/automate-builds-webhook-events)