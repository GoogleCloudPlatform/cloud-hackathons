# This resource block defines the single 'tx-darwin' instance running Ubuntu Minimal.
resource "google_compute_instance" "ubuntu_instance" {
  name         = "tx-darwin-01"
  machine_type = "c4-standard-8"
  zone         = var.zone

  allow_stopping_for_update = true

  # Defines the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2404-noble-amd64-v20250606"
      size  = 50
      type  = "hyperdisk-balanced"
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
    gsutil cp gs://ghacks-media-on-gcp-private-temp/tx-deploy.tar.gz /var/node
    tar xvzf tx-deploy.tar.gz
    cd /var/node/
    chmod +x darwin-init.sh
    sudo ./darwin-init.sh
    echo ">>> Startup script for tx-darwin: finished."
  EOT

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
