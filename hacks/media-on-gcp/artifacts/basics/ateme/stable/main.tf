locals {
  network_interfaces = [for i, n in var.networks : {
    network     = n,
    subnetwork  = length(var.sub_networks) > i ? element(var.sub_networks, i) : null
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    }
  ]
}

resource "google_compute_instance" "default" {
  name         = "ateme-nl"
  machine_type = "c4d-standard-8"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/qwiklabs-resources/global/images/ateme-nl-250625"
    }
  }

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

resource "google_compute_instance" "default" {
  name         = "ateme-tl01"
  machine_type = "c4d-standard-8"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/qwiklabs-resources/global/images/ateme-tl-250525"
    }
  }

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
