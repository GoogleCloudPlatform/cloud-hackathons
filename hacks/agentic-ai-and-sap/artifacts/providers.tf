terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.22.0"
    }
  }
}

provider "google" {
    project = var.gcp_project_id
    region  = var.gcp_region
    zone = var.gcp_zone
}