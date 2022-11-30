# Challenge 1 - Create Managed Instance Groups

[< Previous Challenge](./Challenge-00.md) - **[Home](../README.md)** - [Next Challenge>](./Challenge-02.md)

## Introduction

A managed instance group uses an instance template to create a group of identical instances. Use these to create the backend of the HTTP Load Balancer.

## Description

### Create Instance Template
- Create an instance template with the following configuration: 
    - **Name**: lb-backend-template
    - **Series**: N1
    - **Startup Script**: 
        ```bash
        #! /bin/bash
        sudo apt-get update
        sudo apt-get install apache2 -y
        sudo a2ensite default-ssl
        sudo a2enmod ssl
        export vm_hostname="$(hostname)"
        sudo echo "Page served from: $vm_hostname" | \
        sudo tee /var/www/html/index.html
        ```
    - **Networking**:
        - Use the default Network and Subnet(us-east1) 
        - Add a network tag named **allow-health-check**  
    
            > **NOTE**: The network tag **allow-health-check** ensures that the HTTP Health Check and SSH firewall rules apply to these instances.



### Create Managed Instance Group

- Create a new stateless managed instance group with the following configuration: 
    - **Name:** lb-backend-example
    - **Location:** Single zone
    - **Region:** us-east1
    - **Zone:** us-east1-b
    - **Instance template:** lb-backend-example
    - **Autoscaling:** Don't autoscale
    - **Number of instances:** 1

### Add A Named Port 
For your instance group, set port 80 as a "named port" port. This allows the load balancing service to forward traffic to the named port.

## Success Criteria

- You've created an instance template which defines instance properties including type, boot disk image, and subnet
- Your instance template is configured to allow health checks 
- You've created a new managed instance group as the HTTP backend 
- A port is configured to allow the load balancing service to forward traffic to the backend 

## Learning Resources

- [Instance Templates](https://cloud.google.com/compute/docs/instance-templates)
- [Instance Groups](https://cloud.google.com/compute/docs/instance-groups)
- [Load balancing and scaling](https://cloud.google.com/compute/docs/load-balancing-and-autoscaling)
- [gcloud compute instance-groups](https://cloud.google.com/sdk/gcloud/reference/compute/instance-groups)
