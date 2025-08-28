# main.tf
#
# This is the main configuration file for setting up the Project Cygnus CTF environment.
# v2.2: Removed the three problematic organization-level APIs from the list.
# v2.3: Added sourcerepo.googleapis.com to the list of enabled APIs.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  # List of all APIs required for the project.
  # The three org-level APIs have been removed and must be enabled manually.
  cygnus_apis = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "dlp.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "binaryauthorization.googleapis.com",
    "containeranalysis.googleapis.com",
    "ondemandscanning.googleapis.com",
    "cloudkms.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "apigateway.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "eventarc.googleapis.com",
    "run.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "aiplatform.googleapis.com",
    "sourcerepo.googleapis.com", # Added to support Cloud Source Repositories
  ])
}

# This resource enables all necessary project services idempotently using the
# Terraform provider's credentials.
resource "google_project_service" "cygnus_apis" {
  for_each = local.cygnus_apis

  project = var.project_id
  service = each.key

  # Keep APIs enabled even after the CTF infrastructure is destroyed.
  disable_on_destroy = false
}
