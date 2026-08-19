# Coach's Guide: Agents: Beyond the Basics

## Overview

This guide provides coaches with reference solutions, estimated timings, common blockers, and coaching tips for the **Enterprise Agent Operations on Agent Runtime** gHack.

In this hack, participants scale, govern, and monitor a production-ready Python ADK agent for Cymbal Retail without needing to write or alter agent code. They focus on infrastructure, security, networking, and operations.

## Challenge 1: It Works on My Machine!

### Solution Steps

1. Download/clone the sample repository, and run the following command in the top level directory:

   ```shell
   uv sync --dev  # --dev is optional
   ```

1. In principle it's sufficient to run `export GOOGLE_GENAI_USE_ENTERPRISE=true` in the terminal to configure the authentication on Cloud Shell. Keep in mind that Cloud Shell automatically populates the `GOOGLE_CLOUD_PROJECT` variable, so you don't have to set it. And we don't use the `GOOGLE_CLOUD_LOCATION` as we've hard-coded our model to the `global` location. However, if you follow the directions from the documentation, you should run the following:

   ```shell
   REGION=us-central1  # or any other valid location
   cat > retail_agent/.env <<EOF
   GOOGLE_GENAI_USE_ENTERPRISE=true
   GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT
   GOOGLE_CLOUD_LOCATION=$REGION
   EOF
   source retail_agent/.env  # might be omitted
   ```

1. Start the Firestore emulator

   ```shell
   scripts/setup-emulator.sh
   ```

1. Run the ADK Web UI:

   ```shell
   uv run adk web retail_agent --allow_origins="*"
   ```

## Challenge 2: Contain Your Excitement

### Solution Steps

1. Build and push the container image to Artifact Registry:

   ```bash
   PROJECT_ID=$(gcloud config get-value project)
   REGION="us-central1"
   IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/agent-images/retail-support-agent:v1"

   # Using Cloud Build
   gcloud builds submit --tag "${IMAGE_URI}" .
   ```

2. Deploy to Agent Runtime with BYOC using the Python SDK (`vertexai`):
   Create a deployment script or run in Python:

   ```python
   import vertexai
   from vertexai import Client

   PROJECT_ID = "YOUR_PROJECT_ID"
   LOCATION = "us-central1"
   IMAGE_URI = f"{LOCATION}-docker.pkg.dev/{PROJECT_ID}/agent-images/retail-support-agent:v1"

   client = Client(project=PROJECT_ID, location=LOCATION)

   agent_engine = client.agent_engines.create(
       display_name="cymbal-retail-support-agent",
       container_spec={
           "image_uri": IMAGE_URI,
       },
       # Production Sizing & Scaling configuration
       min_instance_count=1,
       max_instance_count=5,
       cpu_limit="1",
       memory_limit="4Gi",
       concurrency=8,
   )

   print(f"Agent Engine created: {agent_engine.resource_name}")
   ```

3. Alternatively, deploy via `agents-cli`:

   ```bash
   agents-cli deploy \
     --project=${PROJECT_ID} \
     --region=${REGION} \
     --service-name="cymbal-retail-support-agent" \
     --min-instances=1 \
     --max-instances=5 \
     --cpu=1 \
     --memory=4Gi \
     --concurrency=8 \
     --no-confirm-project
   ```

4. Verify the deployment using the remote test client:

   ```bash
   python test_client.py \
     --mode remote \
     --resource-name "projects/${PROJECT_ID}/locations/${REGION}/reasoningEngines/<ENGINE_ID>" \
     --location ${REGION} \
     --prompt "What is the status of my order ORD-1002?"
   ```

### Known Blockers & Coaching Tips

- **Deployment Duration:** Agent Runtime provisioning typically takes 5 to 8 minutes. Inform teams to let the operation complete server-side without interrupting the process.
- **Port Matching:** Ensure the container exposes port 8080 and that FastAPI serves the standard reasoning engine routes.
- **Missing Container Spec:** If deploying programmatically, remind students that BYOC requires `container_spec={"image_uri": ...}`.

## Challenge 3: Badge, Please!

### Solution Steps

1. Inspect the deployed Agent Runtime instance and retrieve its Agent Identity:

   ```bash
   gcloud logging read 'resource.type="aiplatform.googleapis.com/ReasoningEngine"' --limit=10
   ```

   Or via the Vertex AI Python SDK / Console:

   ```python
   engine = client.agent_engines.get(name=RESOURCE_NAME)
   print("Agent Identity:", engine.agent_identity)
   ```

2. Grant the principle of least privilege:
   Assign only the necessary roles to the Agent Identity principal:

   ```bash
   AGENT_IDENTITY_PRINCIPAL="<AGENT_IDENTITY_PRINCIPAL>"

   # Cloud Trace Agent (for emitting traces)
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="${AGENT_IDENTITY_PRINCIPAL}" \
     --role="roles/cloudtrace.agent"

   # Logging Log Writer
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="${AGENT_IDENTITY_PRINCIPAL}" \
     --role="roles/logging.logWriter"

   # Vertex AI User (for invoking Gemini models)
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="${AGENT_IDENTITY_PRINCIPAL}" \
     --role="roles/aiplatform.user"
   ```

3. Verify audit logging:
   Execute a query and inspect Cloud Audit Logs:

   ```bash
   gcloud logging read 'protoPayload.serviceName="aiplatform.googleapis.com" AND protoPayload.authenticationInfo.principalSubject:*' \
     --limit=5 \
     --format="table(timestamp, protoPayload.authenticationInfo.principalSubject, protoPayload.methodName)"
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
