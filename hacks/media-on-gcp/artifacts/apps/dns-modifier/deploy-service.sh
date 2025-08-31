#!/bin/bash

SERVICE_NAME=${1:-dns-modifier}
PROJECT_ID=${2:-`gcloud config get-value project`}
REGION=${3:-us-central1}

echo "Deploying the service: $SERVICE_NAME..."

gcloud run deploy "$SERVICE_NAME" \
    --source . \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated
