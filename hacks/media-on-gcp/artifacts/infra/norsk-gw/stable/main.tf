module "compute" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "norsk-gw-mig"
  base_instance_name   = "norsk-gw"
  target_size          = 1
  machine_type         = var.machine_type
  source_image         = var.source_image
  boot_disk_type       = var.boot_disk_type
  boot_disk_size       = var.boot_disk_size
  tags                 = ["${var.goog_cm_deployment_name}-deployment", "media-on-gcp"]

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = var.external_ips

  metadata = {
    norsk-studio-admin-password = random_password.admin.result
    deploy_domain_name          = var.domain_name
    deploy_certbot_email        = var.certbot_email
    google-logging-enable       = "0"
    google-monitoring-enable    = "0"
  }

  named_ports = [{
    name = "https"
    port = 443
  }]
}

resource "google_compute_firewall" "fwr_tcp_3478" {
  count = var.enable_tcp_3478 ? 1 : 0

  name    = "fwr-allow-norsk-tcp-3478"
  network = element(var.networks, 0)

  allow {
    ports    = ["3478"]
    protocol = "tcp"
  }

  source_ranges = compact([for range in split(",", var.tcp_3478_source_ranges) : trimspace(range)])

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}

resource "google_compute_firewall" "fwr_udp_3478" {
  count = var.enable_udp_3478 ? 1 : 0

  name    = "fwr-allow-norsk-udp-3478"
  network = element(var.networks, 0)

  allow {
    ports    = ["3478"]
    protocol = "udp"
  }

  source_ranges = compact([for range in split(",", var.udp_3478_source_ranges) : trimspace(range)])

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}

resource "google_compute_firewall" "fwr_udp_5001" {
  count = var.enable_udp_5001 ? 1 : 0

  name    = "fwr-allow-norsk-udp-5001"
  network = element(var.networks, 0)

  allow {
    ports    = ["5001"]
    protocol = "udp"
  }

  source_ranges = compact([for range in split(",", var.udp_5001_source_ranges) : trimspace(range)])

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}

resource "random_password" "admin" {
  length  = 22
  special = false
}
