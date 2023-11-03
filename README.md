{% include feature_row %}

## What are gHacks?

gHacks are a set of challenge based hackathons that can be hosted in-person or virtually via Google Meet.

Attendees work in teams of 3 to 5 people to solve a series of technical challenges for a given technology or solution scenario. Challenges describe high-level tasks and goals to be accomplished. gHacks are **NOT** step-by-step labs.

gHacks are designed to be a collaborative learning experience.  Attendees "learn from" and "share with" each other. Without giving step-by-step instructions for the challenges, attendees have to work hard to solve the challenges together as a team.  This results in greater knowledge retention for the attendees. 

Teams are not left on their own to solve the challenges. Coaches work with each team to provide guidance for, but not answers to, the challenges.  The coaches may also provide lectures and/or demos to introduce concepts needed to solve the challenges, as well as review challenge solutions throughout the event.

## The gHacks Collection

### Data & AI
- [MLOps on GCP](./hacks/mlops-on-gcp/README.md)
  > We will be implementing the full lifecycle of an ML project. We'll provide you with a sample code base and you'll work on automating continuous integration (CI), continuous delivery (CD), and continuous training (CT) for a machine learning (ML) system. 
- [Real-time analytics with Change Data Capture (CDC)](./hacks/realtime-analytics/README.md)
  > We will be going through replicating and processing operational data from an Oracle database into Google Cloud in real time. You'll also figure out how to forecast future demand, and how to visualize this forecast data as it arrives.
- [Demand Forecasting](./hacks/demand-forecasting/README.md)
  > We will be implementing a state of the art deep learning forecasting model in just a few hours thanks to Vertex AI AutoML. We'll provide you with a sample notebook and you’ll work on extending that notebook to train a model, run inference and see results. 
- [Introduction to GenAI](./hacks/genai-intro/README.md)
  > We will build a system to catalog scientific papers. Whenever new papers are uploaded to Cloud Storage a Cloud Function will be triggered and use Vertex AI Foundation Model LLM to extract the title and summarize the paper. We'll store this data in BigQuery and use an LLM directly from BigQuery to classify the papers into distinct categories and then implement semantic search using text embeddings and finally we'll use Vector Search as a scalable solution.

### Infrastructure
- [Security with reCAPTCHA and Cloud Armor](./hacks/recaptcha-cloudarmor-security/README.md)
  > We will be setting up gHacks+, the hottest new streaming site. We will configure an HTTP Load Balancer in front of the site and then you'll learn how to set up a reCAPTCHA session token site key and embed it the site. You will also learn how to set up redirection to reCAPTCHA Enterprise manual challenge. We will then configure a Cloud Armor bot management policy to showcase how bot detection can protect gHacks+ from malicious bot traffic.
- [Infrastructure as Code with Terraform](./hacks/iac-with-tf/README.md)
  > This hack is intended as an introduction to provisioning GCP resources using Terraform. We'll start with the basics of Infrastructure as Code (IaC) and help you automate the process of infrastructure provisioning.

### Application Development
- [Intro to Google Kubernetes Engine](./hacks/intro-to-gke/README.md)
  > We will experience what a cloud developer needs to go through to successfully deploy an application to Google Kubernetes Engine. You will learn how to containerize a monolithic application; create a cluster; deploy, run and scale the application and then update the application and rollout the new version with zero downtime.
- [Ready, Steady, Cloud Run!](./hacks/cloud-run/README.md)
  > We'll be using Cloud Run to quickly configure, deploy and troubleshoot a web service. During the process we'll introduce different ways to store data for the web service and learn about how to discover and fix issues. 

### Industry Solutions
- [Gaming on Google Cloud](./hacks/gaming-on-gcp/README.md)
  > This hack will showcase the power of Google Cloud's gaming services and help you create innovative gaming solutions using technologies like the Agones Game Server, Open Match, Cloud Spanner, and BigQuery.

### Operations
- Coming soon...

### Networking
- Coming soon...

##  License
This repository is licensed under Apache2 license. More info can be found [here](./LICENSE).
