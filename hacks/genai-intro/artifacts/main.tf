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

resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "resource_manager_api" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "pubsub_api" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
  depends_on = [
    google_project_service.resource_manager_api
  ]
}

resource "google_project_service" "build_api" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifacts_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "functions_api" {
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging_api" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "vision_api" {
  service            = "vision.googleapis.com"
  disable_on_destroy = false

  depends_on = [ google_project_service.resource_manager_api ]
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

data "google_project" "project" {
  depends_on = [
    google_project_service.resource_manager_api
  ]
}

data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.compute_api
  ]
}

data "google_storage_project_service_account" "gcs_default" {

}

resource "google_project_service_identity" "functions_default_sa" {
  provider = google-beta

  project = data.google_project.project.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_iam_member" "functions_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/cloudfunctions.serviceAgent"
  ])
  role   = each.key
  member = "serviceAccount:${google_project_service_identity.functions_default_sa.email}"
  depends_on = [
    google_project_service.functions_api,
    google_project_service.iam_api
  ]
}

resource "time_sleep" "wait_until_functions_sa_ready" {
  create_duration = "90s"
  depends_on = [
    google_project_iam_member.functions_default_iam
  ]
}

resource "google_pubsub_topic" "pubsub_topic" {
  name = "documents"

  depends_on = [
    google_project_service.pubsub_api
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/aiplatform.user",
    "roles/artifactregistry.writer",
    "roles/bigquery.dataEditor",
    "roles/bigquery.user",
    "roles/logging.logWriter",
    "roles/storage.objectAdmin",
    "roles/storage.insightsCollectorService"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
  depends_on = [
    google_project_service.iam_api
  ]
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "function"
  output_path = "function.zip"
}

resource "google_storage_bucket" "bucket" {
  name                        = "${var.gcp_project_id}-functions"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "src-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.bucket.name
}

resource "google_cloudfunctions_function" "function" {
  name    = "process-document"
  runtime = "python311"

  entry_point           = "on_document_added"
  available_memory_mb   = "512"
  timeout               = "300"
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
  max_instances         = 4

  service_account_email = data.google_compute_default_service_account.gce_default.email

  environment_variables = {
    GCP_REGION     = var.gcp_region
    GCP_PROJECT_ID = var.gcp_project_id
  }

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.pubsub_topic.id
  }

  depends_on = [
    time_sleep.wait_until_functions_sa_ready
  ]
}
