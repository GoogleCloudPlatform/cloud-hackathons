VM_NAME=${1:-"`gcloud config get-value project`-license"}
REGION=${2:-"us-central1"}
ZONE=${3:-"us-central1-a"}
RANGE=${4:-"10.1.0.0/16"}
PROJECT=${5:-`gcloud config get-value project`}

gcloud compute addresses create $VM_NAME-ip --region=$REGION
IP=$(gcloud compute addresses describe $VM_NAME-ip --region=$REGION --format="get(address)")

gcloud compute instances create $VM_NAME \
	--zone=$ZONE --machine-type=n1-standard-1 \
	--network-interface=address=$IP,network-tier=PREMIUM,nic-type=GVNIC,stack-type=IPV4_ONLY,subnet=$REGION \
	--tags=http-server,https-server,lb-health-check \
	--create-disk=auto-delete=yes,boot=yes,device-name=$VM_NAME,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20250613,mode=rw,size=50,type=pd-balanced \
	--shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
	--metadata=enable-osconfig=TRUE,enable-oslogin=true \
	--maintenance-policy=TERMINATE --provisioning-model=STANDARD
