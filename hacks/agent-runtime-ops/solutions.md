# Coach's Guide: Agents: Beyond the Basics

## Overview

This guide provides coaches with reference solutions, estimated timings, common blockers, and coaching tips for the **Enterprise Agent Operations on Agent Runtime** gHack.

In this hack, participants scale, govern, and monitor a production-ready Python ADK agent for Cymbal Retail without needing to write or alter agent code. They focus on infrastructure, security, networking, and operations.

## Challenge 1: It Works on My Machine!

### Solution Steps

Download/clone the sample repository, and run the following command in the top level directory:

```shell
uv sync --dev  # --dev is optional
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
scripts/setup-emulator.sh
```

Run the ADK Web UI:

```shell
uv run adk web retail_agent --allow_origins="*"
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

agent_engine = client.agent_engines.create(
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
         "agent_framework": "google-adk"
      }
)

print(f"Agent Engine created: {agent_engine}")
EOF
```

### Known Blockers & Coaching Tips

- **Deployment Duration:** Agent Runtime provisioning typically takes 5 to 8 minutes. Inform teams to let the operation complete server-side without interrupting the process.

## Challenge 3: Badge, Please!

### Solution Steps

Let's first get the resource name for our agent (can also be retrieved from the console):

```shell
BASE_URL="https://$REGION-aiplatform.googleapis.com/v1"
# Retrieve the Agent Engine ID, assumes that there's only one
AGENT_ENGINE_ID=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "$BASE_URL/projects/$GOOGLE_CLOUD_PROJECT/locations/$REGION/reasoningEngines" | \
    jq -r '.reasoningEngines[0].name')
```

Now we can update it to use the agent identity:

```python
cat > update.py <<EOF
from agentplatform import Client

client = Client(project="$GOOGLE_CLOUD_PROJECT", location="$REGION")

agent_engine = client.agent_engines.update(
   name="$AGENT_ENGINE_ID",
   config={
      "identity_type": "AGENT_IDENTITY"
   }
)
print(f"Agent Engine updated: {agent_engine}")
EOF
```

Grant the principle of least privilege, assign only the necessary roles to the Agent Identity principal:

```bash
# Retrieve the Agent Identity details
AGENT_IDENTITY_PRINCIPAL=$(curl -s -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "$BASE_URL/$AGENT_ENGINE_ID" | \
    jq -r '.spec.effectiveIdentity')

# Grant permissions to access firestore database
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
   --member="principal://$AGENT_IDENTITY_PRINCIPAL" \
   --role="roles/datastore.editor"
```

### Known Blockers & Coaching Tips

- **IAM Propagation Delay:** IAM role bindings can take 60-90 seconds to propagate across Google Cloud global IAM caches. Advise students to wait a moment if they see a transient 403.
- **Service Account vs Agent Identity:** Emphasize to students the difference between traditional service accounts and SPIFFE-based per-agent identities with Context-Aware Access mTLS token binding.

## Challenge 4: Bouncer at the Gate

### Solution Steps

1. Create a Model Armor Template:
   In the Google Cloud Console (Security > Model Armor > Templates) or using `gcloud model-armor templates create`:

   ```bash
   gcloud model-armor templates create retail-agent-security-template \
     --location=us-central1 \
     --filter-config-file=model_armor_template.json
   ```

2. Create an Agent Gateway resource (Network Services / Agent Platform):
   In the Google Cloud Console (Agent Platform > Governance > Gateways > Create Gateway) or via `gcloud`:

   ```bash
   gcloud network-services agent-gateways create retail-agent-gateway \
     --location=us-central1 \
     --mode=CLIENT_TO_AGENT \
     --model-armor-template="projects/${PROJECT_ID}/locations/us-central1/templates/retail-agent-security-template"
   ```

3. Attach the Agent Runtime deployment to the Agent Gateway.

4. Run the security verification suite:

   ```bash
   python adversarial_test.py \
     --resource-name "projects/${PROJECT_ID}/locations/us-central1/reasoningEngines/<ENGINE_ID>" \
     --location us-central1
   ```

5. Verify test outputs:
   - `SEC-01` (Benign Query): **PASS (ALLOW)**
   - `SEC-02` (Prompt Injection - Unauthorized Refund): **PASS (BLOCK / Neutralized)**
   - `SEC-03` (Jailbreak Attempt): **PASS (BLOCK / Neutralized)**
   - `SEC-04` (PII / Sensitive Data Exfiltration): **PASS (BLOCK / Neutralized)**
   - `SEC-05` (Benign Stock Query): **PASS (ALLOW)**

### Known Blockers & Coaching Tips

- **Regional Colocation:** Ensure the Model Armor template and Agent Gateway are created in the **exact same region** (e.g. `us-central1`).
- **Inspection Logs:** Show students how Model Armor logs violations into Security Command Center and Cloud Logging.

## Challenge 5: Keeping It Real (Time)

### Solution Steps

1. Ensure container telemetry environment variables were present during build:
   - `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`
   - `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=EVENT_ONLY`

2. Configure Online Monitor in Google Cloud Console:
   - Navigate to **Agent Platform > Agents > Evaluation > Online monitors**.
   - Click **New monitor**.
   - Select the deployed Agent Runtime Reasoning Engine (`cymbal-retail-support-agent`).
   - Add Metrics:
     - `MULTI_TURN_TASK_SUCCESS`
     - `MULTI_TURN_TOOL_USE_QUALITY`
     - `SAFETY`
   - Set Sampling: 100% sampling for immediate test feedback (in production 5-10% is typical), with a cap of 50 samples per run.
   - Click **Create**.

3. Generate production traffic with the simulator:

   ```bash
   python simulate_traffic.py \
     --resource-name "projects/${PROJECT_ID}/locations/us-central1/reasoningEngines/<ENGINE_ID>" \
     --location us-central1 \
     --sessions 10 \
     --delay 1.5
   ```

4. View Results in Cloud Console:
   - Navigate to **Cloud Trace** to see the OpenTelemetry span hierarchy (`invoke_agent` -> `call_llm` -> `execute_tool`).
   - Navigate to **Agent Platform > Evaluation > Online monitors** to review score charts, AutoRater evaluations, and loss clusters.

### Known Blockers & Coaching Tips

- **Schedule Interval:** Online Monitors run on a periodic polling schedule (evaluating batches every 5-10 minutes). Coaches can explain that in a real enterprise setting, this runs 24/7 in the background.
- **Trace Export:** If traces do not appear, verify that the runtime identity has the `roles/cloudtrace.agent` role.
- **Loss Cluster Interpretation:** Walk students through how loss clusters categorize failing conversations (e.g. invalid refund requests on undelivered items), demonstrating how operations teams can fine-tune instructions based on empirical data.

## Complete Solution Verification Checklist

- [ ] Artifact Registry repository `agent-images` contains the built Docker image.
- [ ] Agent Runtime instance is `ACTIVE` with `min_instance_count=1` and `concurrency=8`.
- [ ] Agent Identity principal is assigned `roles/cloudtrace.agent`, `roles/logging.logWriter`, and `roles/aiplatform.user`.
- [ ] Model Armor template is active and blocking prompt injection / jailbreak attempts on `adversarial_test.py`.
- [ ] Online Monitor is enabled and capturing evaluation metrics from simulated traffic in `simulate_traffic.py`.
