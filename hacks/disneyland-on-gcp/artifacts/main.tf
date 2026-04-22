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

resource "google_project_service" "default" {
  project = var.gcp_project_id
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "alloydb.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "datastream.googleapis.com",
    "aiplatform.googleapis.com",
    "dataplex.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
}

# In case a default network is not present in the project, this variable needs to be set
resource "google_compute_network" "default_network_created" {
  name                    = "default"
  auto_create_subnetworks = true
  count                   = var.create_default_network ? 1 : 0
  depends_on = [
    google_project_service.default
  ]
}

# Enabling comms between VMs for auto mode subnets (needed by Dataproc/Dataflow workers)
resource "google_compute_firewall" "fwr_allow_custom" {
  name          = "fwr-ingress-allow-custom"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["10.128.0.0/9"]
  allow {
    protocol = "all"
  }
}

# Enabling Identity-Aware-Proxy for TCP forwarding (for SSH access from Console)
resource "google_compute_firewall" "fwr_allow_iap" {
  name          = "fwr-ingress-allow-iap"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# This piece of code makes it possible to deal with the default network the same way, 
# regardless of how it has been created. Make sure to refer to the default network through
# this resource when needed.
data "google_compute_network" "default_network" {
  name = "default"
  depends_on = [
    google_project_service.default,
    google_compute_network.default_network_created
  ]
}

# Random password for the AlooyDB database user
resource "random_string" "password" {
  length  = 12
  special = false
}

# AlloyDB Cluster
resource "google_alloydb_cluster" "default" {
  cluster_id = "disney-cluster"
  location   = var.gcp_region

  network_config {
    network = data.google_compute_network.default_network.id
  }

  initial_user {
    user     = "postgres"
    password = random_string.password.result
  }

  depends_on = [google_project_service.default]
}

resource "google_alloydb_instance" "default" {
  cluster       = google_alloydb_cluster.default.name
  instance_id   = "disney-instance"
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = 2
  }

  depends_on = [google_alloydb_cluster.default]
}

# Storage Bucket
resource "google_storage_bucket" "disney" {
  name                        = var.gcp_project_id
  location                    = var.gcp_region
  uniform_bucket_level_access = true
}

# BigQuery Dataset
resource "google_bigquery_dataset" "disney" {
  dataset_id                 = "disney"
  friendly_name              = "Disneyland Data"
  description                = "Dataset for Disneyland Data Analytics"
  location                   = var.gcp_region
  delete_contents_on_destroy = true

  depends_on = [google_project_service.default]
}

# BigQuery Cloud Resource Connection
resource "google_bigquery_connection" "vertex_ai_conn" {
  connection_id = "vertex_ai_conn"
  location      = var.gcp_region
  friendly_name = "Connection to Vertex AI"
  cloud_resource {}

  depends_on = [google_project_service.default]
}

# Grant Vertex AI User to BigQuery Connection Service Account
resource "google_project_iam_member" "bq_connection_vertex_ai" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_bigquery_connection.vertex_ai_conn.cloud_resource[0].service_account_id}"

  depends_on = [google_bigquery_connection.vertex_ai_conn]
}
