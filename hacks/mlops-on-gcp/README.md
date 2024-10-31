# Implementing MLOps on GCP

## Introduction

In this hack, you'll implement the full lifecycle of an ML project. We'll provide you with a sample code base and you'll work on automating continuous integration (CI), continuous delivery (CD), and continuous training (CT) for a machine learning (ML) system.

![MLOps Overview](./images/mlops-challenges.png)

> **Note** This gHack is inspired by the methodology from [this article](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning).

There's no coding involved, we've already prepared the code to train a simple *scikit-learn* model; this could've been any other framework too, the model code has no dependencies on any Google Services or libraries.

We're using the New York Taxi dataset to build a *RandomForestClassifier* to predict whether
the tip for the trip is going to be more than 20% of the fare.

First step is all about exploration and running that code in an interactive environment for development and experimentation purposes.

Then we'll store that code in a version control system so the whole team has access to it and we can keep track of all changes.

After that we'll automate continuous integration and building of packages through build pipelines in Challenge 3.

Challenge 4 is all about data-to-model pipelines, orchestrating data extraction, validation, preparation, model training, evaluation and validation.

Once the model has been trained, in Challenge 5 we'll deploy that model to an API endpoint for real-time inferencing, or choose for the batch option and run batch inferencing.

Challenge 6 is all about monitoring that endpoint/batch predictions and detecting any drift/skew between training data and inferencing data.

And finally in Challenge 7 we'll bring all these things together by tapping into model monitoring and triggering re-training when the model starts to behave off.

