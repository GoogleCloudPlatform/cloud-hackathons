VM_NAME=${1:-"`gcloud config get-value project`-vectar"}
REGION=${2:-"us-central1"}
ZONE=${3:-"us-central1-a"}
RANGE=${4:-"10.1.0.0/16"}
PROJECT=${5:-`gcloud config get-value project`}

gcloud compute addresses create $VM_NAME-ip --region=$REGION
IP=$(gcloud compute addresses describe $VM_NAME-ip --region=$REGION --format="get(address)")

gcloud compute instances create $VM_NAME \
	--zone=$ZONE --machine-type=g2-standard-16 \
	--network-interface=address=$IP,network-tier=PREMIUM,nic-type=GVNIC,stack-type=IPV4_ONLY,subnet=$REGION \
	--accelerator=count=1,type=nvidia-l4-vws \
	--tags=http-server,https-server,lb-health-check \
	--create-disk=auto-delete=yes,boot=yes,device-name=$VM_NAME,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20250613,mode=rw,size=50,type=pd-balanced \
	--create-disk=auto-delete=yes,device-name=disk-2,mode=rw,name=$VM_NAME-disk-2,size=200,type=pd-balanced \
	--create-disk=auto-delete=yes,device-name=disk-3,mode=rw,name=$VM_NAME-disk-3,size=500,type=pd-ssd \
	--shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
	--metadata=enable-osconfig=TRUE,enable-oslogin=true \
	--maintenance-policy=TERMINATE --provisioning-model=STANDARD