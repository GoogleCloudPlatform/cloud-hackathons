# Installing the GCLB by hand

These instructions are to do everything by hand, they will be converted to Terraform

## Steps

These are the steps that need to run in this order to create the GCLB

### Call out to get the team name

Terraform http module

### Create static external IP addresses

We need to create an address for the GCLB and use it below

We will also create addresses for all 5 VMs and use them later

```bash
gcloud compute addresses create gclb-ip --global
```

Here's a list:

```
gclb-ext-ip
resolve-ext-ip
resolve-int-ip
norsk-ext-ip
norsk-int-ip
titan-ext-ip
titan-int-ip
nea-ext-ip
nea-int-ip
darwin-ext-ip
darwin-int-ip
vectar-ext-ip
vectar-int-ip
gemini-agent-ext-ip
gemini-agent-int-ip
```

### Create zone in student project

Create then get the NS 4 servers from that zone
Add a wildcard A record with the external IP

### Create an NS record set in the Shared Project

Create the NS record set using the 4 servers from above

### Create an unmanaged instance group per VM

Create instance groups, one per VM

```bash
gcloud compute network-endpoint-groups create gclb-ateme-neg --zone=europe-west1-b --network=default --network-endpoint-type=GCE_VM_IP --subnet=default
```

### Create a single health check

Use this everywhere

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
