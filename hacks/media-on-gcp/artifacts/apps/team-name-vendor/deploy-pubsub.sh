#!/bin/bash

TOPIC_NAME=${1:-team-name-vendor}
SUBSCRIPTION_NAME="${TOPIC_NAME}-sub"

# Create the Pub/Sub topic with 31-day message retention
gcloud pubsub topics create "$TOPIC_NAME" \
    --message-retention-duration=31d

# Create the pull subscription with no expiration
gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" \
    --topic="$TOPIC_NAME" \
    --expiration-period=never