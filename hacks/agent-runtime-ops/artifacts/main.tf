# Copyright 2026 Google LLC
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

# Enable all required APIs for Agent Runtime, Agent Identity, Agent Gateway, Model Armor, and Online Evaluation
resource "google_project_service" "default" {
  project = var.gcp_project_id
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "modelarmor.googleapis.com",
    "networkservices.googleapis.com",
    "networksecurity.googleapis.com",
    "cloudtrace.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "agentregistry.googleapis.com",
    "agentplatform.googleapis.com",
    "apphub.googleapis.com",
    "apptopology.googleapis.com",
    "cloudapiregistry.googleapis.com",
    "iamconnectors.googleapis.com",
    "iap.googleapis.com",
    "notebooks.googleapis.com",
    "observability.googleapis.com",
    "saasservicemgmt.googleapis.com",
    "securitycenter.googleapis.com",
    "texttospeech.googleapis.com",
    "firestore.googleapis.com",
    "dlp.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
}

# Artifact Registry Repository to host custom BYOC container images
resource "google_artifact_registry_repository" "agent_repo" {
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = "agent-images"
  description   = "Docker repository for Agent Runtime BYOC container images"
  format        = "DOCKER"

  depends_on = [
    google_project_service.default
  ]
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}

# IAM permissions for the Compute Engine default service account used by Cloud Build
resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/logging.logWriter",
    "roles/artifactregistry.writer"
  ])

  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  depends_on = [
    google_project_service.default
  ]
}

# IAM permissions for the AgentRuntime default service agent to retrieve images
resource "google_project_iam_member" "agentruntime_roles" {
  for_each = toset([
    "roles/artifactregistry.reader"
  ])

  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-aiplatform-re.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.default
  ]
}

# Firestore (default) database in Native mode
resource "google_firestore_database" "default" {
  project                 = var.gcp_project_id
  name                    = "(default)"
  location_id             = var.gcp_region
  type                    = "FIRESTORE_NATIVE"
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "DELETE"

  depends_on = [
    google_project_service.default
  ]
}

# Model Armor Service Agent
resource "google_project_service_identity" "model_armor_sa" {
  provider = google-beta
  project  = var.gcp_project_id
  service  = "modelarmor.googleapis.com"

  depends_on = [
    google_project_service.default
  ]
}

# IAM permissions for the Model Armor Service Agent to inspect data using Sensitive Data Protection (Cloud DLP)
resource "google_project_iam_member" "model_armor_dlp_roles" {
  for_each = toset([
    "roles/dlp.user",
    "roles/dlp.reader"
  ])

  project = var.gcp_project_id
  role    = each.key
  member  = google_project_service_identity.model_armor_sa.member

  depends_on = [
    google_project_service_identity.model_armor_sa
  ]
}

# IAM permissions for the Service Extensions / Agent Gateway Data Plane (DEP) service agent to invoke Model Armor callouts
resource "google_project_iam_member" "dep_service_agent_roles" {
  for_each = toset([
    "roles/modelarmor.calloutUser",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/modelarmor.user"
  ])

  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dep.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.default
  ]
}

# Manage the pre-existing _Default log bucket and ensure Log Analytics is enabled
resource "google_logging_project_bucket_config" "default_log_bucket" {
  project          = var.gcp_project_id
  location         = "global"
  bucket_id        = "_Default"
  enable_analytics = true

  depends_on = [
    google_project_service.default
  ]
}
