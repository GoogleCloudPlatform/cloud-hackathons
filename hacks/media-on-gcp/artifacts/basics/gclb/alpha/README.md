# Installing the GCLB by hand

These instructions are to do everything by hand, they will be converted to Terraform

## Steps

These are the steps that need to run in this order to create the GCLB

### Create static external IP address

```bash
gcloud compute addresses create gclb-ip --global
```

### Create 3 internet NEGs

Using the Zonal NEG which should be used for VMs hosted on GCP. This means we can use private addresses

```bash
gcloud compute network-endpoint-groups create gclb-ateme-neg --zone=europe-west1-b --network=default --network-endpoint-type=GCE_VM_IP --subnet=default
```

### Testing Unmanaged Instance Group

Here we will see if we can group the VMs into an unmanaged instance group

### Create the backends

### Call out to get the team name

Curl needed here

### Issue the certificate

Issue a certificate for `teamx.media.ghacks.dev` as per the team name vended.

### Create the frontend

### Create the GCLB
