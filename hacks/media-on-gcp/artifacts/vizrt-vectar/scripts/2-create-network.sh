NETWORK=${1:-"`gcloud config get-value project`-vpc"}
REGION=${2:-"us-central1"}
RANGE=${3:-"10.1.0.0/16"}
PROJECT=${4:-`gcloud config get-value project`}

gcloud compute networks create $NETWORK --subnet-mode=custom --project=$PROJECT 
gcloud compute networks subnets create $REGION --range=$RANGE --stack-type=IPV4_ONLY --network=$NETWORK --region=$REGION --project=$PROJECT 
gcloud compute firewall-rules create allow-remotes --direction=INGRESS --priority=1000 --network=$NETWORK --action=ALLOW --rules=tcp:22,tcp:80,tcp:443,tcp:3389,tcp:8443,udp:8443,tcp:22350,udp:22350 --source-ranges=0.0.0.0/0 --project=$PROJECT 