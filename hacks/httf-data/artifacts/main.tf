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

resource "google_project_service" "gemini_for_cloud_api" {
  service            = "cloudaicompanion.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sqladmin_api" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "spanner_api" {
  service            = "spanner.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager_api" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "connectors_api" {
  service            = "connectors.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "integrations_api" {
  service            = "integrations.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "workflows_api" {
  service            = "workflows.googleapis.com"
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

resource "google_compute_firewall" "allow_iap" {
  name          = "allow-iap"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


# This piece of code makes it possible to deal with the default network the same way, regardless of how it has
# been created. Make sure to refer to the default network through this resource when needed.
data "google_compute_network" "default_network" {
  name = "default"
  depends_on = [
    google_compute_network.default_network_created
  ]
}

data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/aiplatform.user",
    "roles/bigquery.connectionUser",
    "roles/bigquery.dataEditor",
    "roles/bigquery.user",
    "roles/cloudsql.admin",
    "roles/spanner.databaseUser",
    "roles/storage.objectAdmin",
    "roles/storage.insightsCollectorService"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_integrations_client" "integrations_setup" {
  location = var.gcp_region
  depends_on = [
    google_project_service.integrations_api
  ]
}

resource "google_sql_database_instance" "mysql_source_db" {
  name                = "legacy-db"
  database_version    = "MYSQL_8_0"
  deletion_protection = false
  settings {
    tier      = "db-custom-2-8192"
    disk_size = "100"
    disk_type = "PD_SSD"
  }
}

resource "random_string" "sql_password" {
  length  = 12
  special = false
}

resource "google_sql_user" "sql_user" {
  instance = google_sql_database_instance.mysql_source_db.name
  name     = "migration-admin"
  password = random_string.sql_password.result
  host     = "%"
}

resource "google_bigquery_reservation" "bq_edition" {
  name          = "cymbal-analytics"
  location      = "us"
  edition       = "ENTERPRISE"
  slot_capacity = 0

  autoscale {
    max_slots = 100
  }
}

resource "google_bigquery_reservation_assignment" "default" {
  assignee    = "projects/${var.gcp_project_id}"
  reservation = google_bigquery_reservation.bq_edition.id
  job_type    = "QUERY"
}

resource "google_workflows_workflow" "prep_semantic_search" {
  name            = "prep-semantic-search"
  service_account = data.google_compute_default_service_account.gce_default.id
  source_contents = file("workflow.yaml")

  deletion_protection = false

  depends_on = [
    google_project_service.workflows_api
  ]
}

resource "google_compute_instance" "startup_vm" {
  name         = "gce-lnx-env-setup"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm        = true
  }

  network_interface {
    network = data.google_compute_network.default_network.self_link
    access_config {}
  }

  service_account {
    email  = data.google_compute_default_service_account.gce_default.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile("${path.module}/setup.tftpl", {
    mysql_db = google_sql_database_instance.mysql_source_db.name
  })

  depends_on = [
    google_project_service.compute_api,
    google_sql_database_instance.mysql_source_db,
    google_compute_network.default_network_created
  ]
}

