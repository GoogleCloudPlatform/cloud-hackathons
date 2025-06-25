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

module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 10.0.0"

  project_id              = local.project.id
  network_name            = "vpc-media-on-gcp"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

module "media-tx" {
  source = "./modules/media-tx"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}

module "norsk-gw" {
  source = "./modules/norsk-gw"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]
}
