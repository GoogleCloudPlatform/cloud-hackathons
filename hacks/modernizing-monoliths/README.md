# Modernizing the Monolith: Containerizing and Deploying to Kubernetes

## Introduction

Modernizing the Monolith is a hands-on experience helping you learn how to quickly move your applications as they exist today into containers and on to Google Kubernetes Engine (GKE).

## Learning Objectives

In this hack you will be taking on the role of a DevOps engineer tasked with containerizing a monolithic web game and deploying, testing, and debugging it on GKE. You will learn:

- **Containers**
  - Creating a Dockerfile
    - Using multi-stage builds
  - Building images
  - Running containers with Docker
  - SSH’ing into Docker containers
  - Pushing and Pulling Docker images
- **GKE**
  - Creating a cluster
  - Creating and resizing node pools
  - Creating services
    - Creating an ingress
  - Deploying your application
  - Creating deployments
  - SSH’ing into pods
  - Implementing Vertical Pod Autoscaling
  - Implementing Horizontal Pod Autoscaling
  - Creating a kubeconfig file
  - Troubleshooting

## Challenges

- Challenge 1: Containerize the web application
  - Write a Dockerfile to create your container and then push it to Artifact Registry.
- Challenge 2: Deploying on GKE
  - Create a cluster and deploy the containerized web application on it. Fine tune your pod and node sizes, and play test the game to make sure everything is working!
- Challenge 3: Speedrun - containerize and deploy the load testing application
  - Use what you learned from challenges 1 and 2 to containerize the test client application and scale it up on GKE to test your servers.

## Prerequisites

- Your own GCP project with Owner IAM role
- Exemption for your project to any security policy that would prevent you from creating and using external IPs

## Contributors

- Damian Lance

## Challenge 1: Containerize the web application

### Introduction

You’ve just started working as a DevOps Engineer for a company that hosts servers for different games. The company has been running game servers in Google Compute Engine across different Managed Instance Groups which has been working great so far, but occasionally the Testing team fails to setup their local environments correctly and end up approving bad code. The teams have been learning about containers, and are excited to start using them so they no longer have to deal with environment issues.

You have been assigned the *Dungeon Crawl Stone Soup* workload. Your team is looking to you to containerize the latest version of the game with Docker, verify that it plays, and host it in Artifact Registry.

Here are some helpful terms to know for this section:

- *Image* - prepackaged files, code, and commands for running an application. And images are reusable, so once you've got it you can take it wherever you want to!
- *Container* - an active, running image
- *Dockerfile* - the set of instructions to build your image

You can read more about these terms by folowing the *What is a container?* and *What is a Dockerfile?* links in the Learning Resources section below.

### Description

In this challenge, you will write a Dockerfile to create an image for the web game, *Dungeon Crawl Stone Soup* and after creating and testing the image, push it to Artifact Registry.

You can find an excellent sample Dockerfile by following the *Multi-Stage Dockerfiles* link in the Learning Resources section below.

To help you be successful, here are some reminders of things you will need to do:

- Download the application code
- **Compiling DCSS with `make WEBTILES=y` command will take 25+ minutes**. Compile the code on your host machine and create your image from the compiled code to save time on your builds. Work on your Dockerfile while this compiles!
- Create a Dockerfile in the same directory as the application that will do selects a base image, install needed packages and files, and start the application
- Run a Docker build to build a container image
- Create and test a local container before pushing to Artifact Registry or dockerhub

### Success Criteria

- Verify your Docker image is smaller than 600MB
- Demonstrate you can play the game on a container created from your image
- Demonstrate that you can SSH into your running container
- Verify your container image is in Artifact Registry

### Learning Resources

