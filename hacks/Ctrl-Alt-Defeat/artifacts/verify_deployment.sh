#!/bin/bash
#
# Definitive Verification Script for Project Cygnus CTF Environment
#
# This script provides an accurate check of the deployed resources against
# the final, intended state for the CTF challenges.
#
# Usage:
# 1. Save this file as verify_deployment_final.sh
# 2. Make it executable: chmod +x verify_deployment_final.sh
# 3. Run the script with your Project ID as the first argument:
#    ./verify_deployment_final.sh your-gcp-project-id
#

# --- Setup ---
if [ -z "$1" ]; then
    echo "ERROR: No Project ID provided."
    echo "Usage: ./verify_deployment_final.sh [your-gcp-project-id]"
    exit 1
fi

PROJECT_ID="$1"
REGION="europe-west4" # As defined in our terraform.tfvars

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper for printing results
print_result() {
    if [ "$2" -eq 0 ]; then
        echo -e "[  ${GREEN}OK${NC}  ] $1"
    else
        echo -e "[ ${RED}FAIL${NC} ] $1"
        ((FAILURES++))
    fi
}

# State
FAILURES=0

echo -e "${YELLOW}--- Starting Final Verification for Project: $PROJECT_ID ---${NC}"
echo -e "${YELLOW}This script checks the environment is in the correct STARTING state for the CTF.${NC}\n"

# --- Verification Functions ---

check_public_bucket() {
    local BUCKET_NAME=$1
    local STAGE=$2
    local IS_PUBLIC=$(gcloud storage buckets get-iam-policy "gs://${BUCKET_NAME}" --project="$PROJECT_ID" --format="json" | \
                      jq -r '.bindings[] | select(.role == "roles/storage.objectViewer" and .members[] == "allUsers") | .role' 2>/dev/null)
    
    if [ "$IS_PUBLIC" == "roles/storage.objectViewer" ]; then
        print_result "Stage $STAGE: Bucket '${BUCKET_NAME}' is correctly PUBLIC." 0
    else
        print_result "Stage $STAGE: Bucket '${BUCKET_NAME}' is NOT public." 1
    fi
}

check_cloud_function() {
    local FUNC_JSON=$(gcloud functions describe "cygnus-dlp-trigger" --project="$PROJECT_ID" --region="$REGION" --format="json" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        print_result "Stage 1: Cloud Function 'cygnus-dlp-trigger' does NOT exist." 1
        return
    fi

    print_result "Stage 1: Cloud Function 'cygnus-dlp-trigger' exists." 0
    local SA_EMAIL=$(echo "$FUNC_JSON" | jq -r '.serviceConfig.serviceAccountEmail')
    local DEDICATED_SA="cygnus-func-runtime-sa@${PROJECT_ID}.iam.gserviceaccount.com"

    if [ "$SA_EMAIL" == "$DEDICATED_SA" ]; then
        print_result "Stage 1: Function is using the correct dedicated Service Account." 0
        echo -e "       ${BLUE}Note: This is an intentional improvement over the guide for better security.${NC}"
    else
        print_result "Stage 1: Function is using the wrong SA ($SA_EMAIL)." 1
    fi
}

check_source_repo() {
    local REPO_NAME="cygnus-processor-app"
    if ! gcloud source repos describe "$REPO_NAME" --project="$PROJECT_ID" --format="value(name)" >/dev/null 2>&1; then
        print_result "Stage 2: Source Repository '${REPO_NAME}' does NOT exist." 1
        return
    fi
    print_result "Stage 2: Source Repository '${REPO_NAME}' exists." 0

    # Clone to a temporary directory to inspect files
    local TEMP_DIR=$(mktemp -d)
    if gcloud source repos clone "$REPO_NAME" "$TEMP_DIR" --project="$PROJECT_ID" >/dev/null 2>&1; then
        if [ -f "${TEMP_DIR}/Dockerfile" ]; then
            print_result "Stage 2: Insecure 'Dockerfile' found in source repo." 0
        else
            print_result "Stage 2: Insecure 'Dockerfile' NOT found." 1
        fi
        rm -rf "$TEMP_DIR"
    else
        print_result "Stage 2: Could not clone repository to verify content." 1
    fi
}

check_participant_task_resource_absence() {
    local RESOURCE_NAME=$1
    local CHECK_COMMAND=$2
    local EXPECTED_STATE=$3
    
    # Suppress stderr to handle "Not Found" errors gracefully
    eval "$CHECK_COMMAND" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_result "$EXPECTED_STATE: Resource '${RESOURCE_NAME}' is correctly ABSENT." 0
    else
        print_result "$EXPECTED_STATE: Resource '${RESOURCE_NAME}' was found but should be ABSENT." 1
    fi
}

# --- Main Execution ---
echo "--- Verifying Baseline Infrastructure ---"
check_public_bucket "${PROJECT_ID}-cygnus-raw-telemetry" "1"
check_public_bucket "${PROJECT_ID}-cygnus-temporary-public-bucket" "5"
check_cloud_function
check_source_repo

echo -e "\n--- Verifying Participant Tasks (Absence of Resources) ---"
check_participant_task_resource_absence \
    "cygnus-approved-images" \
    "gcloud artifacts repositories describe cygnus-approved-images --project=$PROJECT_ID --location=$REGION" \
    "Stage 2"

check_participant_task_resource_absence \
    "cygnus-prediction-service" \
    "gcloud run services describe cygnus-prediction-service --project=$PROJECT_ID --region=$REGION" \
    "Stage 3/4"

# --- Summary ---
echo ""
if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}--- Verification Complete: All checks passed! The environment is in the correct state for the CTF. ---${NC}"
else
    echo -e "${RED}--- Verification Complete: $FAILURES check(s) failed. Please review the output above. ---${NC}"
fi
