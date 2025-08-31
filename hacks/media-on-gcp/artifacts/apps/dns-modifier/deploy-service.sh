#!/bin/bash

SERVICE_NAME=${1:-dns-modifier}
REGION=${2:-us-central1}

gcloud run deploy "$SERVICE_NAME" \
    --source . \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated
