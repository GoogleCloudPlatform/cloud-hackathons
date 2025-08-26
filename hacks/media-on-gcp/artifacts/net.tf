# Default VPC
module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 10.0.0"

  project_id              = local.project.id
  network_name            = "vpc-media-on-gcp"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

# Load balancer
module "endpoints" {
  source = "./basics/endpoints"

  project_id = local.project.id
  region     = var.gcp_region

  network = module.vpc.network_self_link

  backend_services = {
    nea = {
      instance_group       = module.ateme.nea_instance_group_manager_instance_group
      port                 = module.ateme.nea_port # 8080
      port_name            = module.ateme.nea_port_name # http
      protocol             = "HTTP"
      healthcheck_protocol = "http"
      enable_cdn           = false
    }
    titan = {
      instance_group       = module.ateme.titan_instance_group_manager_instance_group
      port                 = module.ateme.titan_port # 443
      port_name            = module.ateme.titan_port_name # https
      protocol             = "HTTPS"
      healthcheck_protocol = "ssl"
      enable_cdn           = false
    }
    darwin = {
      instance_group       = module.darwin.darwin_instance_group_manager_instance_group
      port                 = module.darwin.darwin_port # 443
      port_name            = module.darwin.darwin_port_name # https
      protocol             = "HTTPS"
      healthcheck_protocol = "ssl"
      enable_cdn           = false
    }
    "norsk-ai" = {
      instance_group       = module.norsk-ai.instance_group_manager_instance_group
      port                 = module.norsk-ai.port # 443
      port_name            = module.norsk-ai.port_name # https
      protocol             = "HTTPS"
      healthcheck_protocol = "ssl"
      enable_cdn           = false
    }
    "norsk-gw" = {
      instance_group       = module.norsk-gw.instance_group_manager_instance_group
      port                 = module.norsk-gw.port # 443
      port_name            = module.norsk-gw.port_name # https
      protocol             = "HTTPS"
      healthcheck_protocol = "ssl"
      enable_cdn           = false
    }
    "davinci" = {
      instance_group       = module.davinci.instance_group_manager_instance_group
      port                 = module.davinci.port # 443
      port_name            = module.davinci.port_name # https
      protocol             = "HTTPS"
      healthcheck_protocol = "ssl"
      enable_cdn           = false
    }
    "vizrt" = {
      instance_group       = module.vizrt.instance_group_manager_instance_group
      port                 = module.vizrt.port # 443
      port_name            = module.vizrt.port_name # https
      protocol             = "HTTPS"
      healthcheck_protocol = "ssl"
      enable_cdn           = false
    }
  }
}

# General Firewall Rules

# Punch a hole for internal VM to VM traffic
resource "google_compute_firewall" "fwr_allow_internal" {
  name          = "fwr-ingress-allow-internal"
  network       = module.vpc.network_self_link
  source_ranges = ["10.128.0.0/9"]
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
}

# Punch a hole for IAP traffic
resource "google_compute_firewall" "fwr_allow_iap" {
  name          = "fwr-ingress-allow-iap"
  network       = module.vpc.network_self_link
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "fwr_ssh" {
  name    = "fwr-ingress-allow-ssh"
  network = module.vpc.network_self_link

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fwr_http" {
  name    = "fwr-ingress-allow-http"
  network = module.vpc.network_self_link

  allow {
    ports    = ["80", "443"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fwr_rdp" {
  name    = "fwr-ingress-allow-rdp"
  network = module.vpc.network_self_link

  allow {
    ports    = ["3389"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fwr_tcp_8080" {
  name    = "fwr-ingress-allow-tcp-8080"
  network = module.vpc.network_self_link

  allow {
    ports    = ["8080"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}
