# Intro to CCAI and Conversational Agents

## Introduction

This hack will be an introduction to the world of Contact Center modernization and will teach you how to build a robust chat agent using Google's Conversational Agents platform.

![Architecture](./images/architecture.png)

You will be building a virtual agent for the HR department of a company called Piped Piper. Your agent will be the central place for employees to find authoritative answers on company policies as well as place to get data from other internal systems (eg. Workday for PTO days balance). This agent will demonstrate how a company can increase employee productivity by centralizing access to knowledge - data stored in internal data sets as well as API driven systems - all accessed using natural language from a single chat.

## Learning Objectives

In this hack you will be solving a common problem of standing up a virtual chat agent - useful in many instances to help a company's internal as well as external users. More specifically we will be exploring the foundations for Google's Contact Center AI (CCAI) and the tool for building agents called Conversational Agents (formerly DialogFlow CX).

In this hack you will:

1. Create your first agent 
1. Set up a basic Playbook to detect an escalation scenario
1. Set up an authoritative knowledge base using internal HR policy documentes to help answer questions
1. Create an external system API call for data we can use in responses

## Challenges

- Challenge 1: First Agent On The Scene
   - Create and initialize a Conversational Agent
- Challenge 2: What's the Game Plan?
   - Set up a basic Playbook to detect an escalation scenario
- Challenge 3: Getting Smarter
   - Give the agent access to PDF documents to use in chat answers
- Challenge 4: Agent Phone Home
   - Call an external system's API for knowledge

## Prerequisites

- Basic knowledge of GCP
- Access to a GCP environment

## Contributors

- Roman Mezhibovski
- Gino Filicetti
- Lexi Flynn

## Challenge 1: First Agent On The Scene

### Introduction

This challenge is all about setting up and getting our agent configured.

### Description

First download the files we'll be using in the rest of this gHack from [this link](https://github.com/gfilicetti/ccai-virtual-agents/archive/refs/heads/main.zip). Unzip the zip file and keep the files handy, they will be needed in various challenges.

Create a new agent in the Dialogflow CX Console. Test your agent with a simple "hello" message.

Use the DialogFlow Messenger Integration to create a chat bubble on the provided `agent-page.html` page so that your agent is reachable via a web page.

Host the webpage on a webserver running in CloudShell and test it in a browser to make sure the chat bubble appears and works.

### Success Criteria

- An agent is created in your project
- The agent can respond to an "Hello" message
- Dialogflow Messenger agent widget is responding similarly to "Hello" messages on a webpage

### Tips

- Don't forget! You can upload files to your Cloud Shell and even expose ports to make it available in your browser.

### Learning Resources

- [Dialogflow Basics](https://cloud.google.com/dialogflow/cx/docs/basics)
- [Testing Agents](https://cloud.google.com/dialogflow/cx/docs/concept/test-case)
- [CloudShell - Manage Files](https://cloud.google.com/shell/docs/uploading-and-downloading-files)
- [Running a Webserver](https://realpython.com/python-http-server/)
- [CloudShell - Preview Webservers](https://cloud.google.com/shell/docs/using-web-preview)


## Challenge 2: What's -YOUR- Intent?

### Introduction

In this challenge we will train our agent on "Intents". These are things we want our agent to understand from human language and act on deterministically. 

### Description

Create a new Intent for the agent to handle escalations. We want to train the agent on certain phrases that would cause it to 'understand' that the human in the chat wants help from a live agent. 

> **NOTE:** Try to use at least 6 training phrases when creating the intent 

> **NOTE:** It could take a few minutes for the new training phrases to be picked up by the agent

Create a new Route to hold the escalation intent with an appropriate agent response.

### Success Criteria

- A new escalation Intent is created
- A new Route is created for the esclation Intent 
- The Agent responds appropriately to the new escalation Intent
- The Agent continues to respond normally to "hello" messages

### Learning Resources

- [Dialogflow Intents](https://cloud.google.com/dialogflow/cx/docs/concept/intent)
- [Dialogflow Fulfillments](https://cloud.google.com/dialogflow/cx/docs/concept/fulfillment)


## Challenge 3: Getting Smarter

### Introduction

In this challenge we enable the Agent to handle questions based on Piped Piper's HR policy documents.

### Description

Create a data store with the PDF HR documents provided.

> **NOTE:** Indexing the documents will take about 5-10 minutes

Add the new data store to the Agent.

### Success Criteria

- A data store is created and has indexed your documents
- The Agent is connected to the data store 
- The Agent can respond to questions answerable by the HR policy documents

### Learning Resources

- [Data Store Agents](https://cloud.google.com/dialogflow/vertex/docs/concept/data-store-agent)


## Challenge 4: Time for GenAI

### Introduction

In this challenge we will use Google's Gemini to enhance the Agent's responses and make it more interactive.

### Description

Create a new Generator for the Default Welcome Intent Route. This Generator will create more human-like welcome messages and make sure that only that response is generated for this intent/route.

### Success Criteria

- There is a Generator created with a prompt that responds with human-like welcome messages
- The Agent uses the new Generator 
- **NOTE/TODO** - need more descriptive success critieria

### Learning Resources

- **NOTE/TODO** - need learning resources for this challenge


## Challenge 5: Agent Phone Home

### Introduction
 
In this challenge we see how to use Gemini to translate between natural language questions and an API call. This will let the Agent answer questions based on data found in an external system it can only get by an API call.

### Description

Create a new Intent for answering a question about Piped Piper's vacation days policy. Create a webhook that will get answers from the `vacation-days` Cloud Function (acting as a placeholder for a real CRM). Create two generators; one for translating the user question into an API call to the webhook, the other for translating the response JSON and answering the initial user question.

### Success Criteria 

- Agent has a webhook that can call the provided cloud function code
- Agent can send questions about vacation policy to the webhook
- Agent can provide correct answers based on webhook's JSON response

### Learning Resources
- [Dialogflow CX Webhooks](https://cloud.google.com/dialogflow/cx/docs/concept/webhook)

