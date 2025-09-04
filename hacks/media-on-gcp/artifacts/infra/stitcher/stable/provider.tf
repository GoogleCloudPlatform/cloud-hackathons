# --- Terraform and Provider Configuration ---

# Specifies the required Terraform version and the Google Cloud provider.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

# Configures the Google Cloud provider with your project ID and the desired region.
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
