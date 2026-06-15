# Custom ADK Agents and Gemini Enterprise app - Coach's Guide

## Introduction

This guide provides notes, guidance, and solutions for the Gemini Enterprise with ADK gHack, utilizing the BigQuery MCP Server.

## Challenge 1: Getting Started with ADK

### Notes & Guidance

Participants should clone the repository and run it locally.

> [!NOTE]  
> It's possible to run these challenges on a local machine too as long as it's been configured and authenticated with `gcloud`. Cloud Shell is the easy option as it already provides these pre-requisites.

```shell
# Clone the skeleton code
git clone https://source.developers.google.com/p/$GOOGLE_CLOUD_PROJECT/r/ghacks-adk-ge
cd ghacks-adk-ge
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
# Keep the existing imports
from datetime import date

def get_current_date() -> str:
    """Returns the current date in YYYY-MM-DD format.
    
    Returns:
        The current date as a string.
    """
    return date.today().strftime("%Y-%m-%d")


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

The very first time someone needs to commit anything to the Git repository they'll have to identify themselves by running the following commands.

```shell
git config --global user.name "$USER"  # or their own name
git config --global user.email "$USER_EMAIL" # or their own email
```

Adding, committing and pushing the changes should be trivial, but see the following commands for the sake of completeness.

```shell
git add .  # stage everything that's changed in this directory and sub-directories
git commit -m "YOUR COMMIT MESSAGE"
git push
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

First configure Agent identity through configuration file:

```shell
echo '{ "identity_type": "AGENT_IDENTITY" }' > retail_bank_agent/.agent_engine_config.json
```

To deploy to Agent Runtime (Agent Platform):

```shell
adk deploy agent_engine retail_bank_agent
```

> [!NOTE]  
> If you need to redeploy your agent, provide the `--agent_engine_id` option so that it *replaces* your deployment (and doesn't create a new agent with a new identity)

Typically users would navigate to the Console and retrieve the principal information and grant permissions, but for automation the following could be used (note that currently only REST APIs exist, no `gcloud` or ADK CLI commands are available):

```shell
BASE_URL="https://$REGION-aiplatform.googleapis.com/v1"
# Retrieve the Agent Engine ID, assumes that there's only one
AGENT_ENGINE_ID=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "$BASE_URL/projects/$GOOGLE_CLOUD_PROJECT/locations/$REGION/reasoningEngines" | \
    jq -r '.reasoningEngines[0].name')
# Retrieve the Agent Identity details
AGENT_IDENTITY=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "$BASE_URL/$AGENT_ENGINE_ID" | \
    jq -r '.spec.effectiveIdentity')
# Grant the MCP Tool User role
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="principal://$AGENT_IDENTITY" \
    --role="roles/mcp.toolUser" \
    --condition=None
# Grant the BigQuery Job User role to run queries
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="principal://$AGENT_IDENTITY" \
    --role="roles/bigquery.jobUser" \
    --condition=None
# Grant the BigQuery Data Viewer role to access data (read-only)
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="principal://$AGENT_IDENTITY" \
    --role="roles/bigquery.dataViewer" \
    --condition=None
```

## Challenge 5: Gemini Enterprise Integration

### Notes & Guidance

This should be rather straight-forward. Enabling Gemini Enterprise app is just a matter of navigating to the Gemini Enterprise (search bar helps), choosing the trial option, and picking a region (`global` is fine). After that choosing the identity provider from the landing page should be self-explanatory.

Once those steps have been taken, you can register the agent in the Gemini Enterprise configuration page (Agents section) using the deployed Agent Runtime resource name, no authorization setup is needed. These [instuctions](https://docs.cloud.google.com/gemini/enterprise/docs/register-and-manage-an-adk-agent#register-an-adk-agent) should be easy to follow.

We expect participants to use the Console, but for automation purposes you can use the following REST API commands.

```shell
LOCATION=global
BASE_URL="https://$LOCATION-discoveryengine.googleapis.com/v1alpha"

APP_URL=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -H "X-Goog-User-Project: $GOOGLE_CLOUD_PROJECT" \
    "$BASE_URL/projects/$GOOGLE_CLOUD_PROJECT/locations/$LOCATION/collections/default_collection/engines" | jq -r .engines[0].name
)

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -H "X-Goog-User-Project: $GOOGLE_CLOUD_PROJECT" \
    "$BASE_URL/$APP_URL/assistants/default_assistant/agents" \
    -d "{
        \"displayName\": \"Retail Bank Agent\",
        \"description\": \"A digital assistant for Retail Bank related questions.\",
        \"adkAgentDefinition\": {
            \"provisionedReasoningEngine\": {
                \"reasoningEngine\": \"$AGENT_ENGINE_ID\"
            }
        }
    }"
```

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
    tools=[get_current_date, mcp_toolset],
    after_model_callback=helpers.convert_to_a2ui
)
```

And in order to redeploy to Agent Runtime, make sure to include the `agent_engine_id` parameter, otherwise there will be a new instance with a new identity. The easiest way to get the agent engine id is through the Console (you can see it as resource name on the Deployments page), otherwise see the commands above to get it through REST APIs.

```shell
adk deploy agent_engine --agent_engine_id="$AGENT_ENGINE_ID" retail_bank_agent
```
