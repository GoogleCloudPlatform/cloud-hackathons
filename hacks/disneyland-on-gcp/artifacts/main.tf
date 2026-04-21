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
  project  = var.gcp_project_id
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

data "google_compute_network" "default" {
  name    = "default"
  project = var.gcp_project_id
  depends_on = [google_project_service.default]
}

# AlloyDB Cluster
resource "google_alloydb_cluster" "default" {
  cluster_id = "disney-cluster"
  location   = var.gcp_region
  network    = data.google_compute_network.default.id

  initial_user {
    user     = "postgres"
    password = "buildwithgemini2025"
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

# BigQuery Dataset
resource "google_bigquery_dataset" "disney" {
  dataset_id                  = "disney"
  friendly_name               = "Disneyland Data"
  description                 = "Dataset for Disneyland Data Analytics"
  location                    = var.gcp_region
  delete_contents_on_destroy  = true

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
