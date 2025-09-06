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
  endpoint_url = "endpoints.${local.project.id}.cloud.goog"
}

data "google_project" "project" {
  provider = google.bootstrap_user_account_googl

  project_id = var.gcp_project_id
}

resource "google_project_service" "compute_api" {
  provider = google.bootstrap_user_account_googl

  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "vertexai_api" {
  provider = google.bootstrap_user_account_googl

  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run_api" {
  provider = google.bootstrap_user_account_googl

  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "centralized_project_binding" {
  provider = google.bootstrap_user_account_googl

  project = local.project.id
  role    = "roles/owner"
  member  = "serviceAccount:${var.host_centralized_serviceaccount_name}@${var.host_gcp_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "imageuser_role" {
  project = var.host_gcp_project_id
  role    = "roles/compute.imageUser"
  member  = "serviceAccount:${local.project.number}@cloudservices.gserviceaccount.com"
}

module "ateme" {
  source = "./infra/ateme/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "darwin" {
  source = "./infra/darwin/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "norsk_gw" {
  source = "./infra/norsk-gw/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone
  # domain_name = "norsk.${local.endpoint_url}"

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "norsk_ai" {
  source = "./infra/norsk-ai/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone
  # domain_name = "gemini.${local.endpoint_url}"

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "davinci" {
  source = "./infra/davinci/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "vizrt" {
  source = "./infra/vizrt-vectar/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

# TODO: Need stitcher image deployed and available

# module "stitcher" {
#   source = "./infra/stitcher/stable"

#   project_id = local.project.id
#   region     = var.gcp_region
#   zone       = var.gcp_zone

#   networks = [module.vpc.network_name]

#   depends_on = [ google_project_iam_member.centralized_project_binding ]
# }
