{% include feature_row %}

<!-- markdownlint-disable-file first-line-heading -->

## What are gHacks?

gHacks are a set of challenge based hackathons that can be hosted in-person or virtually via Google Meet.

Attendees work in teams of 3 to 5 people to solve a series of technical challenges for a given technology or solution scenario. Challenges describe high-level tasks and goals to be accomplished. gHacks are **NOT** step-by-step labs.

gHacks are designed to be a collaborative learning experience.  Attendees "learn from" and "share with" each other. Without giving step-by-step instructions for the challenges, attendees have to work hard to solve the challenges together as a team.  This results in greater knowledge retention for the attendees.

Teams are not left on their own to solve the challenges. Coaches work with each team to provide guidance for, but not answers to, the challenges.  The coaches may also provide lectures and/or demos to introduce concepts needed to solve the challenges, as well as review challenge solutions throughout the event.

## The gHacks Collection

### Data & AI

- [Introduction to GenAI](./hacks/genai-intro/README.md)
  > We will build a system to catalog scientific papers. Whenever new papers are uploaded to Cloud Storage a Cloud Function will be triggered and use an LLM (Gemini) to extract the title and summarize the paper. We'll store this data in BigQuery and use the same LLM directly from BigQuery to classify the papers into distinct categories and then implement semantic search using text embeddings and finally we'll use Vector Search as a scalable solution.
- [MLOps on GCP](./hacks/mlops-on-gcp/README.md)
  > We will be implementing the full lifecycle of an ML project. We'll provide you with a sample code base and you'll work on automating continuous integration (CI), continuous delivery (CD), and continuous training (CT) for a machine learning (ML) system.
- [Crash Course in AI: Formula E Edition](./hacks/genai-fe/README.md)
  > We'll analyze multimodal data to detect crashes and find the drivers that were involved by using Gemini.
- [Easy Ads: From Concept to Creation with GenMedia](./hacks/genmedia-on-gcp/README.md)
  > In this hack, we'll step into the role of a creative director at a cutting-edge ad agency. Our mission is to create a compelling 20-30 second video advertisement for a revolutionary new product using Google Cloud's generative AI tools.
- [Introduction to Agents with ADK](./hacks/adk-intro/README.md)
  > **UPDATED FOR ADK 2** This is an introduction to Agentic AI using Agent Development Kit (ADK) framework. We'll be introducing various ADK concepts step-by-step, starting with a single agent and progressively building a tool-using, collaborative multi-agent system.
- [Custom ADK Agents and Gemini Enterprise app](./hacks/adk-ge/README.md)
  > In this hack, you will leverage the Agent Development Kit (ADK) to develop a custom AI agent, and deliver it to business users through the Gemini Enterprise. During the development of the agent we'll build custom tools, use BigQuery MCP server, deploy our agent to Agent Platform, integrate it with Gemini Enterprise app and experience how to build custom visualizations through A2UI.
- [Modernizing Classic Data Warehousing with BigQuery](./hacks/bq-dwh/README.md)
  > In this hack we'll implement a classic data warehouse using modern tools, such as Cloud Storage, BigQuery, Dataform and Looker Studio. We'll start with a modified version of the well known AdventureWorks OLTP database, and we'll implement a dimensional model to report on business questions using a BI visualization tool.
- [Open Lakehouse with Apache Iceberg](./hacks/bq-olh/README.md)
  > In this hack, we will explore the convergence of data lakes and data warehouses by implementing an open lakehouse architecture using Apache Iceberg. We'll start by organizing raw data in Cloud Storage using the Iceberg table format to enable ACID transactions and schema evolution. From there, we’ll seamlessly query and manage these tables using BigQuery and Spark, ensuring high performance and cost-efficiency. Finally, we’ll combine the results of image analysis with our structured data to identify specific manufacturing defects in product returns, allowing us to correlate visual evidence with product metadata to improve quality control and reduce future return rates.
- [Introduction to Conversational Agents](./hacks/conv-agents-intro/README.md)
  > This hack will be an introduction to the world of Customer Engagement modernization. We will teach you how to build a robust Conversational Agent using Google Cloud’s Customer Engagement Suite.
