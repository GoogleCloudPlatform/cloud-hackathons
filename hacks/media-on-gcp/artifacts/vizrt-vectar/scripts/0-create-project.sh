PROJECT=${1:-"ghacks-vizrt-servers"}
ACCOUNT_ID=${2:-$(gcloud billing accounts list --format="value(ACCOUNT_ID)" --limit=1)}


# create the project and set it
gcloud projects create $PROJECT
gcloud config set project $PROJECT

# attach the billing account
gcloud billing projects link $PROJECT --billing-account=$ACCOUNT_ID
