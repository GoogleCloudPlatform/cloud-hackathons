echo "=====--Starting the cloud run Agent Deployment--"===========

cd sapwithadk

#Install ADK
pip install google-adk

#install The Google Cloud CLI
curl https://sdk.cloud.google.com > install.sh
bash install.sh --disable-prompts > /dev/null 2>&1
source /builder/home/google-cloud-sdk/path.bash.inc

#Configuring the env file with correct variables
cp ./purchasing/.env.example ./purchasing/.env
rm ./purchasing/.env.example

sed -i 's/GOOGLE_CLOUD_PROJECT=sap-demo-ai-d-agents-grht/GOOGLE_CLOUD_PROJECT=${gcp_project_id}/g' ./purchasing/.env
sed -i 's/APPINT_PROJECT_ID=sap-demo-appint-d-appint-p74f/APPINT_PROJECT_ID=${gcp_project_id}/g' ./purchasing/.env
sed -i 's/APPINT_LOCATION=europe-west4/APPINT_LOCATION=${gcp_region}/g' ./purchasing/.env
sed -i 's/SAP_VENDOR_CONNECTION_ID=sap-palkin-demo-s4-gateway/SAP_VENDOR_CONNECTION_ID=s4-vendors/g' ./purchasing/.env
sed -i 's/SAP_PR_CONNECTION_ID=sap-palkin-demo-s4-purchase-req/SAP_PR_CONNECTION_ID=s4-pr/g' ./purchasing/.env


# Set your Google Cloud Project ID
export GOOGLE_CLOUD_PROJECT=${gcp_project_id}

# Set your desired Google Cloud Location
export GOOGLE_CLOUD_LOCATION="global" # Example location
export CLOUD_RUN_LOCATION=${gcp_region}

# Set the path to your agent code directory
export AGENT_PATH="./purchasing"

# Set a name for your Cloud Run service (optional)
export SERVICE_NAME="purchasing-agent-service"

# Set an application name (optional)
export APP_NAME="purchasing-agents-app"

export GOOGLE_GENAI_USE_VERTEXAI=True

#Trigger ADK deployment to Cloud Run
yes | adk deploy cloud_run \
--project=$GOOGLE_CLOUD_PROJECT \
--region=$CLOUD_RUN_LOCATION \
--service_name=$SERVICE_NAME \
--app_name=$APP_NAME \
--with_ui \
$AGENT_PATH

gcloud components install beta

yes | gcloud beta run services update $SERVICE_NAME \
--region=$CLOUD_RUN_LOCATION \
--iap