# Coach's Guide: Agents: Beyond the Basics

## Overview

This guide provides coaches with reference solutions, estimated timings, common blockers, and coaching tips for the **Enterprise Agent Operations on Agent Runtime** gHack.

In this hack, participants scale, govern, and monitor a production-ready Python ADK agent for Cymbal Retail without needing to write or alter agent code. They focus on infrastructure, security, networking, and operations.

## Challenge 1: It Works on My Machine!

### Solution Steps

Download/clone the sample repository, and run the following command in the top level directory:

```shell
python -m venv .venv
. .venv/bin/activate
# Cloud Shell has an older pip that doesn't suport dependency groups, upgrade first
python -m pip install --upgrade pip 
pip install --group dev .
```

Or alternatively use the standard `uv` ecosystem

```shell
uv sync --dev  # --dev is for pytest
. .venv/bin/activate  # otherwise instead of python use uv run
```

In principle it's sufficient to run `export GOOGLE_GENAI_USE_ENTERPRISE=true` in the terminal to configure the authentication on Cloud Shell. Keep in mind that Cloud Shell automatically populates the `GOOGLE_CLOUD_PROJECT` variable, so you don't have to set it. And we don't use the `GOOGLE_CLOUD_LOCATION` as we've hard-coded our model to the `global` location. However, if you follow the directions from the documentation, you should run the following:

```shell
REGION=us-central1  # or any other valid location
cat > retail_agent/.env <<EOF
GOOGLE_GENAI_USE_ENTERPRISE=true
GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT
GOOGLE_CLOUD_LOCATION=$REGION
EOF
source retail_agent/.env  # might be omitted
```

Start the Firestore emulator

```shell
source scripts/start-database-emulator.sh
```

Run the ADK Web UI:

```shell
adk web retail_agent --allow_origins="*"
```

## Challenge 2: Contain Your Excitement

### Solution Steps

Build and push the container image to Artifact Registry:

```bash
IMAGE_URI="${REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/agent-images/retail-support-agent:v1"

# Using Cloud Build
gcloud builds submit --tag "${IMAGE_URI}" .
```

Deploy to Agent Runtime with BYOC using the Python SDK (`agentplatform`), create a deployment script or run in Python:

```python
cat > deploy.py <<EOF
from agentplatform import Client

client = Client(project="$GOOGLE_CLOUD_PROJECT", location="$REGION")

agent = client.agent_engines.create(
      config = {
         "display_name": "cymbal-retail-support-agent",
         "container_spec": {
            "image_uri": "$IMAGE_URI",
         },
         "min_instances": 1,
         "max_instances": 5,
         "container_concurrency": 4,
         "resource_limits": {
            "cpu":"1",
            "memory": "4Gi",
         },
         "agent_framework": "google-adk",
         "class_methods": [
            # For convenience to interact with the agent through the Python SDK
            # https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/use-an-adk-agent
            {"api_mode": "", "name": "get_session"},
            {"api_mode": "", "name": "list_sessions"},
            {"api_mode": "", "name": "create_session"},
            {"api_mode": "", "name": "delete_session"},
            {"api_mode": "async", "name": "async_get_session"},
            {"api_mode": "async", "name": "async_list_sessions"},
            {"api_mode": "async", "name": "async_create_session"},
            {"api_mode": "async", "name": "async_delete_session"},
            {"api_mode": "async", "name": "async_add_session_to_memory"},
            {"api_mode": "async", "name": "async_search_memory"},
            {"api_mode": "stream", "name": "stream_query"},
            {"api_mode": "async_stream", "name": "async_stream_query"},
            {"api_mode": "async_stream", "name": "streaming_agent_run_with_events"},
        ],
      }
)

print(f"Agent deployed: {agent}")
EOF
python deploy.py
```

> [!WARNING]  
> Sometimes deployment fails with a very vague message (code 3), in that case re-running the deploy script usually fixes it.

