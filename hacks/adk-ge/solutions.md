# Gemini Enterprise with ADK - Coach's Guide

## Introduction

This guide provides notes, guidance, and solutions for the Gemini Enterprise with ADK gHack, utilizing the BigQuery MCP Server.

## Challenge 1: Getting Started with ADK

### Notes & Guidance

Participants should clone the repository and run it locally:

```shell
# Clone the skeleton code
git clone https://source.developers.google.com/p/$GOOGLE_CLOUD_PROJECT/r/ghacks-adk-banking
cd ghacks-adk-banking
# Region for Agent Runtime deployment, used later
REGION=us-central1
# Authentication
cat > retail_bank_agent/.env <<EOF
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT
GOOGLE_CLOUD_LOCATION=$REGION
EOF
# Python virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r retail_bank_agent/requirements.txt
# Start the preview interface
adk web --allow_origins="*"
```

## Challenge 2: What's the date?

### Notes & Guidance

Participants implement a basic custom function tool that returns the current date using Python's datetime.

```python
from datetime import date

from google.adk import Agent

from . import helpers


def get_current_date() -> str:
    """Returns the current date in YYYY-MM-DD format.
    
    Returns:
        The current date as a string.
    """
    return date.today().strftime("%Y-%M-%d")


root_agent = Agent(
    model=helpers.MODEL,
    name="root_agent",
    description="A helpful assistant for Retail Bank performance related questions.",
    instruction=f"""
        You are an expert Retail Banking Data Analyst and answer questions by grounding them in data.
        Use project {helpers.PROJECT_ID} and dataset {helpers.DATASET_ID} as your context.
    """,
    tools=[get_current_date]
)
```

## Challenge 3: Talking to BigQuery

### Notes & Guidance

Instead of the built-in `BigQueryToolset`, participants will use the *BigQuery MCP Server* through ADK's `McpToolset`.

```python
from google.adk.tools.mcp_tool import McpToolset
from google.adk.tools.mcp_tool import StreamableHTTPConnectionParams


mcp_toolset = McpToolset(
    connection_params=StreamableHTTPConnectionParams(
        url="https://bigquery.googleapis.com/mcp"
    ),
    header_provider=helpers.get_auth_headers
)


root_agent = Agent(
    model=helpers.MODEL,
    name="root_agent",
    description="A helpful assistant for Retail Bank performance related questions.",
    instruction=f"""
        You are an expert Retail Banking Data Analyst and answer questions by grounding them in data.
        Use project {helpers.PROJECT_ID} and dataset {helpers.DATASET_ID} as your context.   
    """,
    tools=[get_current_date, mcp_toolset]
)
```

## Challenge 4: Agent Runtime

### Notes & Guidance

To deploy to Agent Runtime (Agent Platform):

```shell
adk deploy agent_engine --agent_engine_id="..." retail_bank_agent
```

TODO permissions

## Challenge 5: Gemini Enterprise Integration

### Notes & Guidance

Make the agent A2A compatible using `to_a2a`.

```python
from google.adk.a2a.utils.agent_to_a2a import to_a2a

# In the entry point of the server
to_a2a(root_agent)
```

Register the agent in the Gemini Enterprise console using the deployed A2A endpoint.

## Challenge 6: Visualizing Data (A2UI)

### Notes & Guidance

Since we've already provided most of the functionality in a function, all you have to do is to use the correct callback configuration, which is in this case `after_model_callback`. In addition we'll have to instruct the agent to generate the data in the right format so that it gets detected/parsed properly.

```python
root_agent = Agent(
    model=helpers.MODEL,
    name="root_agent",
    description="A helpful assistant for Retail Bank performance related questions.",
    instruction=f"""
        You are an expert Retail Banking Data Analyst and answer questions by grounding them in data.
        Use project {helpers.PROJECT_ID} and dataset {helpers.DATASET_ID} as your context.
        If and only if the user requests a bar chart, return the answer in csv format surrounded with 
        <bar_chart> and </bar_chart>. Include the names of the columns as a header in the csv.
   
    """,
    tools=[mcp_toolset],
    after_model_callback=helpers.convert_to_a2ui
)
```
