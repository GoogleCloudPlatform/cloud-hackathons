# Configures the Google Cloud provider with your project ID and the desired region.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
