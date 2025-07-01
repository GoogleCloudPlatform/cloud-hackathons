terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = "europe-west2" # London
}

# Define the Google Compute Instance
resource "google_compute_instance" "davinci_vm" {
  project = var.gcp_project_id
  zone    = "europe-west2-a"
  name    = "davinci-remote-edit-machine-${var.teamname}"
  
  # This tells Terraform to create the instance from your specified machine image
  source_machine_image = "projects/ibc-ghack-playground/global/machineImages/davinci-remote-edit-machine"

  # The instance will be deleted when you run 'terraform destroy'
  allow_stopping_for_update = true

  # Network configuration
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnet_name
  }

  # Service account configuration
  service_account {
    email  = "${var.gcp_project_number}-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"] # Or more specific scopes if needed
  }

  labels = {
    managed-by = "terraform"
    team       = var.teamname
  }
}
