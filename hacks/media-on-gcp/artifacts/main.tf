# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
locals {
  project = {
    id     = var.gcp_project_id
    name   = data.google_project.project.name
    number = data.google_project.project.number
  }
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}


resource "google_project_service" "os_config_api" {
  service            = "osconfig.googleapis.com"
  disable_on_destroy = false
}

module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 10.0.0"

  project_id              = local.project.id
  network_name            = "vpc-media-on-gcp"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

module "media-tx" {
  source = "./basics/media-tx/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}

module "norsk-gw" {
  source = "./basics/norsk-gw/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}

module "davinciresolve" {
  source = "./basics/davinciresolve/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}

module "vizrt" {
  source = "./basics/vizrt-vectar/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}

module "ateme" {
  source = "./basics/ateme/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}

data "google_storage_project_service_account" "gcs_default" {

}

resource "google_storage_bucket" "bucket" {
  name                        = "${var.gcp_project_id}-testing"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "fw_ssh" {
  name    = "fw-media-on-gcp-ssh"
  network = module.vpc.network_name

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fw_http" {
  name    = "fw-media-on-gcp-http"
  network = module.vpc.network_name

  allow {
    ports    = ["80", "443"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fw_rdp" {
  name    = "fw-media-on-gcp-rdp"
  network = module.vpc.network_name

  allow {
    ports    = ["3389"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fw_nea" {
  name    = "fw-media-on-gcp-nea"
  network = module.vpc.network_name

  allow {
    ports    = ["8080"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}
