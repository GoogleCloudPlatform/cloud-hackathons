# Installing the GCLB by hand

These instructions are to do everything by hand, they will be converted to Terraform

## Steps

These are the steps that need to run in this order to create the GCLB

### Create static external IP address

```bash
gcloud compute addresses create gclb-ip --global
```

### Create 3 instance groups

Create 3 instance groups, one per VM

```bash
gcloud compute network-endpoint-groups create gclb-ateme-neg --zone=europe-west1-b --network=default --network-endpoint-type=GCE_VM_IP --subnet=default
```

### Create the backends

Create 1 backend for each of the instance groups

### Issue the certificate

Issue a certificate for `teamx.media.ghacks.dev` as per the team name vended. 

Within the certification, put all the domains, eg:
- nea
- darwin
- norsk

### Create the GCLB

Now weave it all together:
- Create the GCLB and it's frontend
- Attach the certificate to the frontend
- Create routing rules that do:
    - for each of the domains, eg: nea
        - route to the same backend (which in turn goes to the instance group, which in turn goes to the VM)





### Call out to get the team name

Curl needed here
