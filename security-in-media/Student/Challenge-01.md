# Challenge 1 - Create Managed Instance Groups

[< Previous Challenge](./Challenge-00.md) - **[Home](../README.md)** - [Next Challenge>](./Challenge-02.md)

## Introduction

A managed instance group uses an instance template to create a group of identical instances. Use these to create the backend of the HTTP Load Balancer.

## Description

### Configure the instance templates
1. In the Cloud Console, navigate to **Navigation menu > Compute Engine > Instance templates**, and then click **Create instance template**.
1. For **Name**, type **lb-backend-template**.
1. For **Series**, select **N1**.
1. Click **Networking, Disks, Security, Management, Sole-Tenancy**.

    ![MIG Startup Script](../Images/mig-startup-script.png)

1. Go to the **Management** section and insert the following script into the **Startup script** field:

    ```bash
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo a2ensite default-ssl
    sudo a2enmod ssl
    sudo vm_hostname="$(curl -H "Metadata-Flavor:Google" \
    http://169.254.169.254/computeMetadata/v1/instance/name)"
    sudo echo "Page served from: $vm_hostname" | \
    tee /var/www/html/index.html
    ```

1. Click on the **Networking** tab, add the network tags: **allow-health-check**
1. Set the following values and leave all other values at their defaults:

    |Property|Value|
    |--|--|
    |Network|default|
    |Subnet|default (us-east1)|
    |Network tags|allow-health-check|
    
    > The network tag **allow-health-check** ensures that the HTTP Health Check and SSH firewall rules apply to these instances.

8. Click **Create**.
8. Wait for the instance template to be created.

### Create the managed instance group
1. Still in the **Compute Engine** page, click **Instance groups** in the left menu.

    ![Create MIG](../Images/mig-create-menu.png)

1. Click **Create instance group**. Select **New managed instance group (stateless)**.
1. Set the following values, leave all other values at their defaults:

    |Property|Value|
    |--|--|
    |Name|lb-backend-example|
    |Location|Single zone|
    |Region|us-east1|
    |Zone|us-east1-b|
    |Instance template|lb-backend-example|
    |Autoscaling|Don't autoscale|
    |Number of instances|1|

1. Click **Create**

### Add a named port to the instance group
1. For your instance group, use this command to define an HTTP service and map a port name to the relevant port. The load balancing service forwards traffic to the named port.

    ```bash
    gcloud compute instance-groups set-named-ports lb-backend-example \
        --named-ports http:80 \
        --zone us-east1-b
    ```

## Success Criteria

- A new blah is now blahing
- Approved traffic is doing a blah
- Blocked traffic is visibly blah'd

## Learning Resources

- [How to use the Google Cloud Console](http://zombo.com)
- [Markdown primer for github](http://zombo.com)
- [How to win friends](http://zombo.com)
- [How to influence people](http://zombo.com)

## Tips (Optional)

- Optional tips go here
- Don't give away
- Too much
