# “Modernizing

## Introduction

Welcome to the coach's guide for the Modernizing Monoliths gHack. Here you will find links to specific guidance for coaches for each of the challenges.

Remember that this hack includes a optional [lecture presentation](resources/lecture.pdf) that features short presentations to introduce key topics associated with each challenge. It is recommended that the host present each short presentation before attendees kick off that challenge.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Containerize the web application
   - Write a Dockerfile to create your container and then push it to Artifact Registry.
- Challenge 2: Deploying on GKE
   - Create a cluster and deploy the containerized web application on it. Fine tune your pod and node sizes, and play test the game to make sure everything is working!
- Challenge 3: Speedrun - containerize and deploy the load testing application
   - Use what you learned from challenges 1 and 2 to containerize the test client application and scale it up on GKE to test your servers

## Coach Prerequisites

This hack has prerequisites that a coach is responsible for understanding and/or setting up BEFORE hosting an event. Please review the [gHacks Hosting Guide](https://ghacks.dev/faq/howto-host-hack.html) for information on how to host a hack event.

The guide covers the common preparation steps a coach needs to do before any gHacks event, including how to properly setup Google Meet and Chat Spaces.

### Student Resources

Before the hack, it is the Coach's responsibility create and make available needed resources including: 
- Files for students
- Lecture presentation
- Terraform scripts for setup (if running in the customer's own environment)

Follow [these instructions](https://ghacks.dev/faq/howto-host-hack.html#making-resources-available) to create the zip files needed and upload them to your gHack's Google Space's Files area. 

Always refer students to the [gHacks website](https://ghacks.dev) for the student guide: [https://ghacks.dev](https://ghacks.dev)

> **Note** Students should **NOT** be given a link to the gHacks GitHub repo before or during a hack. The student guide intentionally does **NOT** have any links to the Coach's guide or the GitHub repo.

## Google Cloud Requirements

This hack requires students to have access to Google Cloud project where they can create and consume Google Cloud resources. These requirements should be shared with a stakeholder in the organization that will be providing the Google Cloud project that will be used by the students.

- Participants will need the Owner role on their respective projects

## Suggested Hack Agenda

- Day 1
  - Challenge 1 (~3 hours)
  - Challenge 2 (~3 hours)
  - Challenge 3 (~2 hours)

## Repository Contents

- `README.md`
  - Student's Challenge Guide
- `solutions.md`
  - Coach's Guide and related files
- `./resources`
  - Resource files, sample code, scripts, etc meant to be provided to students. (Must be packaged up by the coach and provided to students at start of event)
- `./artifacts`
  - Terraform scripts and other files needed to set up the environment for the gHack
- `./images`
  - Images and screenshots used in the Student or Coach's Guide

## Challenge 1: Containerize the web application

### Notes & Guidance

- Participant will need to download the [crawl repository](https://github.com/TheLanceLord/crawl) to their working environment and create their Dockerfile in the root folder of the repository
- [Normal challenge Dockerfile](./solutions/challenge-1/Dockerfile.normal) given time constraints. Requires the student to compile the code manually
- [Advanced challenge Dockerfile](./solutions/challenge-1/Dockerfile.advanced), compiles the code from GitHub
- Useful Docker commands (may need to use `sudo`):
  - `docker build .` creates the image
  - `docker tag <IMAGE_ID> <NAMESPACE>/<REPOSITORY>:<TAG>` tags the image for pushing
  - `docker push <NAMESPACE>/<REPOSITORY>:<TAG>` pushes the image to dockerhub unless otherwise specified
  - `docker run -d <IMAGE_ID>` runs your container in detached mode
  - `docker exec -it <CONTAINER_NAME> /bin/bash` SSH into your running container

## Challenge 2: Deploying on GKE

### Notes & Guidance

- [Solution .yaml for game server Deployment](./solutions/challenge-2/game_server_deployment.yaml)
- [Solution .yaml for the Service](./solutions/challenge-2/service.yaml)
- Cloud Console commands:
  - Create the cluster `gcloud container clusters create opensource-games --zone us-central1-a`
  - Create the node pool `gcloud container node-pools create dcss-gameservers --cluster opensource-games --zone us-central1-a --machine-type e2-standard-2 --num-nodes 3`
  - Create the deployment and service using the `kubectl apply -f <FILENAME>` command for each file
  - Check on the deployment with `kubectl get deployments --namespace=<NAMESPACE>`
  - Check on the service with `kubectl get services --namespace=<NAMESPACE>`

## Challenge 3: Speedrun - containerize and deploy the load testing application

### Notes & Guidance

- Participants will want the [synthetic_player.py](https://github.com/TheLanceLord/crawl/blob/master/load-testing/synthetic_player.py), a Dockerfile, and the requirements.txt file in the same folder
  - requirements.txt
    ```
    selenium==4.11.2
    webdriver-manager==4.0.0
    ```
- [Test client Dockerfile](./solutions/challenge-3/Dockerfile)
- Useful Docker commands (may need to use `sudo`):
  - `docker build .` creates the image
  - `docker tag <IMAGE_ID> <NAMESPACE>/<REPOSITORY>:<TAG>` tags the image for pushing
  - `docker push <NAMESPACE>/<REPOSITORY>:<TAG>` pushes the image to dockerhub unless otherwise specified
  - `docker run -d <IMAGE_ID>` runs your container in detached mode
  - `docker exec -it <CONTAINER_NAME> /bin/bash` SSH into your running container
- [Test client .yaml](./solutions/challenge-3/test_client_e2.yaml)
- Cloud Console commands:
  - Create the node pool `gcloud container node-pools create dcss-n2-clients --cluster opensource-games --zone us-central1-a --machine-type e2-standard-2 --enable-autoscaling --total-min-nodes=0 --total-max-nodes=8 --max-pods-per-node=20`
  - Create the deployment `kubectl apply -f <FILENAME>`
  - Check on the deployment with `kubectl get deployments --namespace=<NAMESPACE>`
  - Check on the pods with `kubectl get pods --namespace=<NAMESPACE>`