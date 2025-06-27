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

# TF is depending on the following images that are in media-on-gcp-storage project
# gcloud compute images list --project media-on-gcp-storage |grep custom
#NAME: tx-core-custom-image
#NAME: tx-darwin-custom-image
#NAME: tx-edge-custom-image
#

locals {
  network_interfaces = [for i, n in var.networks : {
    network     = n,
    subnetwork  = length(var.sub_networks) > i ? element(var.sub_networks, i) : null
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    }
  ]
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
      image = "projects/media-on-gcp-storage/global/images/tx-core-custom-image"
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

  # Defines the network interface for the instance.
  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork

      dynamic "access_config" {
        for_each = network_interface.value.external_ip == "NONE" ? [] : [1]
        content {
          nat_ip = network_interface.value.external_ip == "EPHEMERAL" ? null : network_interface.value.external_ip
        }
      }
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
      image = "projects/media-on-gcp-storage/global/images/tx-edge-custom-image"
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

  # Defines the network interface for the instance.
  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork

      dynamic "access_config" {
        for_each = network_interface.value.external_ip == "NONE" ? [] : [1]
        content {
          nat_ip = network_interface.value.external_ip == "EPHEMERAL" ? null : network_interface.value.external_ip
        }
      }
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
      image = "projects/media-on-gcp-storage/global/images/tx-darwin-custom-image"
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

  # Defines the network interface for the instance.
  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork

      dynamic "access_config" {
        for_each = network_interface.value.external_ip == "NONE" ? [] : [1]
        content {
          nat_ip = network_interface.value.external_ip == "EPHEMERAL" ? null : network_interface.value.external_ip
        }
      }
    }
  }

  # Assigns labels for organization and filtering.
  labels = {
    "os_family" = "ubuntu"
    "env"       = "dev"
  }
}
