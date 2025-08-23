locals {
  network_interfaces = [for i, n in var.networks : {
    network     = n,
    subnetwork  = length(var.sub_networks) > i ? element(var.sub_networks, i) : null
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    }
  ]
}

# This resource block defines the single 'tx-darwin' instance running Ubuntu Minimal.
resource "google_compute_instance" "ubuntu_instance" {
  name         = "vizrt-vectar-01"
  machine_type = "g2-standard-8"
  zone         = var.zone

  allow_stopping_for_update = true

  # Defines the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = "projects/qwiklabs-resources/global/images/vizrt-vectar-machine"
      size  = 50
      type  = "pd-balanced"
    }
  }

  guest_accelerator {
    type  = "nvidia-l4-vws"
    count = 1
  }

  # Enables Shielded VM features to meet security constraints.
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
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
}

resource "google_compute_firewall" "fw_vizrt_vectar" {
  name    = "fw-media-on-gcp-vizrt-vectar"
  network = element(var.networks, 0)

  allow {
    ports    = ["4172", "8444", "22350"]
    protocol = "tcp"
  }

  allow {
    ports    = ["4173", "8443", "22350"]
    protocol = "udp"
  }

  source_ranges = ["0.0.0.0/0"]
}
