# ADK with Gemini Enterprise - Coach's Guide

## Introduction

This guide provides the solutions for the ADK with Gemini Enterprise gHack.

## Challenge 1: Getting Started with ADK

### Notes & Guidance

Participants should clone the repository. In a real scenario, this would be a Cloud Source Repository.

```shell
git clone https://source.developers.google.com/p/$GOOGLE_CLOUD_PROJECT/r/ghacks-adk-banking
cd ghacks-adk-banking
```

To run locally:

```shell
python3 -m venv .venv
source .venv/bin/activate
pip install google-adk
# Set up .env with GOOGLE_CLOUD_PROJECT, etc.
adk web app/agent.py
```

To deploy to Agent Runtime (Agent Platform):

```shell
agents-cli deploy --target agent-runtime
```

## Challenge 2: Talking to BigQuery

### Notes & Guidance

Participants need to add the `BigQueryToolset` and filter it.

**agent.py snippet:**

```python
from google.adk.tools.bigquery import BigQueryToolset

bq_toolset = BigQueryToolset(
    project_id="YOUR_PROJECT_ID",
    dataset_id="banking_data",
    tool_filter=["execute_sql"]
)

agent = Agent(
    name="banking_agent",
    instruction="You are a banking analyst. Query the banking_data.transactions table. Use ONLY the execute_sql tool.",
    tools=[bq_toolset]
)
```

**Tip:** The Agent Identity (Service Account) needs `roles/bigquery.jobUser` and `roles/bigquery.dataViewer`.

## Challenge 3: Knowledge Catalog Integration

### Notes & Guidance

Use `McpToolset` for the Knowledge Catalog.

```python
from google.adk.tools.mcp_tool import McpToolset
from google.adk.tools.mcp_tool.mcp_session_manager import StdioConnectionParams
from mcp import StdioServerParameters

knowledge_catalog = McpToolset(
    connection_params=StdioConnectionParams(
        server_params=StdioServerParameters(
            command="gcloud",
            args=["beta", "knowledge-catalog", "mcp-server"] # Example command
        )
    )
)
```

## Challenge 4: Gemini Enterprise Integration

### Notes & Guidance

Make the agent A2A compatible using `to_a2a`.

```python
from google.adk.a2a.utils.agent_to_a2a import to_a2a
# In the entry point
to_a2a(root_agent, port=8080)
```

Then register in Gemini Enterprise console using the A2A endpoint.

## Challenge 5: Visualizing Data (A2UI)

### Notes & Guidance

A2UI typically involves returning specific artifacts or using tools that generate UI components. In ADK, this can be done by yielding `Event(content=...)` with specific MIME types or using the `A2UI` library if available.

```python
from google.adk.plugins.a2ui import A2UIPlugin
app = App(..., plugins=[A2UIPlugin()])
```