Keep in mind Agent Runtime provisioning typically takes ~5 minutes. Inform teams to let the operation complete server-side without interrupting the process.

## Challenge 3: Badge, Please!

### Solution Steps

Let's first get the resource name for our agent (can also be retrieved from the console):

```shell
BASE_URL="https://$REGION-aiplatform.googleapis.com/v1"
# Retrieve the Agent Engine ID, assumes that there's only one
export AGENT_RESOURCE_NAME=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "$BASE_URL/projects/$GOOGLE_CLOUD_PROJECT/locations/$REGION/reasoningEngines" | \
    jq -r '.reasoningEngines[0].name')
```

Now we can update it to use the agent identity:

```python
cat > update_identity.py <<EOF
from agentplatform import Client

client = Client(project="$GOOGLE_CLOUD_PROJECT", location="$REGION")

agent = client.agent_engines.update(
   name="$AGENT_RESOURCE_NAME",
   config={
      "identity_type": "AGENT_IDENTITY"
   }
)
print(f"Agent updated: {agent}")
EOF
python update_identity.py
```

Grant the principle of least privilege, assign only the necessary roles to the Agent Identity principal:

```bash
# Retrieve the Agent Identity details
AGENT_IDENTITY_PRINCIPAL=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "$BASE_URL/$AGENT_RESOURCE_NAME" | \
    jq -r '.spec.effectiveIdentity')

# Grant permissions to access firestore database
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
   --member="principal://$AGENT_IDENTITY_PRINCIPAL" \
   --role="roles/datastore.editor"
```

> [!WARNING]  
> IAM role bindings can take 60-90 seconds to propagate across Google Cloud global IAM caches. Advise participants to wait a moment if they see a transient 403.

## Challenge 4: Bouncer at the Gate

### Solution Steps

> [!IMPORTANT]  
> Model Armor template and Agent Gateway must be created in the **exact same region** (e.g. `us-central1`).

You can create a Model Armor template either on the Console (Security > Model Armor > Templates), or using the `gcloud` CLI:

```shell
# This is essential!
gcloud config set api_endpoint_overrides/modelarmor "https://modelarmor.$REGION.rep.googleapis.com/"

gcloud model-armor templates create retail-agent-security-template \
      --location=$REGION \
      --basic-config-filter-enforcement=enabled \
      --pi-and-jailbreak-filter-settings-enforcement=enabled \
      --pi-and-jailbreak-filter-settings-confidence-level=high \
      --rai-settings-filters=filterType=HATE_SPEECH,confidenceLevel=LOW_AND_ABOVE \
      --rai-settings-filters=filterType=DANGEROUS,confidenceLevel=LOW_AND_ABOVE \
      --rai-settings-filters=filterType=HARASSMENT,confidenceLevel=LOW_AND_ABOVE \
      --rai-settings-filters=filterType=SEXUALLY_EXPLICIT,confidenceLevel=LOW_AND_ABOVE \
      --template-metadata-log-sanitize-operations
```

Similar to Model Armor you can create an Agent Gateway resource in the Google Cloud Console (Agent Platform > Governance > Gateways > Create Gateway) or via `gcloud`:

