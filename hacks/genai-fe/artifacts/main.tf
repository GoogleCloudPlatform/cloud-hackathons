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

resource "google_project_service" "serviceusage_api" {
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "resource_manager_api" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging_api" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "vertex_api" {
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery_api" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery_conn_api" {
  service            = "bigqueryconnection.googleapis.com"
  disable_on_destroy = false
}

# In case a default network is not present in the project the variable `create_default_network` needs to be set.
resource "google_compute_network" "default_network_created" {
  name                    = "default"
  auto_create_subnetworks = true
  count                   = var.create_default_network ? 1 : 0
  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_firewall" "default_allow_custom_created" {
  name          = "default-allow-custom"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["10.128.0.0/9"]
  allow {
    protocol = "all"
  }
}

# This piece of code makes it possible to deal with the default network the same way, regardless of how it has
# been created. Make sure to refer to the default network through this resource when needed.
data "google_compute_network" "default_network" {
  name       = "default"
  depends_on = [
    google_compute_network.default_network_created
  ]
}