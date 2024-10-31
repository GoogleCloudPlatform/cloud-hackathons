# Implementing Demand Forecasting on GCP

## Introduction

In this hack, you'll implement a state of the art deep learning forecasting model in just a few hours thanks to Vertex AI AutoML. We'll provide you with a sample notebook and you'll work on extending that notebook to train a model, run inference and see results.

## Learning Objectives

This hack will help you explore:

- Creating Vertex AI Dataset resource
- AutoML Training for demand forecasting
- Obtain evaluation metrics for the model resource
- Vertex AI Batch Prediction

## Challenges

- Challenge 1: Let's start importing data!
- Challenge 2: How quickly can you start training?
- Challenge 3: Getting the evaluation results
- Challenge 4: Time for batch prediction

## Prerequisites

- Knowledge of Python
- Knowledge of Git
- Basic knowledge of GCP
- Access to a GCP environment

## Contributors

- Naz Bayrak

## Challenge 1: Let's start exploring & data importing!

### Introduction

We'll start with an easy challenge. Jupyter notebooks are great for interactive exploration. We can run those locally, but Vertex AI provides managed environments where you get to run Jupyter with the right security controls.
Create a Managed Notebook on Vertex AI. We've prepared [a sample project on Github](https://github.com/nazlevent/demand_forecasting_AutoML), navigate there and clone the notebook into your environment. Open the notebook student_demand_forecasting_ghack_notebook.ipynb. You should now be able to run the first notebook until the model training section and get familiar with some of the Vertex AI concepts.

### Success Criteria

1. There's a new (User-)Managed Notebook
2. The sample notebook  student_demand_forecasting_ghack_notebook.ipynb is successfully run and there is VertexAI managed dataset in place.
3. No code changes are needed for this challenge

### Tips

- You can use the terminal in VertexAI Workbench to clone the repository. If you prefer a UI, [here](https://cloud.google.com/vertex-ai/docs/workbench/user-managed/save-to-github) is a tutorial on how to do it.

### Learning Resources

- Documentation on [Vertex AI Workbench](https://cloud.google.com/vertex-ai/docs/workbench/managed/introduction)

## Challenge 2: How quickly can you start training?

### Introduction

The objective of this challenge is to create an AutoML forecasting model for the next 30 days using the dataset from the first challenge. Instead of a point forecast we want you to output quantile forecasts so you can fine tune your results based on your business use case.  We already provided you the skeleton of the function but you need to fill it in.

### Success Criteria

1. There's a new model trained successfully on VertexAI
2. Code changes are needed for this challenge

### Tips

- Be careful on which metric you choose as an optimization objective. Quantile predictions require a specific parameter.
- Training  will take ~2.5 hours to complete.

### Learning Resources

Training documentation is [here](https://cloud.google.com/python/docs/reference/aiplatform/latest/google.cloud.aiplatform.AutoMLForecastingTrainingJob) & tabular training kick-off documentation is [here](https://cloud.google.com/python/docs/reference/aiplatform/latest/google.cloud.aiplatform.AutoMLTabularTrainingJob).
Read optimization objectives for forecast models [here](https://cloud.google.com/vertex-ai/docs/tabular-data/forecasting/train-model#optimization-objectives).

## Challenge 3: Getting the evaluation results

### Introduction

Before we start batch prediction, AutoML already reports the training results so we'll like you to take a look at them.

### Success Criteria

1. Print the model evaluation results in your notebook using `list_model_evaluations` function.

### Tips

You might need to make some minor changes to the code base to have a successful run

### Learning Resources

Here is a [pointer](https://cloud.google.com/vertex-ai/docs/samples/aiplatform-list-model-evaluation-slices-sample) to help you get started.

## Challenge 4: Time for batch prediction

### Introduction

What good is a model if you don't run inference against it? We'll use the model generated in the  previous challenge to run batch prediction against it. Again, we have the code skeleton ready for you.

### Success Criteria

1. Print the model batch prediction results and their explanations in your notebook.

### Tips

- You can get started with batch predictions [here](https://cloud.google.com/vertex-ai/docs/predictions/overview).
- You're done with the challenge, you can now either clean up your resources or move forward to take home challenge!