> **Warning** As of June 2024 *Cloud Source Repositories* is [end of sale](https://cloud.google.com/source-repositories/docs/release-notes#June_17_2024). However, any organization that has created at least one CSR repository in the past, will still have access to existing repositories and will be able to create new ones. If you're running this in a Qwiklabs environment you're good to go, but if you're running this in **your** own environment, please verify that you have access to *Cloud Source Repositories* in your organization.

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

## Challenges

- Challenge 1: Let's start exploring!
- Challenge 2: If it isn't in version control, it doesn't exist
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

## Challenge 1: Let's start exploring!

### Introduction

As depicted in the overview diagram, the first step of any ML project is data analysis and maybe some experimentation. Jupyter notebooks are great for interactive exploration. We can run those locally, but Vertex AI provides managed environments where you get to run Jupyter with the right security controls and flexible hardware options.

### Description

Create a *Vertex AI Workbench Instance*. Pick a region close to you and choose the **single user only** option.

It's a good practice to have isolated virtual environments for experiments, so create a new virtual environment and install that as a kernel. See this [gist](https://gist.github.com/meken/e6c7430997de9b3f2cf7721f8ecffc04) for the instructions.

> **Warning** Not using a dedicated and isolated environment/kernel might cause dependency conflicts as Vertex AI Workbench Instances come pre-installed with some versions of the required libraries.

We've prepared a [sample project on Github](https://github.com/meken/gcp-mlops-demo/archive/refs/heads/main.zip), navigate there and download the project as a **zip** file and extract the contents of the zip file onto your Notebook instance. Open the notebook `01-tip-toe-vertex-ai.ipynb`, make sure that you've selected the newly created kernel. You should now be able to run the first notebook and get familiar with some of the Vertex AI concepts.

> **Note** As we're installing packages in the first cell of the sample notebook and restarting the kernel in one of the following cells, *Run All* will not work. Run the cells one-by-one also to understand what's going on in every cell.

### Success Criteria

1. There's a new single-user Vertex AI Workbench Instance.
2. The sample notebook `01-tip-toe-vertex-ai.ipynb` is successfully run (using the newly generated kernel) and a model file is generated/stored in Google Cloud Storage.
3. No code was modified.

### Tips  

- Some of the required settings can be found in the *Advanced Settings* section when you're creating a new Vertex AI Workbench Instance.
- If there's nothing mentioned in the instructions about a parameter, stick to the defaults (this applies to all of the challenges).
- You can download the zip file to your local machine and then upload it to the Notebook instance, but you can also get the zip URL and use the `wget` (or `curl`) command from a terminal on the Notebook instance.
- The sample notebook creates a bucket in a specific *region*, take note of that as you'll need that information in the next challenges.

### Learning Resources

- Documentation on [Vertex AI Workbench Instances](https://cloud.google.com/vertex-ai/docs/workbench/instances/introduction)

## Challenge 2: If it isn't in version control, it doesn't exist

### Introduction

The objective of this challenge is to create and configure a Git repository so that the code can be version controlled. In principle, you can use any external Git repository (Github/BitBucket/Gitlab etc), but for this challenge we'll use a *Cloud Source Repository* on GCP.

> **Warning** As of June 2024 *Cloud Source Repository* is [end of sale](https://cloud.google.com/source-repositories/docs/release-notes#June_17_2024). However, any organization that has created at least one CSR repository in the past, will still have access to existing repositories and will be able to create new ones. So, if you've made it so far, and your coaches have done their due diligence, you're lucky and can use CSR for this challenge.

### Description

If you have completed the previous challenge, you should have the source code already unpacked on your Vertex AI Workbench Instance (if another user is driving this challenge, see the tips). But you're free to complete this challenge on another environment such as Cloud Shell or even on your local machine.

Create a Cloud Source Repository, configure access through **SSH**.

Make sure that the source code is pushed to the freshly created repository and can be cloned from it.

### Success Criteria

1. There's a new Cloud Source Repository.
2. The code base is pushed to Cloud Source Repository.
3. At least one team member can access the repository from the command line.
4. No code was modified.

### Tips

- The previous challenge required you to use a single-user Vertex AI Workbench Instance, so if you want to complete this challenge in a Vertex AI Workbench Instance as a different user, you'll have to create a new instance. In that case create another single-user Vertex AI Workbench Instance for the new user and download the repository (zip file). You don't need to run the provided sample notebook or create the virtual environment for this challenge.
- Alternatively you could use the Cloud Shell to complete this challenge.
- Both Vertex AI Workbench Instances and Cloud Shell have OpenSSH already installed

### Learning Resources

- How-to guides for [Cloud Source Repository](https://cloud.google.com/source-repositories/docs/how-to)

## Challenge 3: You break the build, you buy cake

### Introduction

This task is all about automating things using Cloud Build. When multiple people work on the same project and contribute to the same repository it's good to have a *Continuous Integration* pipeline that can lint, test and package the source code everytime new commits are pushed. In this challenge we'll use the provided build pipeline to automate this process. It will generate and store the newest version of the Python package, which contains the training code, when there's a new commit.

### Description

Once things look fine locally, set up a *Cloud Build Trigger* that's run when code is *pushed* to the repository. The code base already includes a build configuration (`cloudbuild.yaml`), have a look at it to understand what it does. Make sure that the trigger uses that build configuration and the `Compute Engine Default Service Account` as the service account. Name the trigger `CI` (or `continuous-integration`).

> **Warning**  
> The qwiklabs environment only has quota in the *global* region, make sure that you pick that when you're creating the trigger.

### Success Criteria

1. There's a new Cloud Build push trigger called `CI` (or `continuous-integration`).
2. The trigger is connected to the Cloud Source Repository created in the previous challenge.
3. The trigger uses the provided (fully configured) build configuration.
4. And there's at least one successful build.

### Tips

- You will need to make some minor changes to the Python code base to have a successful run.

### Learning Resources

- How-to guides for [Cloud Build](https://cloud.google.com/build/docs/how-to)

## Challenge 4: Automagic training with pipelines

### Introduction

The previous challenge introduced the concept of build pipelines. But there are different types of pipelines, and this task is getting started with Vertex AI pipelines for *Continuous Training*. In our example the continuous training pipeline will extract data from BigQuery, validate it, prepare it, train a model with it (using the Python package that's built during the previous challenge), evaluate that model and register it in Vertex AI Model Registry.

### Description

If you've successfully completed the previous challenge, your training code has been packaged and can be run from a Vertex AI pipeline.

The provided project has a `pipeline.py` file that can generate a pipeline definition. Run that to generate a pipeline definition file in `YML` format. Use the generated pipeline definition file to create a new *Pipeline Run* through the GCP Console. Fill in the required pipeline parameters in the next step (you can look up the Python package location). Do not set/override the `endpoint` and `monitoring_job` parameters (keep the default values).

> **Note**  
> Once the pipeline is triggered, it will take ~10 minutes to complete.

### Success Criteria

1. There's at least one successful Vertex AI pipeline run that has generated a Managed Model in the Model Registry.
2. No code was modified.

### Tips

- Read the `pipeline.py` to understand what it does.
- Note that the `pipeline.py` can generate `JSON` and `YML` pipeline definition files based on the extension of the output file name.
- You can either upload the pipeline definition from a local machine, or put it on GCS and refer to its location.
- You have already created a bucket, you can use that as the pipeline root (optionally add `pipelines` folder in it).
- For the parameter *location* look up the *region* of the storage bucket created in the first challenge.
- And for the *python_pkg* parameter check the Cloud Build pipeline to find out where the created Python package is stored and browse to that location to get the name of the package.
- If you're in doubt about the parameters, remember to *Use the Force and read the Source* ;)

### Learning Resources

- Running [Vertex AI Pipelines](https://cloud.google.com/vertex-ai/docs/pipelines/run-pipeline#console) on the console

## Challenge 5: Make it work and make it scale

### Introduction

Having a model is only the first step, we can now make predictions using that model. This is typically called inferencing (or scoring) and can be done

- In an **online** fashion with an HTTP endpoint that can generate predictions for incoming data in real-time,
- Or in **batch** by running the model on a large set of files or a database table.

From this challenge onwards you'll have the option to either do online inferencing or batch inferencing. Please choose your path:

- [Online Inferencing](#online-inferencing)
- [Batch Inferencing](#batch-inferencing)

### Online Inferencing

<!-- markdownlint-disable-file  no-duplicate-heading -->

### Description

So, you've chosen for online inferencing. In order to use the model to serve predictions in an online fashion it has to be deployed to an endpoint. Luckily Vertex AI provides exactly what we need, a managed service for serving predictions, called Online Prediction.

Create a new Vertex AI Endpoint and deploy the freshly trained model. Use the smallest machine type but make sure that it can scale to more than 1 node by configuring *autoscaling*.

> **Note**  
> The deployment of the model will take ~10 minutes to complete.
>
> **Warning**  
> Note that the Qwiklab environment we're using has a quota on the endpoint throughput (30K requests per minute), **do not exceed that**.

### Success Criteria

1. The model has been deployed to an endpoint and can serve requests.
2. Show that the Endpoint has scaled to more than 1 instance under load.
3. No code was modified.

### Tips

- Verify first that you're getting predictions from the endpoint before generating load (for example using cURL)
- In order to generate load you can use any tool you want, but the easiest approach would be to install [apache-bench](https://httpd.apache.org/docs/2.4/programs/ab.html) on Cloud Shell or your notebook environment. Google it, if you don't know how to use it :)

### Learning Resources

- Documentation on [Online Predictions deployment](https://cloud.google.com/vertex-ai/docs/general/deployment)
- More info on the [request data format](https://cloud.google.com/vertex-ai/docs/predictions/get-online-predictions). Remember that we've used the `scikit-learn` framework to train our model.

### Batch Inferencing

### Description

So, you've chosen for the batch inferencing path. We're going to use Vertex AI Batch Predictions to get predictions for data in a BigQuery table. First, go ahead and create a new table with at most 10K rows that's going to be used for generating the predictions. Once the table is created, create a new Batch Prediction job with that table as the input and another BigQuery table as the output, using the previously created model. Choose a small machine type and 2 compute nodes. Don't turn on Model Monitoring yet as that's for the next challenge.

> **Note**  
> The batch inferencing will take roughly ~10 minutes, most of that is the overhead of starting the cluster, so increasing the number of instances won't help with the small table we're using.

### Success Criteria

1. There's a properly structured input table in BigQuery with 10K rows.
2. There's a succesful Batch Prediction job.
3. There are predictions in a new BigQuery table.
4. No code was modified.

### Tips

- The pipeline that we've used in the previous challenge contains a task to prepare the data using BigQuery, have a look at that for inspiration.
- Make sure that the input table has the exact same number of input columns as required by the model. Remember, for training extra data is needed which is not an input for the model at inferencing time ;)

### Learning Resources

- Creating BigQuery [datasets](https://cloud.google.com/bigquery/docs/datasets)
- Creating BigQuery [tables](https://cloud.google.com/bigquery/docs/tables#sql)
- BigQuery [public datasets](https://console.cloud.google.com/marketplace/details/city-of-new-york/nyc-tlc-trips)
- Vertex AI [Batch Predictions](https://cloud.google.com/vertex-ai/docs/tabular-data/classification-regression/get-batch-predictions)

## Challenge 6: Monitor your models

### Introduction

There are times when the training data becomes not representative anymore because of changing demographics, trends etc. To catch any skew or drift in feature distributions or even in predictions, it is necessary to monitor your model performance continuously.

> **Note** We'll be using *Model Monitoring v1* for this challenge, which is configured during *Online Prediction Endpoint configuration* for online models, and *Batch Prediction Run configuration* for batch execution.

If you've chosen the online inferencing path, continue with [Online Monitoring](#online-monitoring), otherwise please skip to the [Batch Monitoring](#batch-monitoring) section.

### Online Monitoring

### Description

Vertex AI Endpoints provide Model Monitoring capabilities which will be configured for this challenge. Turn on Training-serving skew detection for your model and use an hourly granularity to get alerts. Create a new notification channel that uses Pub/Sub messages and configure it to use a new Pub/Sub topic.

Send at least 10K prediction requests to collect monitoring data.

### Success Criteria

1. Show that the Model Monitoring is running successfully for the endpoint that's created in the previous challenge.
2. Show that there's new Pub/Sub topic and a Pub/Sub notification channel for the Model Monitoring job.
3. By default Model Monitoring keeps request/response data in a BigQuery dataset, find and show that data.
4. No code was modified.

### Tips

- You can use the `sample.csv` file from Challenge 1 as the baseline data.
- You can use the same tool you've used for the previous challenge to generate the requests, make sure to include some data that has a different distribution than the training data.

### Learning Resources

- Introduction to [Vertex AI Model Monitoring](https://cloud.google.com/vertex-ai/docs/model-monitoring/overview)
- Creating a [Pub/Sub topic](https://cloud.google.com/pubsub/docs/create-topic)
- Creating a [notification channel](https://cloud.google.com/monitoring/support/notification-options#pubsub)

### Batch Monitoring

### Description

Vertex AI Batch prediction jobs provide Model Monitoring capabilities as well. Create a new Batch Predition job with monitoring turned on with BigQuery input and ouput tables, use default values for the alert thresholds. Create a new notification channel that uses Pub/Sub messages and configure it to use a new Pub/Sub topic.

### Success Criteria

1. There's a new Batch Prediction job with monitoring turned on.
2. Show that there's new Pub/Sub topic and a Pub/Sub notification channel for the Model Monitoring job.
3. As batch inferencing will take roughly ~10 minutes again, it's sufficient to show the properly configured job configuration.
4. No code was modified.

### Tips

- You can use the `sample.csv` file from Challenge 1 as the baseline training data.
- You can use the same data you've used for the previous challenge to run the batch predictions, make sure to include some data that has a different distribution than the training data.

### Learning Resources

- [Model monitoring](https://cloud.google.com/vertex-ai/docs/model-monitoring/model-monitoring-batch-predictions) for Batch Predictions
- Creating a [Pub/Sub topic](https://cloud.google.com/pubsub/docs/create-topic)
- Creating a [notification channel](https://cloud.google.com/monitoring/support/notification-options#pubsub)

## Challenge 7: Close the loop

### Introduction

If you've completed all of the previous challenges, you're now ready to bring it all together. This task is all about automating the whole process, so that when Model Monitoring raises an alert, a new model is trained and deployed.

Just like the previous challenges, if you've chosen the online inferencing path, continue to [Online Loop](#online-loop), otherwise please skip to the [Batch Loop](#batch-loop) section.

> **Note**  
> For this challenge we'll keep things simple, we'll reuse the original training data to retrain and won't do anything if the model is not better, but in real world you'd be using a combination of existing data with the new data, and take manual actions if automatic retraining doesn't yield better results.

### Online Loop

### Description

Use the provided build pipeline (`clouddeploy.yaml`) to create a new build configuration. Configure it to be triggered in response to the messages received in the Pub/Sub topic that's used to configure the Model Monitoring notifications. Also provide the necessary variables, such as the model training code version, endpoint name etc. Name this trigger `CT-CD` (or `continuous-training-and-delivery`).

### Success Criteria

1. There's a correctly configured build pipeline that can be triggered through Pub/Sub messages, named `CT-CD` (or `continuous-training-and-delivery`).
2. Model Monitoring alerts can trigger the mentioned build through Pub/Sub notification channel.
3. There's at least one successful build.
4. No code was modified.

### Tips

- If you create the topic before you create the notification channel you can copy its fully qualified name and paste when configuring the notification channel.

### Learning Resources

- [Triggering Cloud Build with Pub/Sub events](https://cloud.google.com/build/docs/automate-builds-pubsub-events)

### Batch Loop

### Description

Typically Batch Predictions are asynchronous and are scheduled to run periodically (daily/weekly etc). You can trigger batch jobs using different methods, for this challenge we'll use Cloud Build pipelines in combination with Vertex AI pipelines. Create a new Cloud Build trigger using the provided `batchdeploy.yaml` file, don't forget to set the required variables. Call this trigger `CD` (or `continuous-delivery`) and make sure that this build pipeline is triggered through webhook events. Create a new Cloud Scheduler job that runs every Sunday at 3:30 and uses the webhook event URL as the execution method.

Running the batch predictions periodically will only get us half way. We need to monitor any Model Monitoring alerts and act on that. There's another Cloud Build pipeline definition provided by `clouddeploy.yaml` that's responsible for retraining. Configure that in a new Cloud Build trigger, call it `CT` (or `continuous-training`) set the required variables (remember to set *ENDPOINT* to `[none]`, the others should be familiar, when in doubt have a look at the yaml file). Use Pub/Sub messages as the trigger event and pick the topic that's configured for Model Monitoring Pub/Sub notification channel.

### Success Criteria

1. There's a correctly configured build pipeline for *batch predictions* that can be triggered with webhooks, called `CD` (or `continuous-delivery`).
2. There's a Cloud Scheduler job that is configured to run every Sunday at 3.30 triggering the batch predictions build pipeline.
3. There's a correctly configured build pipeline for *retraining* that can be triggered with Pub/Sub messages, called `CT` (or `continuous-training`).
4. Show that all the components have run at least once.
5. No code was modified.

### Tips

- If you create the topic before you create the notification channel you can copy its name and paste when configuring the notification channel.
- The webhook URL configuration in Cloud Scheduler requires the header `Content-Type` to be set to `application/json` otherwise the things won't work.
- You can *force run* a Cloud Scheduler job, no need to wait until Sunday :).

### Learning Resources

- [Cloud Scheduler](https://cloud.google.com/scheduler/docs/schedule-run-cron-job)
- [Triggering Cloud Build with webhook events](https://cloud.google.com/build/docs/automate-builds-webhook-events)
- [Triggering Cloud Build with Pub/Sub events](https://cloud.google.com/build/docs/automate-builds-pubsub-events)
