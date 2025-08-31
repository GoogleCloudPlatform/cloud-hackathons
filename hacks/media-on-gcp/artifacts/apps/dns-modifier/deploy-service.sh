#!/bin/bash

SERVICE_NAME=${1:-dns-modifier}
PROJECT_ID=${2:-`gcloud config get-value project`}
REGION=${3:-us-central1}

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "Deploying the service: $SERVICE_NAME..."

gcloud run deploy "$SERVICE_NAME" \
    --source . \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated

echo "Granting DNS Administrator role to the default compute service account..."

# Get the project ID and number to construct the default service account email
# Grant the DNS Administrator role to the service account
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/dns.admin"
