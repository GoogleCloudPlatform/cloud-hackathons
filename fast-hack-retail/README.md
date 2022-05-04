# gHacks - Retail Analytics
## Introduction
In today's retail environments, anticipating your customer's needs is now table-stakes if you want to keep up with your competitors. How can you achieve this? What tools in Google Cloud's deep toolbox can be used? That's what we'll explore in this gHack.

## Learning Objectives
Over the course of this gHack you'll be replicating OLTP transactions to BigQuery and then use BigQuery ML to forecast demand for a product and present the outcome using Looker. 

You'll be using a variety of Google Cloud offerings to achieve this including:

1. Oracle
1. BigQuery
1. Datastream
1. Dataflow
1. BigQuery ML
1. Looker

## Challenges
1. Challenge 0: **[Installing Prerequisites and Preparing Your Environment](Student/Challenge-00.md)**
   - Get yourself ready to develop our FastFresh solution
1. Challenge 1: **[Replicating Oracle Data Using Datastream](Student/Challenge-01.md)**
   - Backfill the Oracle FastFresh schema and replicate updates to Cloud Storage in real time.
1. Challenge 2: **[Creating a Dataflow Job using the Datastream to BigQuery Template](Student/Challenge-02.md)**
   - Now it’s time to create a Dataflow job which will read from GCS and update BigQuery. You will deploy the pre-built Datastream to BigQuery Dataflow streaming template to capture these changes and replicate them into BigQuery.
1. Challenge 3: **[Analyzing Your Data in BigQuery](Student/Challenge-03.md)**
   - A real time view of the operational data is now available in BigQuery. In this challenge you will run queries such as comparing the sales of a particular product in real time, or combining sales and customer data to analyze spending habits.
1. Challenge 4: **[Building a Demand Forecast](Student/Challenge-04.md)**
   - In this challenge you will use BigQuery ML to build a model to forecast the demand for products in store.

## Prerequisites
- Your own GCP project with Owner IAM role.
- gCloud CLI
- Visual Studio Code
- Successfully complete the following FastStarts:
   - [BigQuery Console](https://cloud.google.com/bigquery/docs/quickstarts/load-data-console)
   - [BigQuery ML](https://cloud.google.com/bigquery-ml/docs/linear-regression-tutorial)
   - [Vertex AI Workbench](https://cloud.google.com/vertex-ai/docs/workbench/user-managed/create-user-managed-notebooks-instance-console-quickstart)
   - [Dataflow](https://cloud.google.com/dataflow/docs/quickstarts/quickstart-templates)

## Repository Contents
- `../Student/Resources`
  - Various initial files needed for students

## Contributors
- Carlos Augusto
- Gino Filicetti
- Murat Eken

