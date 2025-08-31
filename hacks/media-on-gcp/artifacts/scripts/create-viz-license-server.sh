VM_NAME=${1:-"`gcloud config get-value project`-license"}
REGION=${2:-"europe-west4"}
ZONE=${3:-"europe-west4-a"}

gcloud compute addresses create $VM_NAME-ip --region=$REGION
IP=$(gcloud compute addresses describe $VM_NAME-ip --region=$REGION --format="get(address)")

gcloud compute instances create $VM_NAME \
	--zone=$ZONE --machine-type=n1-standard-1 \
	--network-interface=address=$IP,network-tier=PREMIUM,nic-type=GVNIC,stack-type=IPV4_ONLY,network=default \
	--tags=http-server,https-server,lb-health-check \
	--create-disk=auto-delete=yes,boot=yes,device-name=$VM_NAME,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20250613,mode=rw,size=50,type=pd-balanced \
	--shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
	--metadata=enable-osconfig=TRUE,enable-oslogin=true \
	--maintenance-policy=TERMINATE --provisioning-model=STANDARD
