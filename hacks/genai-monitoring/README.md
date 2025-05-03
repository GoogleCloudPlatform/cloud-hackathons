# Production monitoring of GenAI Features with Firebase Genkit

## Introduction

Want to master the art of keeping Firebase Genkit LLM applications alive and thriving in the real world? This hackathon puts you in the driver's seat of production monitoring for Large Language Model (LLM) powered applications. Assuming the role of a Site Reliability Engineer (SRE) on a fictional Movie Guru app team, you will use Firebase Genkit Monitoring to tackle the critical challenges of ensuring LLMs perform flawlessly in production. You'll dive deep into troubleshooting live issues, optimizing performance bottlenecks, and guaranteeing a smooth user experience for a movie recommendation app. 

Why is this crucial? Because in the age of AI, those who can effectively monitor and manage LLM applications in production are the ones who will build the future. The GenAI monitoring, debugging, and optimization skills you'll gain are universally applicable for a modern SRE and are transferable to a wide range of systems beyond Genkit Monitoring.

“GenAI App Development with Genkit” is a recommended pre-requisite.

## Learning Objectives

This is going to be an introduction to running apps on Cloud Run. We'll dive into various aspects of app development using cloud native tooling on GCP.

- Understand your GenAI app health in production 
- Troubleshoot different types of GenAI issues that might arise like model limitations, latency, hallucinations, …
- Find and address issues associated with the quality of your generated content

## Challenges

- Challenge 1: Set up your environment and interact with the app
- Challenge 2: Exploring Monitoring dashboard
- Challenge 3: Troubleshooting failures
- Challenge 4: Improving performance

## Contributors

Manasa Kandula Esther Lloyd Cleo Schneider Polina Govorkova

## Challenge 1: Set up your environment and interact with the app

### Introduction

Welcome to the Movie Guru team! In your role as a Site Reliability Engineer on this team, you will work through the challenges to ensure that the app is reliable and performant. 
Your first task is to get the application running smoothly in your local environment. You'll set up your development environment using the Cloud Shell editor and interact with the initial version of the Movie Guru application, ensuring a stable starting point for the system.

### Firebase setup

To use Firebase Genkit and Genkit Monitoring, you'll need to set up a web app in Firebase.

- Go to the **Firebase Console** and create a new Firebase Web App in the *existing* project.

### Clone the Repository and set the environment variables

> **Note** Run this step on the computers of all your team mates.

- Open the **Cloud Shell Editor** and type the following commands.

```sh
git clone https://github.com/MKand/movie-guru.git
cd movie-guru
git checkout ghack-genkit-monitoring
```

- Update the **set_env_vars.sh** to reflect your environment.

### Cloud setup

The following script enables the required APIs, creates the necessary service account with roles, and uploads movie poster images to a GCP bucket on your behalf.

- Edit the **set_env_vars.sh** to replace project_id.


- Run setup script.

    ```sh
    chmod +x setup_cloud.sh
    ./setup_cloud.sh --skip-infra #the qwiklab environment has already created the infra for you
    ```

### Database Setup

The app uses PostgreSQL with the pgvector extension to store movie description embeddings and structured data (title, plot, release date, etc.)

- Create a shared docker network for all the app containers we will use to run this application.

    ```sh
    docker network create db-shared-network
    ```

- Setup local *pgvector* DB

    ```sh
    chmod +x setup_local.sh
    source setup_local.sh
    docker compose -f docker-compose-pgvector.yaml up -d
    ```

### Run the Application

- Start the application services. This can take a few minutes as we are building many docker images for all the application containers (frontend, webserver, Genkit flows).

    ```sh
    source set_env_vars.sh
    docker compose up --build
    ```

In the meantime, explore how the application operates by examining this architecture diagram and corelating it with the codebase contents:
![Architecture diagram](images/architecture-diagram.png)

