# gHacks - Retail Analytics
## Introduction
Welcome to the coach's guide for the Retail Analytics gHack. Here you will find links to specific guidance for coaches for each of the challenges.

Remember that this hack includes a [lecture presentation](Lectures.pdf) that introduces key topics associated with each challenge. It is recommended that the host present this presentation before attendees kick off the hack.

## Coach's Guides
- Challenge 1: **[Replicating Oracle Data Using Datastream](solution-01.md)**
   - Backfill the Oracle FastFresh schema and replicate updates to Cloud Storage in real time.
- Challenge 2: **[Creating a Dataflow Job using the Datastream to BigQuery Template](solution-02.md)**
   - Now it’s time to create a Dataflow job which will read from GCS and update BigQuery. You will deploy the pre-built Datastream to BigQuery Dataflow streaming template to capture these changes and replicate them into BigQuery.
- Challenge 3: **[Analyzing Your Data in BigQuery](solution-03.md)**
   - A real time view of the operational data is now available in BigQuery. In this challenge you will run queries such as comparing the sales of a particular product in real time, or combining sales and customer data to analyze spending habits.
- Challenge 4: **[Building a Demand Forecast](solution-04.md)**
   - In this challenge you will use BigQuery ML to build a model to forecast the demand for products in store.
