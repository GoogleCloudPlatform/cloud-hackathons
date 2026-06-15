# Custom ADK Agents and Gemini Enterprise app

## Introduction

In this hack, you will step into the shoes of a developer tasked with building an agentic solution for Sara, a Product Owner at a retail bank. Sara needs to track and analyze performance metrics for a newly launched banking product. Instead of relying on static dashboards or waiting for manual database reports, she wants a conversational interface that can securely interact with live banking data in real-time.

To solve this end-to-end business problem, you will leverage the *Agent Development Kit (ADK)* to build a custom AI agent, run and test it securely on Google Cloud's enterprise-grade infrastructure, and deliver it directly to Sara inside her existing *Gemini Enterprise* workspace.

![Architecture Overview](./images/ge-adk-arch.png)

## Learning Objectives

1. Set up and test an ADK agent locally.
2. Integrate BigQuery using a secure *MCP (Model Context Protocol) server* for natural language database querying.
3. Deploy and host agents securely in Google Cloud using *Agent Runtime* with managed Agent identities.
4. Integration with Gemini Enterprise app.
5. Implement A2UI for data visualization.

## Challenges

- Challenge 1: Getting Started with ADK
  - Clone skeleton code, run it locally in Cloud Shell.
- Challenge 2: What's the date?
  - Implement a basic custom function tool in Python to fetch the current date.
- Challenge 3: Talking to BigQuery
  - Connect the Google-managed *BigQuery MCP Server* to query banking data using natural language.  
- Challenge 4: Agent Runtime
  - Deploy your agent to Agent Runtime and configure secure identity and access.
- Challenge 5: Gemini Enterprise Integration  
  - Make the agent A2A compatible and register it as a custom agent in the Gemini Enterprise app.
- Challenge 6: Visualizing Data (A2UI)
  - Generate and visualize charts directly in the chat interface using native A2UI.  

## Prerequisites

- Access to a Google Cloud Project with the required APIs enabled.  
- Cloud Shell environment.  
- Familiarity with Python and basic SQL.

## Challenge 1: Getting Started with ADK

### Introduction

