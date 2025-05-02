# Production monitoring of GenAI Features with Firebase Genkit

## Introduction

Want to master the art of keeping Firebase Genkit LLM applications alive and thriving in the real world? This hackathon puts you in the driver's seat of operating Large Language Model (LLM) powered applications.
Using Genkit, you will optimse some of the LLM-based features of your app, and using Firebase Genkit Monitoring, you'll tackle the critical challenges of ensuring LLMs perform flawlessly in production. 
You'll dive deep into troubleshooting live issues, optimizing performance bottlenecks, and guaranteeing a smooth user experience for a movie recommendation app.

Why is this crucial? Because in the age of AI, those who can effectively monitor and manage LLM applications in production are the ones who will build the future.

“GenAI App Development with Genkit” is a recommended pre-requisite.

## Learning Objectives

This is going to be an introduction to running apps on Cloud Run. We'll dive into various aspects of app development using cloud native tooling on GCP.

1. Understand your GenAI app health in production.
1. Troubleshoot different types of GenAI issues that might arise like model limitations, latency, hallucinations, etc.
1. Find and address issues associated with the quality of your generated content.

## Challenges

- Challenge 1: Set up your environment and interact with the app
- Challenge 2: Get familiar with the dashboard - 20 min
- Challenge 3: Troubleshooting failures - 30 min
- Challenge 4: Optimizing latency - 30 min

## Challenge 1: Set up your environment and interact with the app

## Prerequisites

