PROJECT=${1:-`gcloud config get-value project`}

# enable the Compute API
gcloud services enable compute.googleapis.com --project=$PROJECT

# GF: This is for Argo environments only
gcloud services enable orgpolicy.googleapis.com --project=$PROJECT
gcloud org-policies reset constraints/compute.vmExternalIpAccess --project=$PROJECT
