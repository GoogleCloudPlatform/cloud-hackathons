# Terraform Configuration to provision three Google Cloud Compute Instances.
#
# This file defines the following resources:
# 1. tx-core: A c2-standard-8 instance running Rocky Linux 9.
# 2. tx-edge: A c2-standard-8 instance running Rocky Linux 9.
# 3. tx-darwin: A c2-standard-8 instance running Ubuntu 24.04 Minimal.
#
# All instances are defined as separate resources to allow for individual configuration,
# will be created in the 'europe-west2-b' zone, and will have
# Shielded VM features (including Secure Boot) enabled to comply with organization policy.
# Each instance is configured with a specific service account, API scopes, and a startup script.

# TF is depending on the following images that are in ghack-student project
# gcloud compute images list --project ghack-student |grep custom
#NAME: tx-core-custom-image
#NAME: tx-darwin-custom-image
#NAME: tx-edge-custom-image
#
# --- Terraform and Provider Configuration ---

# Specifies the required Terraform version and the Google Cloud provider.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Configures the Google Cloud provider with your project ID and the desired region.
provider "google" {
  project = "ghack-student"
  region  = "europe-west2"
}


# --- Instance Resources ---

# This resource block defines the 'tx-core' instance.
resource "google_compute_instance" "tx_core" {
  name         = "tx-core"
  machine_type = "c2-standard-8"
  zone         = "europe-west2-b"

  # Defines the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = "projects/ghack-student/global/images/tx-core-custom-image"
      size  = 50
      type  = "pd-balanced"
    }
  }

  # Enables Shielded VM features to meet security constraints.
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Defines the service account and its API access scopes for the instance.
  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  # This script runs the first time the instance boots.
  # You can modify this script independently for tx-core.
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e # Exit immediately if a command exits with a non-zero status.

    echo ">>> Starting startup script for tx-core..."

    # Data Sync
    mkdir -p /var/node
    cd /var/node
    gsutil cp gs://techex/tx-deploy.tar.gz /var/node
#    tar xvzf tx-deploy.tar.gz
#    cd /var/node/core
#    chmod +x install-5.38.1.sh
#    sudo ./install-5.38.1.sh

    echo ">>> Startup script for tx-core finished."
  EOT
  # Defines the network interface for the instance.
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP is assigned here
    }
  }

  # Assigns labels for organization and filtering.
  labels = {
    "os_family" = "rocky-linux"
    "env"       = "dev"
  }
}

# This resource block defines the 'tx-edge' instance.
resource "google_compute_instance" "tx_edge" {
  name         = "tx-edge"
  machine_type = "c2-standard-8"
  zone         = "europe-west2-b"

  # Defines the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = "projects/ghack-student/global/images/tx-edge-custom-image"
      size  = 50
      type  = "pd-balanced"
    }
  }

  # Enables Shielded VM features to meet security constraints.
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Defines the service account and its API access scopes for the instance.
  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  # This script runs the first time the instance boots.
  # You can modify this script independently for tx-edge.
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e # Exit immediately if a command exits with a non-zero status.

    echo ">>> Starting startup script for tx-edge..."

    # Data Sync
    mkdir -p /var/node
    cd /var/node
    gsutil cp gs://techex/tx-deploy.tar.gz /var/node
#    tar xvzf tx-deploy.tar.gz
#    cd /var/node/edge
#    chmod +x install-centos-1.43.0.sh
#    sudo ./install-centos-1.43.0.sh
    echo ">>> Startup script for tx-edge finished."
  EOT
  # Defines the network interface for the instance.
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP is assigned here
    }
  }

  # Assigns labels for organization and filtering.
  labels = {
    "os_family" = "rocky-linux"
    "env"       = "dev"
  }
}

# This resource block defines the 'tx-darwin' instance running from a custom image.
resource "google_compute_instance" "tx_darwin" {
  name         = "tx-darwin"
  machine_type = "c2-standard-8"
  zone         = "europe-west2-b"

  # Defines the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = "projects/ghack-student/global/images/tx-darwin-custom-image"
      size  = 50
      type  = "pd-balanced"
    }
  }

  # Enables Shielded VM features to meet security constraints.
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Defines the service account and its API access scopes for the instance.
  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  # This script runs the first time the instance boots.
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e # Exit immediately if a command exits with a non-zero status.

    echo ">>> Starting startup script for tx-darwin..."

    # Data Sync
    mkdir -p /var/node
    cd /var/node
    gsutil cp gs://techex/tx-deploy.tar.gz /var/node
#    tar xvzf tx-deploy.tar.gz
#    cd /var/node/
#    chmod +x darwin-init.sh
#    sudo ./darwin-init.sh
#    echo ">>> Startup script for tx-darwin: finished."
  EOT
  # Defines the network interface for the instance.
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP is assigned here
    }
  }

  # Assigns labels for organization and filtering.
  labels = {
    "os_family" = "ubuntu"
    "env"       = "dev"
  }
}