- [Real-time analytics with Change Data Capture (CDC)](./hacks/realtime-analytics/README.md)
  > We will be going through replicating and processing operational data from an Oracle database into Google Cloud in real time. You'll also figure out how to forecast future demand, and how to visualize this forecast data as it arrives.
- [Hack to the Future: Data Track](./hacks/httf-data/README.md)
  > In this hack we'll help the fictitious Cymbal Shops e-commerce platform to modernize their tech stack, primarily focusing on the migration of the legacy application MySQL database to Cloud Spanner. From that point we'll create BigQuery analytics datasets to handle both historical and live data using federation, use advanced generative AI to enhance the existing dataset with descriptions and images, and finally implement semantic search on this dataset.
- [Disneyland Agentic Data Cloud](./hacks/disneyland-on-gcp/README.md)
  > Build an end-to-end intelligent guest assistance system. You will ingest operational data into AlloyDB and generate vector embeddings natively using AlloyDB AI, configure QueryData for predictable SQL generation, and set up real-time replication to BigQuery using Datastream. In BigQuery, you will train forecasting models using BigQuery ML, build a multimodal RAG pipeline on images and PDF brochures, and map visitor movement patterns using BigQuery's native SQL Graph (GQL) capabilities. After cataloging your assets in Knowledge Catalog, you will use Conversational Analytics to query insights, sync these insights back to AlloyDB via BigQuery FDW, expose operational and analytical tools using the MCP Toolbox, and build and deploy a conversational assistant web app powered by the Agent Development Kit (ADK).

### Infrastructure

- [Security with reCAPTCHA and Cloud Armor](./hacks/recaptcha-cloudarmor-security/README.md)
  > We will be setting up gHacks+, the hottest new streaming site. We will configure an HTTP Load Balancer in front of the site and then you'll learn how to set up a reCAPTCHA session token site key and embed it the site. You will also learn how to set up redirection to reCAPTCHA Enterprise manual challenge. We will then configure a Cloud Armor bot management policy to showcase how bot detection can protect gHacks+ from malicious bot traffic.
- [Infrastructure as Code with Terraform](./hacks/iac-with-tf/README.md)
  > This gHack is intended as an introduction to provisioning GCP resources using Terraform. We'll start with the basics of Infrastructure as Code (IaC) and help you automate the process of infrastructure provisioning.

### Application Development

- [Intro to Google Kubernetes Engine](./hacks/intro-to-gke/README.md)
  > We will experience what a cloud developer needs to go through to successfully deploy an application to Google Kubernetes Engine. You will learn how to containerize a monolithic application; create a cluster; deploy, run and scale the application and then update the application and rollout the new version with zero downtime.
- [Modernizing the Monolith: Containerizing and Deploying to Kubernetes](./hacks/modernizing-monoliths/README.md)
  > Learn Docker and GKE with a web application that you can play! You will compose your own Dockerfile to containerize an existing web application and get practice in creating a cluster, creating node pools, and running deployments and services.
- [Ready, Steady, Cloud Run!](./hacks/cloud-run/README.md)
  > We'll be using Cloud Run to quickly configure, deploy and troubleshoot a web service. During the process we'll introduce different ways to store data for the web service and learn about how to discover and fix issues.
- [Practical SRE](./hacks/practical-sre/README.md)
  > In this gHack, you'll step into the role of SREs and Product Owners for a cutting-edge app. Your mission is to ensure that this app delivers a smooth, reliable, and responsive experience for its users.

### Industry Solutions

- [Gaming on Google Cloud](./hacks/gaming-on-gcp/README.md)
  > Learn how to deploy and manage game servers using Agones. Experience how Open Match integrates with Agones to assign players to game servers and protects servers with players from premature scale down operations.

### SAP

- [Agentic AI and SAP](./hacks/agentic-ai-and-sap/README.md)
  > This hackathon challenges participants to build intelligent applications by unifying SAP and other enterprise data in BigQuery. Participants will then use Google's no-code and advanced agent development tools to create conversational AI and automate complex business processes, such as creating purchase requisitions directly within SAP.

### Stay tuned for more

We've got more hacks in development and feel free to suggest new ones...

## License

This repository is licensed under Apache2 license. More info can be found [here](./LICENSE).
