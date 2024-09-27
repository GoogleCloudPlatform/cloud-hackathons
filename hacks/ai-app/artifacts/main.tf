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
resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Enables required APIs.
resource "google_project_service" "default" {
  provider = google-beta.no_user_project_override
  project  = var.gcp_project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudbuild.googleapis.com",
    "storage.googleapis.com",
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
    "sql-component.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
    "redis.googleapis.com",
    "firebase.googleapis.com",
  "secretmanager.googleapis.com"])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.gcp_region
  repository_id = "movie-guru-repo"
  description   = "docker repository for app movie-guru"
  format        = "DOCKER"
  project       = var.gcp_project_id
  docker_config {
    immutable_tags = false
  }
  depends_on = [google_project_service.default]
}

resource "google_service_account" "default" {
  account_id   = "movie-guru-chat-server-sa"
  display_name = "movie-guru-chat-server-sa"
  depends_on   = [google_project_service.default]

}

resource "google_project_iam_member" "vertex-user" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "sql-user" {
  project = var.gcp_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "redis-user" {
  project = var.gcp_project_id
  role    = "roles/redis.editor"
  member  = "serviceAccount:${google_service_account.default.email}"
}