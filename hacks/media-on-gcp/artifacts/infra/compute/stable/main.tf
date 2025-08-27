locals {
  network_interfaces = [for i, n in var.networks : {
    network     = n,
    subnetwork  = length(var.sub_networks) > i ? element(var.sub_networks, i) : null
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    }
  ]
}

resource "google_compute_instance_template" "instance_template" {
  name_prefix  = "${var.instance_group_name}-"
  machine_type = var.machine_type
  region       = var.region

  tags = var.tags

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.boot_disk_size
    disk_type    = var.boot_disk_type
  }

  can_ip_forward = var.ip_forward

  shielded_instance_config {
    enable_secure_boot          = true
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

  labels = var.labels

  metadata = var.metadata
  metadata_startup_script = var.startup_script

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

  dynamic "guest_accelerator" {
    for_each = var.accelerator_count > 0 ? [1] : []
    content {
      type  = var.accelerator_type
      count = var.accelerator_count
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = var.accelerator_count > 0 ? "TERMINATE" : "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name   = var.instance_group_name
  region = var.region

  version {
    instance_template = google_compute_instance_template.instance_template.id
  }

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  base_instance_name = var.base_instance_name
  target_size        = var.target_size
}