- Access the Frontend Application Open <http://localhost:8080> in your browser. If you are using the cloud shell editor, view the website by clicking on the **WebPreview** button on the top right of the editor and selecting port **8080**.

> **Note** Please note that we are running this in the lab environment which makes the application a lot slower and more unpredictable due to the rate limits.

### Test the app

- Login using your name (without spaces).

- Interact with the app and get your first movie recommendation. Then spend time getting to know the Movie Guru application by sending it different prompts.

  - Does it respond in the ways you expect?
  - Does it give reasonable recommendations?

- Run the following two queries:

  - “Show me some funny films” (or another genre)
  - “Show me movies with ratings greater than 3”. (or another rating)
  - Is there a difference in the number of recommendations you get for these two types of queries? Can you figure out where this difference comes from.

### Success Criteria

- Your local environment is set up in Cloud Shell.
- All your teammates have clone the code repo into their own enviroments.
- You are able interact with the Movie Guru app running on your local Cloud Shell instance.
- You notice that the genre based query has more results than the rating based query.

### Learning Resources

- [Genkit](https://firebase.google.com/docs/genkit)
- [Setting up firebase web app](https://firebase.google.com/docs/projects/use-firebase-with-existing-cloud-project#how-to-add-firebase_console)


## Challenge 2: Exploring Monitoring dashboard

### Prerequisites

- Make sure you have completed the steps *Clone the Repository and set the environment variables* on the machine which is executing this challenge.
- If you want to run the application locally, also run the *Database Setup* and the *Run the Application* steps.

### Introduction

Before we dive into troubleshooting, it's essential to get familiar with the tools we'll be using. In this challenge, you'll explore the Genkit monitoring dashboard. This will involve navigating its different sections, understanding the types of data it displays, and learning how to interpret the information presented. This foundational knowledge is crucial for effectively diagnosing and resolving issues in the subsequent challenges.

### Description

The Genkit monitoring dashboard provides essential insights into your application's performance and execution. This challenge asks you to explore the dashboard and achieve specific goals based on your discoveries.

Use the Genkit monitoring dashboard to understand the performance and behavior of your application by achieving the following goals:

- Access and navigate to the Genkit monitoring dashboard for your deployed application.
- Identify the key aggregate stability metrics displayed for the entire project and interpret what they indicate about the overall health of your application.
- What are the individual GenAI **features** in your app and what are the performance indicators (metrics) shown for each.
- What is the specific feature that handles the *core user interactions* in the MovieGuru app and what metrics can you find about it?
- By examining an individual execution (a trace) of the user interaction feature, what information can you identify about the sequence of steps that occurred and the specific details recorded for each step?
- What are the most notable differences in the execution paths of user queries (e.g., a question requiring a movie recommendation versus a simple greeting)?
- From the detailed view of a trace, discover how to access the related data within Google Cloud Logging and Google Cloud Trace, and observe any differences or similarities in how the data is presented across these various tools.

### Success Criteria

- You are now familiar with key sections of Firebase Genkit Monitoring dashboard
- You know the different features that comprise the **movieguru** app and what they do.
- You know the different steps that the app takes to answer a user's query.
- You know how the steps differ when the user makes a query that requires a search versus one that doesn't.
- You can correlate data in the monitoring dashboard with data in Cloud

### Learning Resources

- [Genkit Monitoring](https://firebase.google.com/docs/genkit/observability/getting-started)
- [Tracing](https://opentelemetry.io/docs/concepts/signals/traces/)
- [Observability on Google Cloud](https://cloud.google.com/stackdriver/docs)
- **Genkit Feature**

    In the context of Genkit monitoring and observability, a **feature** represents a distinct, identifiable functional component or capability within your Genkit application.

    These features serve as logical units for which performance metrics (such as request count, success rate, and latency) and execution traces are aggregated and displayed in the Genkit monitoring dashboard.

    Think of a feature as a specific task or workflow segment that you want to observe and analyze independently. Examples in an application could include:

  - Handling a specific type of user query (e.g., "Movie Search").
  - Executing a particular agentic step or tool use.
  - Processing a specific data loading or transformation task.

    By breaking down your application's execution into features, the monitoring dashboard allows you to quickly assess the health and performance of individual components.

## Challenge 3: Troubleshooting failures

### Prerequisites

- Make sure you have completed the steps *Clone the Repository and set the environment variables* on the machine which is executing this challenge.
- If you want to run the application locally, also run the *Database Setup* and the *Run the Application* steps.

### Introduction

Now that you're familiar with the Genkit monitoring dashboard, it's time to put those skills to the test. Our movie recommendation app is having a few issues. In this challenge, you'll use your knowledge of the dashboard to investigate these errors that are disrupting the application's functionality and try and fix them.

### Description

A feature of the *MovieGuru* app is experiencing a high volume of errors, impacting its success rate.
Your tasks are to use the Genkit monitoring dashboard and the code (*/js/flows*) to pinpoint the main cause of these failures.
Additionally, you noticed in *challenge 1* that queries for movies based on *ratings* yeilds fewer results than queries based on *genre*. You will also figure out why this is happening.

- Identify the feature most failures.
- Identify what these failures have in common? Hint: use feature paths table.
- Identify the underlying cause of each of these failures?
- Implement a fix for these failures (hint: look through the code to find the source of the issue).
- Identify why there are fewer results for the *ratings* based search.

### Success criteria

- You have idenfified the feature with the most failures.
- You understand the root case of these failures.
- You have implemented a fix, restarted the application, and retried search queries to show that the error no longer occurs
- You understand why there are fewer results for the *ratings* based search.

### Learning resources

- [Input and Output schemas in genkit prompts](https://firebase.google.com/docs/genkit/dotprompt#schemas)
- [Input and Output schemas in genkit flows](https://firebase.google.com/docs/genkit/flows#input_and_output_schemas)
- [RAG and Retrievers](https://firebase.google.com/docs/genkit/rag)
- **Prompts and Flows in Genkit**:
  
    A *flow* is the executable unit – it defines and orchestrates a sequence of steps (the process) and can contain multiple sub-steps like other flows, prompts, retrievers, tools, etc.

    A *prompt* is data – the input sent to an AI model plugin within a step of that flow, and the output received from the model in that step.

    So, you execute a flow, and within the flow's steps, prompts are used to interact with AI models. They differ because the flow is the action that runs, while the prompt is the content exchanged during a specific step involving an AI model.

    Both flows and prompts can have their own input and output data schemas.
- **Useful docker compose commands**
  - To build and run containers defined in a dockercompose.yaml file, use `docker compose up --build`. Find more info [here](https://docs.docker.com/compose/reference/up/).

  - To bring down running containers defined in a dockercompose.yaml file, use `docker compose down`. Find more info [here](https://docs.docker.com/compose/reference/down/).


## Challenge 4: Improving performance

### Prerequisites

- Make sure you have completed the steps *Clone the Repository and set the environment variables* on the machine which is executing this challenge.
- If you want to run the application locally, also run the *Database Setup* and the *Run the Application* steps.

### Introduction

Now that you are familiar with the Firebase Genkit Monitoring dashboard, and have dealt with a major cause of failures, your users can finally chat with the chatbot with no trouble, but is it the best experience? Even with code failures gone, users may get frustrated and leave the app if it is painfully slow, or doesn't give enough recommendations (like with queries based on ratings). Let's fix these issues here.


### Description

Let's inspect the performance of the Movie Guru app using Firebase Genkit Monitoring.

- What is the slowest feature in our app? What is the P50 and P90 latency for that feature and what does that mean?
- Inspect individual traces in that feature and identify areas for improvement.
- Come up with ideas for how to improve latency and implement them.
- Are there ways you can improve the number of results on searches based on rating? If so, try and implement them.

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