- Google Cloud Project with atleast Editor role.
- Basic knowledge of docker (it's not crucial, but we use docker to run the app containers).
- Basic coding knowledge (some node.js or other programming knowledge)

## Introduction

Welcome to the Movie Guru team! Let's get started by getting your development environment up and running.
You'll be using the Cloud Shell editor to build and deploy your the app in a cloud virtual environment and interact with it there.

## Learning Objectives

Today, you will join the Movie Guru team that has just launched the first version of their app to production. What is Movie Guru? It's the next generation of movie recommendations, forget filtering down by genre or actor. Describe what you are hoping to get out of your next movie watching experience and let Movie Guru do the rest.

You'll be using the Cloud Shell to emulate a production environment and get a sense for how you might troubleshoot real world problems. You'll dive deep into troubleshooting live issues, optimizing performance bottlenecks, and guaranteeing a smooth user experience for a movie recommendation app. At the end of this lab, you will: 

1. Understand how to use Firebase Genkit Monitoring to monitor Genkit app health in production
1. Find the issue plaguing your user base most with helpful quick filters and an in-depth trace viewer
1. Troubleshoot different types of GenAI issues that might arise like prompt inefficiency, model limitations, and high latency requests

## Description

### Introduction

Welcome to the Movie Guru team! Let's get started by getting your development environment up and running. You'll be using the Cloud Shell editor to build the app in a cloud virtual environment and interact with it there.

### Firebase setup

To use Firebase Genkit and Genkit Monitoring, you'll need to set up a web app in Firebase.

1. Go to the **Firebase Console** and create a new Firebase Web App in the *existing* project.

### Clone the Repository and set the environment variables

> **Note** Run this step on the computers of all your team mates.

1. Open the **Cloud Shell Editor** and type the following commands.

```sh
git clone https://github.com/MKand/movie-guru.git
cd movie-guru
git checkout ghack-genkit-monitoring
```

1. Update the **set_env_vars.sh** to reflect your environment.

### Cloud setup

The following script enables the required APIs, creates the necessary service account with roles, and uploads movie poster images to a GCP bucket on your behalf.

1. Run setup script.

    ```sh
    chmod +x setup_cloud.sh
    ./setup_local.sh --skip-infra #gHack creates the infra for you
    ```

### Database Setup

The app uses PostgreSQL with the pgvector extension to store movie description embeddings and structured data (title, plot, release date, etc.)

1. Create a shared docker network for all the app containers we will use to run this application.

    ```sh
    docker network create db-shared-network
    ```

2. Setup local *pgvector* DB

    ```sh
    chmod +x setup_local.sh
    source setup_local.sh
    docker compose -f docker-compose-pgvector.yaml up -d
    ```

### Run the Application

1. Start the application services. This can take a few minutes as we are building many docker images for all the application containers (frontend, webserver, Genkit flows).

    ```sh
    source set_env_vars.sh
    docker compose up --build
    ```

In the meantime, think through these questions with your group:
[Some questions about it]

1. Access the Frontend Application Open http://localhost:8080 in your browser. If you are using the cloud shell editor, view the website by clicking on the **WebPreview** button on the top right of the editor and selecting port **8080**.

> **Note** Please note that we are running this in the lab environment which makes the application a lot slower and more unpredictable due to the rate limits.

### Test the app

Use your name (without spaces) to log in.

1. Interact with the app and get your first movie recommendation. Then spend time getting to know the Movie Guru application by sending it different prompts.

- Does it respond in the ways you expect?
- Does it give reasonable recommendations?

1. Run the following two queries:

- “Show me some funny films” (or another genre)
- “Show me movies with ratings greater than 3”. (or another rating)
- Is there a difference in the number of recommendations you get for these two types of queries? Can you figure out where this difference comes from.

### Success Criteria

After installation, run the following command to ensure that Genkit is installed correctly.

## Contributors

Manasa Kandula Esther Lloyd Cleo Schneider Polina Govorkova

## Challenge 2: Exploring Monitoring dashboard

### Prerequisites

Before beginning this challenge, complete [Challenge 1: Set up your environment and interact with the app]() to seed data in the dashboard.

### Introduction

Before we dive into troubleshooting, it's essential to get familiar with the tools we'll be using. In this challenge, you'll explore the Genkit monitoring dashboard. This will involve navigating its different sections, understanding the types of data it displays, and learning how to interpret the information presented. This foundational knowledge is crucial for effectively diagnosing and resolving issues in the subsequent challenges.

### Description
The Genkit monitoring dashboard provides a wealth of information about our application's performance. Your task is to explore the dashboard and familiarize yourself with its key components.
Navigate to the Genkit monitoring dashboard for your deployed application.
Identify the key sections of the dashboard, such as:
Aggregate stability metrics for the project broken down by features (requests, success rate, latency).
Features table, which includes information about individual features
Explore the concept of the feature by digging deeper into the `[NAME OF THE FEATURE]`: click into a single feature within the table to open a feature-centric view and identify the key sections, such as:
Aggregate metrics, including consumption metrics
Failed paths table
Traces table, which includes information about individual traces
Explore the concept of the trace by digging deeper into the one of the traces: click into a single trace within the table to open a trace-centric view and identify the key sections, such as:
Trace span tree
Span details
After exploring all this data, try to answer the following questions
What is a feature?
What is a trace?
Compare your answers to those officially shown in the documentation.
In the trace view, open up the hamburger menu to reveal “Open in Cloud Logging” and “Open in Cloud Trace” menu options. Navigate to both to observe the same data in the CloudOps. Your Cloud project is the place Genkit stores your data, which is then queried into the Genkit Monitoring dashboard.
### Success Criteria

You are now familiar with key sections of Genkit Monitoring dashboard
You now understand what kind and how information is organized in the dashboard
You can correlate data in the monitoring dashboard with data in the Cloud
### Tips
Hover on question marks next to elements to reveal more details
Note any unfamiliar concepts and open up documentation to check your understanding.


### Learning resources
Genkit Monitoring Documentation
Documentation for underlying monitoring tools (Cloud Metrics, Logging, and Trace)

## Challenge 3: Troubleshooting code failures [DRAFTED]

### Prerequisites

Before beginning this challenge, 
complete [Challenge 1: Set up your environment and interact with the app] to seed data in the dashboard.
complete [Challenge 2: Exploring Monitoring dashboard] to familiarize yourself with the monitoring dashboard.

### Introduction

Now that you're familiar with the Genkit monitoring dashboard, it's time to put those skills to the test. Our movie recommendation app is showing a low success rate, indicating that errors are occurring. In this challenge, you'll use your knowledge of the dashboard to investigate these errors that are disrupting the application's functionality.

### Description
The movie recommendation app is experiencing a high volume of errors, impacting its success rate. Your task is to use the Genkit monitoring dashboard to pinpoint the main cause of these failures.
Investigate the aggregate metrics on the project-level monitoring page to identify all failing features.
First, identify the most problematic feature. 
Understand the impact of addressing this issue. How much will your overall success rate improve if you solved the errors for that feature?
View feature details, which now has a “Failed paths” section to help you identify all trace variations that led to the bad response. What insight does the feature path give you?
Filter traces down to failures and examine feature outputs, which display error traces. 
Identify the issue. Through your analysis of the traces, pinpoint the location and nature of the schema mismatch.
Implement a fix in the application code to correct the schema mismatch.
For this, copy full input directly from the monitoring dashboard within a trace-centric view.
Now, let’s look at the second feature that’s causing problems.
Use the same techniques to narrow down the failing feature traces and examine errors in the feature output to diagnose problems. 
You may not always have control over quota handling. In your code, implement graceful handling of the issue by hard-coding the following joke as a response: [JOKE GOES HERE]
Validate your fix by running input from the failed traces.
### Success criteria
You can now  use the Genkit monitoring dashboard to compare feature success rate and identify failed paths.
You understand how to use failed paths filtering to find relevant failed traces.
### Tips
Look for clues in error messages, data types, or data formats within the traces.
Use the filtering and search capabilities of the monitoring dashboard to efficiently locate relevant information.
Remember that schema mismatches often occur when data is exchanged between different parts of the application or between the application and external services (like an LLM API).
### Learning resources
Documentation on running DevUI

## Challenge 4: Optimizing request latency

### Prerequisites

Before beginning this challenge, complete [Challenge 1: Set up your environment and interact with the app]() and [Challenge 2: Troubleshooting code failures]() which will seed data in the dashboard and help you get familiar with monitoring concepts in Firebase Genkit Monitoring.

### Introduction

Now that you are familiar with the Firebase Genkit Monitoring dashboard, and have dealt with a major cause of failures, your users can finally chat with the chatbot with no trouble, but is it the best experience?

Even with code failures gone, users may get frustrated and leave the app if it is painfully slow. Let's use Firebase Genkit Monitoring to investigate whether latency could be impacting customers. Each question a user asks the chatbot requires the application to make several underlying calls to the LLM using a Retrieval Augmented Generation (RAG) architecture. When a user sends a request for a movie recommendation to our chatbot, the chat bot: 
Analyzes the request to figure out if there are new preferences expressed.
Fetches additional context from our vector DB, our relational DB, or both
Sends a prompt to the LLM that has been hydrated with the original request and fetched context

### Description

Navigate to the Firebase Genkit Monitoring dashboard for the "INSERT FEATURE NAME" feature.

To investigate this issue, you'll need to:
Look at the P50 (average) and P90 (90th percentile) latency for this feature
Use the filter bar to find traces that are >X ms
Inspect individual traces and compare high latency traces to lower latency traces

As you are investigating, you will be looking for two main issues:
Find the model step that is taking the longest amount of time
Identify steps where we could parallelize requests to make things more efficient

Once you have identified the problem areas –
Update the model step with a smaller model using this code 

```
imports

ai.generate(flashModel)
```
Update the retrieval step to retrieve in parallel

```
<TODO create code snippet>
```
Rerun your app and interact with the chatbot to send new traces
Validate that you are seeing better performance

### Success Criteria

You are now familiar with latency graphs in Firebase Genkit Monitoring.
You understand how to use the latency filters in the trace table to find high latency traces.
You can use the trace viewer to dig deeper into which steps are areas for improvement.
The code modifications have resulted in lower latency requests for the "INSERT FEATURE NAME" feature.

### Tips

Generally any model interaction is going to be the most expensive part of your request
Using smaller models can yield better performance but sometimes comes at the cost of high quality responses. Playing around with different models for your use case and comparing them in Firebase Genkit Monitoring can help you figure out the right balance.

## Challenge 6: Digging into user engagement 
