```
gcloud compute instances create vizrt-vectar-01 \
    --zone=europe-west4-b \
    --machine-type=g2-standard-16 \
    --accelerator=type=nvidia-l4-vws,count=1 \
    --maintenance-policy="TERMINATE" \
    --image=vizrt-vectar-machine \
    --image-project=qwiklabs-resources
    --boot-disk-size=50 \
    --boot-disk-type=pd-balanced \
    --network=default \
    --subnet=default
```

```
gcloud compute firewall-rules create allow-remotes --direction=INGRESS --priority=1000 --network=default --action=ALLOW
--rules=tcp:22,tcp:80,tcp:443,tcp:3389,tcp:4172,tcp:8443,tcp:22350,udp:4172,udp:8443,udp:22350
--source-ranges=0.0.0.0/0
```