#!/bin/bash

# ==============================================================================
#           START Google Cloud VM for DaVinci Resolve Remote Editing
# ==============================================================================
#
# Description:
#   This script creates a Google Compute Engine (GCE) instance configured
#   for remote video editing with DaVinci Resolve.
#
# Instructions:
#   1. Make this script executable:
#      chmod +x 01-start-davinchi-remote.sh
#   2. Fill in the placeholder variables in the section below.
#   3. Run the script:
#      ./01-start-davinchi-remote.sh
#
# ==============================================================================

# --- CONFIGURATION ---
# Replace the placeholder values below with your specific settings.

# Your team name or a unique identifier for the machine name.
TEAMNAME="ibcghac"

# Your Virtual Private Cloud (VPC) network name.
YOUR_VPC="ibc-vpc"

# The name of the subnet within your VPC.
YOUR_SUBNET="ibc-vpc-subnet-eu-west2-a"

# Your Google Cloud project number (not the project ID).
# You can find this on the GCP Console home page.
YOUR_PROJECT_NUMBER="669648730623"

# Your Google Cloud project number (not the project ID).
# You can find this on the GCP Console home page.
YOUR_PROJECT_ID="media-on-gcp-storage"


# --- SCRIPT LOGIC ---
# Do not edit below this line unless you know what you are doing.

# Project and Machine Image details
PROJECT_ID="${YOUR_PROJECT_ID}"
ZONE="europe-west2-b" # London region, zone a
SOURCE_IMAGE="projects/ibc-ghack-playground/global/machineImages/davinci-remote-edit-machine"
INSTANCE_NAME="davinci-remote-edit-machine-${TEAMNAME}"
SERVICE_ACCOUNT="${YOUR_PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
NETWORK_INTERFACE="network=${YOUR_VPC},subnet=${YOUR_SUBNET}"

# Inform the user what is happening
echo "🚀 Starting the creation of Google Cloud instance: ${INSTANCE_NAME}"
echo "--------------------------------------------------------"
echo "Project:          ${PROJECT_ID}"
echo "Zone:             ${ZONE}"
echo "Source Image:     ${SOURCE_IMAGE}"
echo "Service Account:  ${SERVICE_ACCOUNT}"
echo "Network:          ${YOUR_VPC}"
echo "Subnet:           ${YOUR_SUBNET}"
echo "--------------------------------------------------------"

# Execute the gcloud command to create the instance
gcloud compute instances create "${INSTANCE_NAME}" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --source-machine-image="${SOURCE_IMAGE}" \
    --network-interface="${NETWORK_INTERFACE}" \
    --service-account="${SERVICE_ACCOUNT}"

# Check the exit code of the gcloud command
if [ $? -eq 0 ]; then
    echo "✅ Success! VM instance '${INSTANCE_NAME}' created."
else
    echo "❌ Error: Failed to create VM instance. Please check the gcloud error message above."
fi