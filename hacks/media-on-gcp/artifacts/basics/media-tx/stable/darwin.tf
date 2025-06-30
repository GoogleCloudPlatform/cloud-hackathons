# This resource block defines the single 'tx-darwin' instance running Ubuntu Minimal.
resource "google_compute_instance" "ubuntu_instance" {
  name         = "tx-darwin-01"
  machine_type = "c4-standard-8"
  zone         = "europe-west2-b"

  # Defines the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2404-noble-amd64-v20250606"
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
    tar xvzf tx-deploy.tar.gz  
    cd /var/node/
    chmod +x darwin-init.sh     
    sudo ./darwin-init.sh       
    echo ">>> Startup script for tx-darwin: finished."
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
