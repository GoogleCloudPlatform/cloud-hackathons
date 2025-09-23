# Introduction to Agents with ADK

## Introduction

Welcome to the coach's guide for Introduction to Agents with ADK gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

> [!IMPORTANT]  
> As of June 2024 *Cloud Source Repositories* is [end of sale](https://cloud.google.com/source-repositories/docs/release-notes#June_17_2024). However, any organization that has created at least one CSR repository in the past, will still have access to existing repositories and will be able to create new ones. If you're running this in a Qwiklabs environment you're good to go, but if you're running this in **your** own environment, please verify that you have access to *Cloud Source Repositories* in your organization.

## Coach's Guides

## Challenges

- Challenge 1: First Scan
- Challenge 2: Equipping the Scanner
- Challenge 3: Sticky Notes
- Challenge 4: Agent Symphony
- Challenge 5: MCP: Universal Tooling
- Challenge 6: A2A: Remote Agent Power

## Challenge 1: First Scan

### Notes & Guidance

The first step is to clone the repository that has been created for the team.

> [!IMPORTANT]  
> We're using Cloud Source Repositories for this hack, which still uses `master` as the default branch. The easiest option is to stick to that.

```shell
git clone https://source.developers.google.com/p/$GOOGLE_CLOUD_PROJECT/r/ghacks-adk-intro
```

Since we're using Cloud Source Repositories, the authentication is done automatically through OAuth. If there are permission denied errors, make sure that the variable `$GOOGLE_CLOUD_PROJECT` is set (sometimes Cloud Shell starts without it being set correctly). If the challenges are run from another VM, either [SSH authentication](https://cloud.google.com/source-repositories/docs/authentication#ssh) would need to be set up, or `gcloud source repos clone` needs to be used (which requires setting up gcloud authentication on the VM first).

If they get the message `warning: You appear to have cloned an empty repository`, they were too quick. The repository is initialized asynchronously at project startup and takes a minute or so. In that case they should retry (after deleting the empty repository, the `ghacks-adk-intro` directory).

Once the repository is cloned, although it's not a hard requirement, the best practice is to start with a virtual environment. There are multiple tools to create virtual environments and install packages but we'll stick to the defaults.

```shell
cd ghacks-adk-intro
python3 -m venv .venv
source .venv/bin/activate
```

Now we can install the required libraries.

```shell
pip install -r requirements.txt
```

One final step before we can start running the `adk web` command is to set some environment variables to configure the authentication (might require gcloud authentication to be set up if not being run from Cloud Shell).

```shell
REGION=us-central1
cat > janitor/.env <<EOF
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT
GOOGLE_CLOUD_LOCATION=$REGION
EOF
source janitor/.env  # might be left out 
```

> [!NOTE]  
> We've configured Git to ignore the file `.env` as we don't want it to be checked in. Although in our case it doesn't contain sensitive information (other than the project id), it typically will have keys and other secret information, so it's not a good practice to store that in a Git repository.

The only file that needs to be edited in the following challenges is `janitor/agent.py`, no other file needs to be modified. In this challenge it will look like this:

```python
from google.adk import Agent

import janitor.schemas as schemas
import janitor.settings as settings
import janitor.tools as tools


resource_scanner_agent = Agent(
    name="resource_scanner_agent",
    model=settings.GEMINI_MODEL,
    instruction="""
    You are a Cloud Resource Scanner. 
    Return *all* resources.
    """
)

root_agent = resource_scanner_agent
```

Now we can run the `adk web` command and preview it by clicking the web preview icon in the Cloud Shell menu and selecting Preview and Change Port to 8000.

If you get authentication errors, make sure that the environment variables as defined above (in the `.env` file) are set and have been sourced.

## Challenge 2: Equipping the Scanner

### Notes & Guidance

The new driver should follow the same steps to clone the repository and set up their environment.

Then edit the `janitor/agent.py` to update the prompt and configure the tool.

```python
resource_scanner_agent = Agent(
    name="resource_scanner_agent",
    model=settings.GEMINI_MODEL,
    instruction="""
    You are a Cloud Resource Scanner. 
    Return *all* resources.
    """,
    tools=[tools.get_compute_instances_list]
)
```

Format of the response is not relevant for this challenge as long as all of the virtual machines are returned.

Make sure that the changes are pushed to the repository so the next driver can pick up the changes.

## Challenge 3: Sticky Notes

### Notes & Guidance

Again the new driver should follow the same steps for the first challenge to clone the repository (or pull the latest changes if they have already cloned it) and set up their environment (if they haven't done that already).

Then edit the `janitor/agent.py` to update the prompt and configure the `output_key`. It's also possible to introduce another tool that stores things explicitly in the session state using the `CallContext` or `ToolContext` but it's much more work (see the official [docs](https://google.github.io/adk-docs/sessions/state/#how-state-is-updated-recommended-methods) for more details).

```python
resource_scanner_agent = Agent(
    name="resource_scanner_agent",
    model=settings.GEMINI_MODEL,
    instruction="""
    You are a Cloud Resource Scanner. 
    Return *all* resources.
    """,
    tools=[tools.get_compute_instances_list],
    output_key="resources",
    output_schema=schemas.VMInstanceList
)
```

Make sure that the changes are pushed to the repository so the next driver can pick up the changes.

## Challenge 4: Agent Symphony

### Notes & Guidance

Again the new driver should follow the same steps for the first challenge to clone the repository (or pull the latest changes if they have already cloned it) and set up their environment (if they haven't done that already).

```python
# keep other imports

from google.adk.agents import SequentialAgent

# keep resource_scanner_agent as is
resource_monitor_agent = Agent(
    name="resource_monitor_agent",
    model=settings.GEMINI_MODEL,
    instruction="""
    You are a Cloud Resource Monitor.
    Filter the {resources} and return back only the instances that are idle.
    A resource is considered idle if it has <5% average cpu utilization and minimal network activity.
    """,
    tools=[tools.get_compute_instance_stats],
    output_key="idle_resources",
    output_schema=schemas.VMStatsList,
)

orchestrator_agent = SequentialAgent(
    name="orchestrator_agent",
    sub_agents=[resource_scanner_agent, resource_monitor_agent]
)

root_agent = orchestrator_agent
```

> [!NOTE]  
> Sometimes after running both agents, the `resources` state variable seems to be empty, but as long as `idle_resources` provides the correct set of instances, it should be fine.

Make sure that the changes are pushed to the repository so the next driver can pick up the changes.

## Challenge 5: MCP: Universal Tooling

### Notes & Guidance

Again the new driver should follow the same steps for the first challenge to clone the repository (or pull the latest changes if they have already cloned it) and set up their environment (if they haven't done that already).

First step is to run the Cloud Run proxy to simplify things.

```shell
gcloud run services proxy --region $REGION --port=8888 mcp-server
```

The following snippet indicates what needs to be changed.

```python
# keep other imports
from google.adk.tools.mcp_tool import MCPToolset
from google.adk.tools.mcp_tool import StreamableHTTPConnectionParams

# keep resource_scanner_agent and idle_checker_agent as is

mcp_tool_set = MCPToolset(
    connection_params=StreamableHTTPConnectionParams(
        url="http://localhost:8888/"
    )
)

resource_labeler_agent = Agent(
    name="resource_labeler_agent",
    model=settings.GEMINI_MODEL,
    instruction="""
    You are a Cloud Resource Labeler.
    Add the 'janitor-scheduled' label with the value set to 7 days in the future to the idle instances.
    Do not add the label if the instance already has a 'janitor-scheduled' label.
    """,
    tools=[mcp_tool_set, tools.get_current_date, tools.add_days_to_date]
)

orchestrator_agent = SequentialAgent(
    name="orchestrator_agent",
    sub_agents=[
        resource_scanner_agent,
        resource_monitor_agent,
        resource_labeler_agent
    ]
)
```

The proxy solves the authenticaton part of this simple tool. It's also possible to make this work without the proxy. In that case we could create and use bearer tokens. The token creation is trivial and can be done through the `google-auth` library.

```python
import google.auth.transport.requests
import google.oauth2.id_token

def get_bearer_token(audience: str) -> str:
    request = google.auth.transport.requests.Request()
    token = google.oauth2.id_token.fetch_id_token(request, audience)
    return token
```

ADK provides many different classes and methods for handling the authentication configuration, but we'll stick to the simple method of providing the bearer token in the header of the request.

```python
MCP_SERVER_CLOUD_RUN_URL="..." # typically https://mcp-server-$PROJECT_NUMBER.$REGION.run.app

mcp_tool_set = MCPToolset(
    connection_params=StreamableHTTPConnectionParams(
        url=f"{MCP_SERVER_CLOUD_RUN_URL}/",
        headers={"Authorization": f"Bearer {tools.get_bearer_token(MCP_SERVER_CLOUD_RUN_URL)}"},
    )
)
```

> [!NOTE]  
> At the time of this writing using the `auth_scheme` and `auth_credentials` for bearer tokens doesn't work well with MCP servers, as those credentials are not utilized for listing the tools, tracked [here](https://github.com/google/adk-python/issues/2168).

As our tool is simple, this approach works fine, but in real world, you might need to use OAuth flows, API keys etc. And there will be cases where the currently authenticated user's credentials need to be forwarded to remote agents/tools so that they can perform actions on behalf of the user (see the official [docs](https://google.github.io/adk-docs/safety/#identity-and-authorization) for more details).

In order to verify if the labels have been set correctly, you can either navigate to the relevant section on Google Cloud Console or run the following command:

```shell
gcloud compute instances list  \
    --project=$GOOGLE_CLOUD_PROJECT \
    --format='value(name, labels)'
```

Make sure that the changes are pushed to the repository so the next driver can pick up the changes.

## Challenge 6: A2A: Remote Agent Power

### Notes & Guidance

Again the new driver should follow the same steps for the first challenge to clone the repository (or pull the latest changes if they have already cloned it) and set up their environment (if they haven't done that already).

First step is to run the Cloud Run proxy to simplify things.

```shell
gcloud run services proxy --region $REGION --port=8080 a2a-server
```

> [!IMPORTANT]  
> Currently when an A2A Agent is accessed through the Cloud Run proxy, the proxy port must match the port that the container is running on (which is port `8080` by default). Note that this only applies to the A2A server, the MCP server can be proxied through any port. Once [relative URLs](https://github.com/a2aproject/A2A/issues/160) are supported by A2A, this should be fixed.

The following snippet indicates what needs to be changed.

```python
# keep other imports
from google.adk.agents.remote_a2a_agent import AGENT_CARD_WELL_KNOWN_PATH
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent

# keep other agents
resource_cleaner_agent = RemoteA2aAgent(
    name="resource_cleaner_agent",
    description="This agent stops idle instances that have been scheduled for cleanup",
    agent_card=(
        f"http://localhost:8080/a2a/resource_cleaner_agent{AGENT_CARD_WELL_KNOWN_PATH}"
    )
)

orchestrator_agent = SequentialAgent(
    name="orchestrator_agent",
    sub_agents=[
        resource_scanner_agent,
        resource_monitor_agent,
        resource_labeler_agent,
        resource_cleaner_agent
    ]
)
```

Similar to the MCP server authentication we can make this work without the proxy too. In that case we could create and use bearer tokens (see MCP server authentication for the token creation).

```python
import httpx

A2A_SERVER_CLOUD_RUN_URL="..." # typically https://a2a-server-$PROJECT_NUMBER.$REGION.run.app

httpx_client = httpx.AsyncClient(headers={
        "Authorization": f"Bearer {tools.get_bearer_token(A2A_SERVER_CLOUD_RUN_URL)}"
    })

resource_cleaner_agent = RemoteA2aAgent(
    name="resource_cleaner_agent",
    description="This agent stops idle instances that have been scheduled for cleanup",
    agent_card=(
        f"http://localhost:8080/a2a/resource_cleaner_agent{AGENT_CARD_WELL_KNOWN_PATH}"
    ),
    httpx_client=httpx_client
)
```

> [!NOTE]  
> Again, due to lack of relative URL support in A2A `url` definitions, if this authentication method is chosen, the `url` field of `agent.json` needs to be updated too (can be done through the Cloud Console by editing the source of Cloud Run instance for `a2a-server`).

In order to verify if the correct instance have been stopped, you can either navigate to the relevant section on Google Cloud Console or run the following command:

```shell
gcloud compute instances list  \
    --project=$GOOGLE_CLOUD_PROJECT \
    --format='value(name, status)'
```
