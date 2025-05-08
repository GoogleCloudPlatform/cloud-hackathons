# GenAI Monitoring Infrastructure - Terraform Configuration for Movie Guru

This directory contains the Terraform configuration files used to provision and manage the infrastructure for a GenAI monitoring project centered around a "Movie Guru" application within a Google Cloud Platform (GCP) environment. This project focuses on leveraging Genkit and GCP services to monitor and optimize the performance, stability, and user engagement of the application.

## Purpose

The primary goals of this Terraform code are to:

* Enable necessary GCP services for a GenAI application, including those essential for LLM interactions, data storage, and application deployment.
* Create a service account with appropriate permissions for the application's backend server and services.
* Set up Firebase to store the firebase configuration.
* Set up the Monitoring infrastructure using Genkit.
* Define project-level variables and outputs for easy management.
* Use specific `google-beta` provider version for a specific provider configuration.

## File Structure and Description

* **`main.tf`**:
    * This is the core configuration file.
    * It enables essential GCP services, including Compute Engine, Firebase, Cloud Build, Cloud Storage, Vertex AI, Artifact Registry, Cloud SQL, Cloud Run, and more. These services are fundamental for running and monitoring a GenAI application.
    * It creates a service account (`movie-guru-chat-server-sa`) and grants it various IAM roles:
        * `roles/aiplatform.user` (Vertex AI user - for interacting with LLMs)
        * `roles/monitoring.metricWriter` (Monitoring metric writer - for Genkit and GCP monitoring)
        * `roles/cloudtrace.agent` (Cloud Trace agent - for request tracing)
        * `roles/logging.logWriter` (Logging writer - for application logs)
* **`variables.tf`**:
    * Defines the variables required for the Terraform deployment.
    * `gcp_project_id`: The ID of your GCP project.
    * `gcp_loation`: The location of your GCP resources.
    * `gcp_region`: The default GCP region (defaults to `us-central1`).
    * `gcp_zone`: The default GCP zone (defaults to `us-central1-c`).
* **`outputs.tf`**:
    * Defines the outputs of the Terraform deployment.
    * `project_id`: Exports the GCP project ID.
    * `service_account_email`: Exports the email of the created service account.
* **`providers.tf`**:
    * Configures the Terraform providers for Google Cloud.
    * Specifies the `google` and `google-beta` providers and their versions.
    * Sets `user_project_override` to true for general use and creates an alias provider `no_user_project_override` with `user_project_override` to `false` for services creation.
* **`firebase.tf`**:
    * Configures Firebase for the project.
    * Creates a Firebase project.
    * Creates a Firebase Web application
    * Creates a bucket and stores the `firebase-config.json` file.

## Key Resources

* **Google Project Services:** Various GCP APIs are enabled to support the GenAI application's features and monitoring needs. These include services for:
    * LLM interactions (Vertex AI)
    * Data storage (Cloud SQL, Cloud Storage)
    * Application deployment (Cloud Run)
    * Monitoring and observability (Cloud Logging, Cloud Trace)
* **Google Service Account:** A dedicated service account (`movie-guru-chat-server-sa`) is created, providing fine-grained access control for the application to interact with GCP resources.
* **Firebase Project:** A Firebase project is created to store the firebase configuration.
* **Firebase Web App:** A Firebase Web application is created.
* **Genkit Monitoring Foundation:** The enabled services and the roles granted to the service account support the use of Genkit for monitoring.

## How to Use

1. **Prerequisites:**
    * Terraform installed.
    * A Google Cloud project set up.
    * The gcloud CLI installed and authenticated.
    * Genkit CLI installed.

2. **Configuration:**
    * Copy `terraform.tfvars.example` to `terraform.tfvars` and provide configuration or pass variables in as command-line arguments.

3. **Deployment:**
    * Run `terraform init` to initialize the Terraform working directory.
    * Run `terraform plan` to preview the changes.
    * Run `terraform apply` to create the resources.