Before building advanced features, you need to understand the foundation. The [Agent Development Kit (ADK)](https://adk.dev/) is an open-source framework designed to help developers build, test, and run production-ready AI agents.

In this challenge, you will configure your local development environment by running an ADK agent inside Cloud Shell before we scale our architecture to the cloud.

### Description

We've already prepared a code base for you and put it in a Git repository (your coach will provide you the link). Clone that on Cloud Shell, create a virtual environment, activate it and install the Python dependencies from the `requirements.txt`. Configure the agent to use *user credentials* for local development through Agent Platform (formerly known as Vertex AI).

Once everything is set up, run `adk web` and make sure that the agent responds back.

### Success Criteria

- The Git repository has been cloned to Cloud Shell.  
- You get no errors when you greet the agent from the `adk web` UI.  
- No code was modified.

### Tips

- The utility `adk web` is part of ADK CLI that gets installed when you install the dependencies in your virtual environment.
- Newer versions of the `adk web` feature require you to set the `--allow_origins` to `"*"` to prevent CORS errors.

### Learning Resources

- [Cloud Shell](https://cloud.google.com/shell/docs/launching-cloud-shell)  
- [Cloud Shell Editor](https://cloud.google.com/shell/docs/launching-cloud-shell-editor)  
- [Previewing web apps](https://cloud.google.com/shell/docs/using-web-preview)
- [Creating and activating Python virtual environments](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/#create-and-use-virtual-environments)
- [Setting up authentication for ADK](https://adk.dev/agents/models/google-gemini/#google-cloud-agent-platform)
- [ADK CLI](https://adk.dev/api-reference/cli/#adk)

## Challenge 2: What's the date?

### Introduction

Large Language Models (LLMs) are incredibly capable, but they are limited to the data they were trained on, meaning they don't have access to real-time information or the ability to execute actions. To overcome this, agents use *Tools*.

Tools are basically external interfaces (functions, APIs, or scripts) that the agent can invoke dynamically when it needs real-time context. To see this in action, you will write a custom Python function to get the current date, allowing the agent to handle references such as last month, last quarter based on current date.

### Description

At the moment if our users would ask our agent the current date, it would emit a date from the past. In order to make our agent aware of the current date, we'll introduce a new *function tool* that dynamically calculates and returns the current date.

Create a new Python function `get_current_date` that returns the current date in `YYYY-MM-DD` format. Add a [docstring](https://peps.python.org/pep-0257/#one-line-docstrings) to that function explaining what it returns and in which format. Make that function available as a tool to the agent.

Commit and push your changes to the Git repository when you're done.

### Success Criteria

- When you ask the agent what the current date is, it returns today's date (it's okay if the UI shows it formatted differently, but the tool output should be the correct format).
- All the changes are committed and pushed to the Git repository.

### Tips

- The ADK web UI lets you inspect every step, you can hover over the steps and see the details.

### Learning Resources

- [Example function tool in ADK](https://adk.dev/tools-custom/function-tools/#example)

## Challenge 3: Talking to BigQuery

### Introduction

Sara's goal is to analyze how the new banking product is performing, which requires querying a company data store. Since she is a product owner, not a database administrator, she wants to use natural language instead of SQL.

Writing custom code to map user queries to database schemas can be incredibly tedious. Instead, we'll let our model generate the SQL queries and use a tool to access the underlying data source and run queries.

We could build our own tool as we did in the previous challenge, but there's also a plethora of tools available built by others. This is where the *Model Context Protocol (MCP)* plays a role; it offers a standardized abstraction layer for tools so that any agent can use them.

For this challenge we'll use the the Google-managed *BigQuery MCP Server* to access the company data source with customer data.

### Description

Integrate the *BigQuery MCP Server* into your ADK agent. Once the agent is equipped with the BigQuery MCP tools, and can run SQL queries successfully, commit and push your changes.

### Success Criteria

- Ask the agent: *How many accounts were created in the last quarter?*. This should successfully retrieve the result from BigQuery (around 150, exact numbers might be different to randomly generated data).
- Verify the agent utilizes the MCP tools to inspect and query the database under the hood.
- All the changes are committed and pushed to the Git repository.

### Tips

- Keep in mind that this MCP server is a remote server available through Streamable HTTP.

### Learning Resources

- [MCP Toolset in ADK](https://adk.dev/tools-custom/mcp-tools)
- [BigQuery MCP Server Reference](https://docs.cloud.google.com/bigquery/docs/reference/mcp)

## Challenge 4: Agent Runtime

### Introduction

Running agents locally with personal user credentials is great for prototyping, but enterprise-grade business applications require a secure, reliable, and scalable hosting environment.

In this challenge, you will move your agent off your local machine and deploy it to Google Cloud's *Agent Runtime* (part of the Gemini Enterprise Agent Platform). You will configure a dedicated *Agent Identity*, a managed principal, and grant it the precise, minimum IAM permissions required to access BigQuery. This ensures your agent runs securely under its own cloud identity without exposing personal user credentials.

### Description

Deploy your agent to Agent Runtime, using the ADK CLI. Make sure that the Agent Runtime uses Agent Identity.

Grant the required permissions to the identity of the Agent so that it can read data from and run jobs on BigQuery, and can use the BigQuery MCP tools.

Once the agent on Agent Runtime can successfully answer questions that require accessing BigQuery, commit and push your changes.

### Success Criteria

- Ask the agent on Agent Runtime: *How many customers do we have in total?*. This should run a query on the `customers` table and return `1000`.
- All the changes are committed and pushed to the Git repository.

### Tips

- Agent Runtime used to be called Agent Engine, some ADK CLI options still use that terminology
- If you need to redeploy your agent, provide the `--agent_engine_id` option so that it *replaces* your deployment (and doesn't create a new agent with a new identity)
- You can use the *Playground* section in Agent Runtime interface to have a similar experience as locally testing through ADK web UI.
- Easiest option to configure the Agent Identity is to through the agent config file `.agent_engine_config.json`.

### Learning Resources

- [Deploying with ADK CLI](https://adk.dev/api-reference/cli/#adk-deploy)
- [Creating an Agent with Agent Identity](https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/agent-identity#create-agent-identity)

## Challenge 5: Gemini Enterprise Integration

### Introduction

Our agent is only useful if business users can easily access it. Instead of forcing Sara to open a terminal or use a developer-focused console, we want to deliver this agent directly into the communication hub she uses every day: the *Gemini Enterprise* app.

### Description

First create a new Gemini Enterprise app instance (use the 30-day trial option) and choose Google Identity when setting up identity.

Add our agent to the Gemini Enterprise app through the *Custom agent via Agent Runtime* option, and verify that the agent is available and functional from Gemini Enterprise app.

### Success Criteria

- In the Gemini Enterprise app, ask the agent: "What was the adoption rate of Advantage Plus accounts last quarter?" and verify that the agent returns something like `90%` (exact numbers might vary due to random data).

### Tips

- You can see all the sessions and their details in Agent Runtime UI under the *Sessions* section, including the ones started from Gemini Enterprise app.

### Learning Resources

- [Creating a Gemini Enterprise app](https://docs.cloud.google.com/gemini/enterprise/docs/create-app)
- [Registering a custom agent in Gemini Enterprise app](https://docs.cloud.google.com/gemini/enterprise/docs/register-and-manage-an-adk-agent)

## Challenge 6: Visualizing Data (A2UI)

### Introduction

While reading numbers or CSV tables in a chat window is helpful, business trends are best understood visually. Sara wants to see product performance represented in clean, interactive charts.

Traditionally, displaying visualizations from a chat agent required building bespoke web applications or executing unsafe client-side scripts. The *Agent-to-User Interface (A2UI)* project solves this by defining an open, secure, and declarative standard for rendering native interface components.

### Description

In principle our agent could generate A2UI specs (the declarative model for a UI) if we prompted it properly. However, we're going to keep things simple, and we'll put the data in A2UI format ourselves using the ADK callback functionality.

Update the agent instructions to return data in csv format surrounded with `<bar_chart></bar_chart>` tags *only* when the user asks for a bar chart. Here's an example:

```text
<bar_chart>
category,amount
A, 5
B, 20
C, 35
D, 15
</bar_chart>
```

We've already provided a function that can detect these blocks in the model response and replace them with A2UI components. Go ahead and make sure that this function is called after the model is run.

Verify that a bar chart is generated on the Gemini Enterprise app when the user request a bar chart.

Finally commit and push your changes.

### Tips

- If you update your existing deployment, Gemini Enterprise app will use the latest version of your agent. But if you create another deployment, you'll need to grant the required roles to run queries as you'll have a new Agent Identity and you'll have to add the new Agent to the Gemini Enterprise app.

### Success Criteria

- Ask the agent: "Generate a bar chart showing the number of customers for each account type." and verify that a bar chart is rendered in the interface.  
- All the changes are committed and pushed to the Git repository.

### Learning Resources

- [ADK Callbacks](https://adk.dev/callbacks/)
