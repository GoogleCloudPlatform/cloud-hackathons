# Retail Analytics
## Introduction
This gHack will take you through replicating and processing operational data from an Oracle database into Google Cloud in real time. You'll also figure out how to forecast future demand, and how to visualize this forecast data as it arrives.

This tutorial uses a fictitious retail store named FastFresh to help demonstrate the concepts we'll be dealing with. FastFresh specializes in selling fresh produce, and wants to minimize food waste and optimize stock levels across all stores. You will use fictitious sales transactions from FastFresh as the operational data in this tutorial.

![Architecture](./images/arch-diagram.png)

The above diagram showcases the flow of operational data through Google Cloud, which is as follows:

- Incoming data from an Oracle source is captured and replicated into Cloud Storage through Datastream.
- This data is processed and enriched by Dataflow templates, and is then sent to BigQuery.
- BigQuery ML is used to forecast demand for your data, which is then visualized in Looker.

## Learning Objectives
- Replicate and process data from Oracle into BigQuery in real time.
- Run demand forecasting against  data that has been replicated and processed from Oracle in BigQuery.
- Learn how to visualize forecasted demand and operational data in real time in Looker.

You'll be using a variety of Google Cloud offerings to achieve this including:

1. Oracle
1. BigQuery
1. Datastream
1. Dataflow
1. BigQuery ML
1. Looker

## Challenges
- Challenge 0: **[Installing Prerequisites and Preparing Your Environment](Student/Challenge-00.md)**
   - Get yourself ready to develop our FastFresh solution
- Challenge 1: **[Replicating Oracle Data Using Datastream](Student/Challenge-01.md)**
   - Backfill the Oracle FastFresh schema and replicate updates to Cloud Storage in real time.
- Challenge 2: **[Creating a Dataflow Job using the Datastream to BigQuery Template](Student/Challenge-02.md)**
   - Now it’s time to create a Dataflow job which will read from GCS and update BigQuery. You will deploy the pre-built Datastream to BigQuery Dataflow streaming template to capture these changes and replicate them into BigQuery.
- Challenge 3: **[Analyzing Your Data in BigQuery](Student/Challenge-03.md)**
   - A real time view of the operational data is now available in BigQuery. In this challenge you will run queries such as comparing the sales of a particular product in real time, or combining sales and customer data to analyze spending habits.
- Challenge 4: **[Building a Demand Forecast](Student/Challenge-04.md)**
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
- `../Coach/Lectures.pdf`
  - Slides for Lectures on topics covered in this gHack

## Contributors
- Carlos Augusto
- Gino Filicetti
- Murat Eken

