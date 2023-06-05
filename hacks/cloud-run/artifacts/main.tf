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
data "google_project" "project" {}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Artifact Registry API
resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

# Cloud Build API
resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

# Cloud Resource Manager API
resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# Cloud Datastore API
resource "google_project_service" "datastore" {
  service            = "datastore.googleapis.com"
  disable_on_destroy = false
}

# Identity and Access Management (IAM) API
resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# Cloud Monitoring API
resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

# Cloud Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

# Google Cloud Memorystore for Redis API
resource "google_project_service" "redis" {
  service = "redis.googleapis.com"
}

# Cloud Run Admin API
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Secret Manager API
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
}

# Service Management API
resource "google_project_service" "servicemanagement" {
  service            = "servicemanagement.googleapis.com"
  disable_on_destroy = false
}

# Service Usage API
resource "google_project_service" "serviceusage" {
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

# Cloud SQL Admin API
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}

# Serverless VPC Access API
resource "google_project_service" "vpcaccess" {
  service = "vpcaccess.googleapis.com"
}

# Cloud Deploy API
resource "google_project_service" "clouddeploy" {
  service = "clouddeploy.googleapis.com"
}

# Permissions for the default service account
data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/datastore.user",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
}

# MemoryStore instance
resource "google_redis_instance" "instance" {  
  connect_mode            = "DIRECT_PEERING"
  memory_size_gb          = 1
  name                    = "redis"  
  read_replicas_mode      = "READ_REPLICAS_DISABLED"
  redis_version           = "REDIS_6_X"
  region                  = var.gcp_region
  tier                    = "BASIC"
  transit_encryption_mode = "DISABLED"
  depends_on = [
    google_project_service.redis
  ]
}

# Cloud SQL instance
resource "google_sql_database_instance" "instance" {
  database_version = "POSTGRES_14"
  name             = "postgres"  
  region           = var.gcp_region

  depends_on = [
    google_project_service.sqladmin
  ]

  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = false
      point_in_time_recovery_enabled = false
    }

    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_HDD"

    ip_configuration {
      ipv4_enabled = true
    }

    pricing_plan = "PER_USE"
    tier         = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = "database"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "app"
  instance = google_sql_database_instance.instance.name
  password     = "my-precious"
}


