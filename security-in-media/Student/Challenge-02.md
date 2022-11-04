# Challenge 2 - Setup Your HTTP Load Balancer

[< Previous Challenge](./Challenge-01.md) - **[Home](../README.md)** - [Next Challenge>](./Challenge-03.md)

## Introduction

Configure the HTTP Load Balancer to send traffic to your backend instance group named: **lb-backend-example** created in Challenge 1.

## Description

### Start the configuration
- Create a classic HTTPS load balancer to send traffic from the Internet to your VMs named: ```http-lb```

### Configure the backend
Backend services direct incoming traffic to one or more attached backends. Each backend is composed of an instance group and additional serving capacity metadata.

Configure the backend with the following configuration:

 - **Name**: http-backend
 - **Protocol**: HTTP
 - **Named Port**: http
 - **Instance Group**: lb-backend-example
 - **Port Numbers**: 80

Configure the Health Check with the following configuration: 

- **Name**: http-health-check
- **Protocol**: TCP
- **Port**: 80
- **Logging**: enabled
- **Sample Rate**: 1

> **NOTE:** Health checks determine which instances receive new connections. This HTTP health check polls instances every 5 seconds, waits up to 5 seconds for a response and treats 2 successful or 2 failed attempts as healthy or unhealthy, respectively.

### Configure the frontend
The host and path rules determine how your traffic will be directed. For example, you could direct video traffic to one backend and static traffic to another backend. However, you are not configuring the Host and path rules in this hack.

Configure the frontend with the following configuration: 

- **Protocol**: HTTP
- **IP Version**: IPv4
- **IP Address**: Ephemeral
- **Port**: 80

### Test the HTTP Load Balancer
Now that you created the HTTP Load Balancer for your backends, verify that traffic is forwarded to the backend service. To test IPv4 access to the HTTP Load Balancer.

> **NOTE:** It might take up to 15 minutes to access the HTTP Load Balancer. In the meantime, you might get a 404 or 502 error. Keep trying until you see the page load.

## Success Criteria

- You've created an HTTP load balancer 
- Traffic is forwarded by the load balancer to the backend created in Challenge 1
- The load balancer has a working IPv4 address 

## Learning Resources

- [External HTTP(S) Load Balancing](https://cloud.google.com/load-balancing/docs/https)

