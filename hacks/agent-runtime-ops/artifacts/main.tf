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
  project  = var.gcp_project_id
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
    "monitoring.googleapis.com"
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
