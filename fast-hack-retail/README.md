# gHacks - Intro To Kubernetes

## Introduction
This intro level hack will help you get hands-on experience with Docker, Kubernetes and the Google Kubernetes Engine Service (GKE) on Google Cloud. 

This hack starts off by covering containers, what problems they solve, and why Kubernetes is needed to help orchestrate them.  You will learn all of the Kubernetes jargon (pods, services, and deployments, oh my!).  By the end, you should have a good understanding of what Kubernetes is and be familiar with how to run it on Google Cloud.

This hack includes a optional [lecture presentation](Coach/Lectures.pptx) that features short presentations to introduce key topics associated with each challenge. It is recommended that the host present each short presentation before attendees kick off that challenge.

## Learning Objectives
In this hack you will solve a common challenge for companies migrating to the cloud. You will take a simple multi-tiered web app, containerize it, and deploy it to a GKE cluster. Once the application is in GKE, you will learn how to tweak all the knobs and levers to scale, manage and monitor it.

1. Containerize an application
1. Deploy a Kubernetes cluster in Azure and deploy applications to it.
1. Understand key Kubernetes management areas: scalability, upgrades and rollbacks, storage, networking, package management and monitoring

## Challenges
- Challenge 0: **[Pre-requisites - Ready, Set, GO!](Student/00-prereqs.md)**
   - Prepare your workstation to work with Azure, Docker containers, and AKS
- Challenge 1: **[Got Containers?](Student/01-containers.md)**
   - Package the "FabMedical" app into a Docker container and run it locally.
- Challenge 2: **[The Artifact Registry](Student/02-acr.md)**
   - Deploy an Artifact Registry, secure it and publish your container.
- Challenge 3: **[Introduction To Kubernetes](Student/03-k8sintro.md)**
   - Install the Kubernetes CLI tool, deploy a GKE cluster and verify it is running.
- Challenge 4: **[Your First Deployment](Student/04-k8sdeployment.md)**
   - Pods, Services, Deployments: Getting your YAML on! Deploy the "FabMedical" app to your GKE cluster. 
- Challenge 5: **[Scaling and High Availability](Student/05-scaling.md)**
   - Flex Kubernetes' muscles by scaling pods, and then nodes. Observe how Kubernetes responds to resource limits.
- Challenge 6: **[Deploy MongoDB to GKE](Student/06-deploymongo.md)**
   - Deploy MongoDB to GKE from a public container registry.
- Challenge 7: **[Updates and Rollbacks](Student/07-updaterollback.md)**
   - Deploy v2 of FabMedical to GKE via rolling updates, roll it back, then deploy it again using the blue/green deployment methodology.
- Challenge 8: **[Storage](Student/08-storage.md)**
   - Delete the MongoDB you created earlier and observe what happens when you don't have persistent storage. Fix it!
- Challenge 9: **[Helm](Student/09-helm.md)**
   - Install Helm tools, customize a sample Helm package to deploy FabMedical and use the Helm package to redeploy FabMedical to GKE.
- Challenge 10: **[Networking](Student/10-networking.md)**
   - Explore integrating DNS with Kubernetes services and explore different ways of routing traffic to FabMedical by configuring an Ingress Controller.
   
## Prerequisites

- Access to a GCP project with Owner IAM role
   - **NOTE:** If needed a qwiklab environment can be provisioned.
- [**gCloud CLI**](https://cloud.google.com/sdk/docs/install)
   - Update to the latest
- Alternatively, you can use the [**Google Cloud Shell**](https://shell.cloud.google.com/)
- [**Visual Studio Code**](https://code.visualstudio.com/)

## Repository Contents
- `../Coach/Guides`
  - [Lecture presentation](Coach/Lectures.pptx) with short presentations to introduce each challenge.
- `../Coach/Solutions`
   - Example solutions to the challenges (If you're a student, don't cheat yourself out of an education!)
- `../Student/Resources`
   - FabMedial app code and sample templates to aid with challenges

## Contributors
- Gino Filicetti
- Murat Eken