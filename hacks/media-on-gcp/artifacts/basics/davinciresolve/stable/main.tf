# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

locals {
  network_interfaces = [for i, n in var.networks : {
    network     = n,
    subnetwork  = length(var.sub_networks) > i ? element(var.sub_networks, i) : null
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    }
  ]
}

resource "google_compute_instance" "davinci-remote-edit-machine-01" {
  name          = "davinci-remote-edit-machine-01"
  machine_type  = "g2-standard-8"
  zone          = var.zone

  allow_stopping_for_update = true

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "projects/media-on-gcp-storage/global/images/davinci-remote-edit-machine"
      size  = 600
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  guest_accelerator {
    type  = "nvidia-l4-vws"
    count = 1
  }

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
  }

  metadata = {
    enable-osconfig = "TRUE"
    enable-oslogin  = "true"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  # Defines the network interface for the instance.
  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork
      queue_count = 0
      stack_type  = "IPV4_ONLY"

      dynamic "access_config" {
        for_each = network_interface.value.external_ip == "NONE" ? [] : [1]

        content {
          nat_ip = network_interface.value.external_ip == "EPHEMERAL" ? null : network_interface.value.external_ip
          network_tier = "PREMIUM"
        }
      }
    }
  }
}