```shell
GATEWAY_NAME="retail-agent-gateway"
TEMPLATE_NAME="retail-agent-security-template"
TEMPLATE_FULL_PATH="projects/${GOOGLE_CLOUD_PROJECT}/locations/${REGION}/templates/${TEMPLATE_NAME}"

# 1. Create / Update the Agent Gateway (Includes Registries & MCP protocol)
cat <<EOF | gcloud network-services agent-gateways import "${GATEWAY_NAME}" \
  --location="${REGION}" \
  --source=-
protocols:
  - MCP
googleManaged:
  governedAccessPath: CLIENT_TO_AGENT
registries:
  - "//agentregistry.googleapis.com/projects/${GOOGLE_CLOUD_PROJECT}/locations/${REGION}"
EOF

# 2. Create / Update the Service Extension with the JSON 'model_armor_settings' & 10s timeout
cat <<EOF | gcloud service-extensions authz-extensions import "${GATEWAY_NAME}-aisecurity-authzextension" \
  --location="${REGION}" \
  --source=-
name: ${GATEWAY_NAME}-aisecurity-authzextension
service: modelarmor.${REGION}.rep.googleapis.com
failOpen: true
timeout: 10s
metadata:
  model_armor_settings: '[{"response_template_id":"${TEMPLATE_FULL_PATH}","request_template_id":"${TEMPLATE_FULL_PATH}"}]'
EOF

# 3. Create / Update AuthzPolicy binding the extension to the gateway
cat <<EOF | gcloud beta network-security authz-policies import "${GATEWAY_NAME}-aisecurity-authzpolicy" \
  --location="${REGION}"\
  --source=-
name: ${GATEWAY_NAME}-aisecurity-authzpolicy
target:
  resources:
    - "projects/${GOOGLE_CLOUD_PROJECT}/locations/${REGION}/agentGateways/${GATEWAY_NAME}"
policyProfile: CONTENT_AUTHZ
action: CUSTOM
customProvider:
  authzExtension:
    resources:
      - "projects/${GOOGLE_CLOUD_PROJECT}/locations/${REGION}/authzExtensions/${GATEWAY_NAME}-aisecurity-authzextension"
EOF
```

> [!NOTE]  
> It's much easier to do this from the UI.

Attach the Agent Runtime deployment to the Agent Gateway.

```python
cat > update_gateway.py <<EOF
import os

from agentplatform import Client

client = Client(project="$GOOGLE_CLOUD_PROJECT", location="$REGION")
gateway_uri = "projects/$GOOGLE_CLOUD_PROJECT/locations/$REGION/agentGateways/$GATEWAY_NAME"
agent = client.agent_engines.update(
    name="$AGENT_RESOURCE_NAME",
    config={
         "container_spec": {
            "image_uri": "$IMAGE_URI",
         },
         "agent_gateway_config": {
            "client_to_agent_config": {
                "agent_gateway": gateway_uri
            }
        },
        "env_vars": {
            "GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY": "true" 
        },
        "agent_framework": "google-adk",
    }
)
print(f"Agent successfully linked to Gateway: {agent}")
EOF
python update_gateway.py
```

> [!WARNING]  
> For some strange reason, updating the gateway causes env variables and agent framework to be lost, so those need to be included in the config block.

Verify test outputs by running `pytest -m sanitization` after making sure that the environment variables `GOOGLE_CLOUD_PROJECT` (should be there on Cloud Shell by default), `GOOGLE_CLOUD_LOCATION` and `AGENT_RESOURCE_NAME` are *exported*. All tests should pass.

> [!NOTE]  
> Immediately after creating the Model Armor & Gateway the tests might not pass, try it again after a few minutes.

## Challenge 5: Keeping It Real (Time)

### Solution Steps

Configure Online Monitor in Google Cloud Console, this should be trivial.

> [!WARNING]  
> Immediately after creating the monitor for the first time, its status might be *Failed*, if you click on that it will say *Permission Denied when querying traces (this might be transient if the OnlineEvaluator was recently created)*, so you can ignore it. It can take more than 10 minutes for the status to be *Active*.

Generate production traffic with the simulator:

```bash
scripts/simulate-traffic.sh \
   --resource-name "$AGENT_RESOURCE_NAME" \
   --location "$REGION" \
   --sessions 20 \
   --delay 1.0
```

View Results in Cloud Console, Dashboard->Evaluation should show a degraded Tool Use Quality score.

Rule 2 in the agent prompt calls `lookup_order` on any identifier provided by the customer without format validation. Update the prompt to indicate that that SKU- codes are product identifiers, and only call lookup_order on valid ORD-IDs.

Keep in mind that Online Monitors run on a periodic polling schedule (evaluating batches every 10 minutes). You can explain that in a real enterprise setting, this runs 24/7 in the background.
