terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

locals {
  suffix      = "retail"
  network_tag = "orcl-db"
}

resource "google_project_service" "compute_api" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "datastream_api" {
  service = "datastream.googleapis.com"
}

resource "google_project_service" "dataflow_api" {
  service = "dataflow.googleapis.com"
}

resource "google_project_service" "pubsub_api" {
  service = "pubsub.googleapis.com"
}

resource "google_compute_network" "vpc_sample" {
  name                    = "vpc-${local.suffix}"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "sub-${local.suffix}"
  network                  = google_compute_network.vpc_sample.self_link
  ip_cidr_range            = "10.0.0.0/24"
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_internal" {
  name          = "fwr-ingress-allow-internal"
  network       = google_compute_network.vpc_sample.self_link
  source_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
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

resource "google_compute_firewall" "allow_iap" {
  name          = "fwr-ingress-allow-iap"
  network       = google_compute_network.vpc_sample.self_link
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_oracle" {
  name          = "fwr-ingress-allow-oracle"
  network       = google_compute_network.vpc_sample.self_link
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.network_tag]
  allow {
    protocol = "tcp"
    ports    = ["1521"]
  }
}

resource "google_compute_address" "oracle_vm_eip" {
  name = "eip-orcl-vm"

  depends_on = [
    google_compute_network.vpc_sample
  ]
}

data "template_file" "startup_script" {
  template = file("${path.module}/setup.sh")
}

resource "google_compute_instance" "oracle_vm" {
  name         = "gce-lnx-orcl-001"
  machine_type = "e2-standard-4"
  tags         = [local.network_tag]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm        = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
      nat_ip = google_compute_address.oracle_vm_eip.address
    }
  }

  metadata_startup_script = data.template_file.startup_script.rendered
}