- [Install Docker Engine](https://docs.docker.com/engine/install/)
- [Install Git](https://github.com/git-guides/install-git)
- [What is a container?](https://www.docker.com/resources/what-container/)
- [What is a Dockerfile?](https://www.cloudbees.com/blog/what-is-a-dockerfile)
- [Reference for building a Dockerfile](https://docs.docker.com/engine/reference/builder/)
- [Multi-Stage Dockerfiles](https://pmac.io/2019/02/multi-stage-dockerfile-and-python-virtualenv/)
- [Code for the web game, Dungeon Crawl Stone Soup](https://github.com/TheLanceLord/crawl)
- [Webgame prerequisites](https://github.com/TheLanceLord/crawl/tree/master/crawl-ref/source/webserver#prerequisites)
- [Webgame install instructions](https://github.com/TheLanceLord/crawl/tree/master/crawl-ref/INSTALL.md)

### Tips

- Multi-Stage Dockerfiles are important for keeping your image size down. You can always write your Dockerfile as a single stage, and then break it up once you've got the containerized application working.

### Advanced Challenges

Too comfortable?  Eager to do more?  Try these additional challenges!

- Re-write your Dockerfile to compile the code

## Challenge 2: Deploy with GKE

### Introduction

With your Docker image ready and tested, you are ready to get it running on GKE so players can start enjoying this retro-style rogue-like game. Your manager asks that you try to keep the node sizes small to keep costs down, and that for now you limit the number of nodes to 3.

Here are some helpful terms to know for this section:

- *Kubernetes* - an open-source system for automating deployment, scaling, and management of containerized applications
- *Node* - worker machines that run your containerized applications and other workloads
- *Cluster* - a group of nodes that run containerized applications. Every cluster has at least one worker node
- *Node pool* - a group of nodes within a cluster that all have the same configuration
- *Pod* - the most basic deployable unit within a Kubernetes cluster, capable of running one or more containers
- *Namespace* - an abstraction used by Kubernetes to organize objects in a cluster and provide a way to divide cluster resources
- *Deployment* - an API object that manages a replicated application
- *Service* - a method for exposing a network application that is running as one or more Pods in your cluster
- *K8s* - an abbreviation for Kubernetes

### Description

In this challenge, you will create a GKE cluster and use it to host playable *Dungeon Crawl Stone Soup* game server pods.

To help you be successful, here are some reminders of things you will need to do:

- Create a cluster and node pool
- Create a deployment for your application and a service to direct traffic to it. Don't forget the liveness and readiness probes!
- Create a namespace to help keep things organized

> **Note**

- Use `e2-standard-2` nodes in your node pool as they will be the most cost effective. Don't worry about performance for this gHack!
- The general GKE best practices are (note: there are always exceptions!):
  - Don't set CPU limits
  - Set memory limit equal to memory request

### Success Criteria

- A cluster with three nodes in a node pool
- Default node pool deleted
- Liveness and readiness probes implemented on the game server deployment
- SSH into a game server container and verify the contents match with those of the [crawl-ref](https://github.com/TheLanceLord/crawl/tree/master/crawl-ref/source) folder
- Demonstrate you can play the game by connecting to your service's IP address

### Learning Resources

- [Kubernetes resources under the hood — Part 1](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-1-4f2400b6bb96)
- [Kubernetes resources under the hood — Part 2](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-2-6eeb50197c44)
- [Kubernetes resources under the hood — Part 3](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-3-6ee7d6015965)
- [Stop using CPU limits](https://home.robusta.dev/blog/stop-using-cpu-limits)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Namespaces Walkthrough](https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/)
- [Kubernetes Glossary](https://kubernetes.io/docs/reference/glossary/?fundamental=true)

## Challenge 3: Load testing

### Introduction

The testing team is putting their finishing touches on their load testing application, and they will need your help containerizing the code so that it can be scaled up in GKE. Your aim is to conduct a 100 player test against your game servers.

### Description

In this challenge, you will containerize the load testing application for your Dungeon Crawl Stone Soup game servers, and deploy a 100 pod test using GKE.

Here is the test application code [synthetic_player.py](https://github.com/TheLanceLord/crawl/blob/master/load-testing/synthetic_player.py)

This application uses [Selenium](https://www.selenium.dev/) with a Google Chrome webdriver to simulate player connectivity and interactions with the game. (note: at the time of course creation, running the `apt-get -y --fix-broken install;` and repeating the `dpkg -i google-chrome-stable_current_amd64.deb;` command were necessary to get the application to work.)

The install instructions:

```shell
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
dpkg -i google-chrome-stable_current_amd64.deb; \
apt-get -y --fix-broken install; \
dpkg -i google-chrome-stable_current_amd64.deb; \
pip3 install -r requirements.txt; \
```

requirements.txt:

```text
selenium==4.11.2
webdriver-manager==4.0.0
```

To help you be successful, here are some reminders of things you will need to do:

- Create a node pool
- Create a deployment for your application and a service to direct traffic to it. Don't forget the liveness and readiness probes!
- Create a namespace to help keep things organized

> **Note**

- Use `e2-standard-2` nodes in your node pool as they will be the most cost effective, and if you run out of E2, use N2. Don't worry about performance for this gHack!
- The general GKE best practices are (note: there are always exceptions!):
  - Don't set CPU limits
  - Set memory limit equal to memory request
- The load testing clients sometimes have connection issues, don't be concerned if GKE shows you have 100 pods running, but your application only shows a handful

### Success Criteria

- 100 test client pods spun up in a running state
- Navigate to the public endpoint of your service and login to see the list of bots playing the game. View one of their in-progress game sessions to see their attempt

### Learning Resources

- [Kubernetes resources under the hood — Part 1](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-1-4f2400b6bb96)
- [Kubernetes resources under the hood — Part 2](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-2-6eeb50197c44)
- [Kubernetes resources under the hood — Part 3](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-3-6ee7d6015965)
- [Stop using CPU limits](https://home.robusta.dev/blog/stop-using-cpu-limits)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Namespaces Walkthrough](https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/)
- [Kubernetes Glossary](https://kubernetes.io/docs/reference/glossary/?fundamental=true)
