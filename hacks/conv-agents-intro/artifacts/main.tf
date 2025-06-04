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
  # Services needed
  service_apis_list = [
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "logging.googleapis.com",
    "dialogflow.googleapis.com",
    "speech.googleapis.com",
    "storage-component.googleapis.com",
    "datalabeling.googleapis.com",
  ]
}

resource "google_project_service" "all" {
  project  = var.gcp_project_id
  for_each = toset(local.service_apis_list)
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

data "google_project" "project" {
  depends_on = [
    google_project_service.all
  ]
}

data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.all
  ]
}

data "google_storage_project_service_account" "gcs_default" {
}

resource "google_project_service_identity" "functions_default_sa" {
  provider = google-beta

  project = data.google_project.project.project_id
  service = "cloudfunctions.googleapis.com"

  depends_on = [
    google_project_service.all
  ]
}

resource "google_project_iam_member" "functions_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/cloudfunctions.serviceAgent"
  ])
  role   = each.key
  member = "serviceAccount:${google_project_service_identity.functions_default_sa.email}"
  depends_on = [
    google_project_service.all
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/logging.logWriter",
    "roles/artifactregistry.writer",
    "roles/storage.objectAdmin"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
  depends_on = [
    google_project_service.all
  ]
}

resource "time_sleep" "wait_until_functions_sa_ready" {
  create_duration = "90s"
  depends_on = [
    google_project_iam_member.functions_default_iam
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

resource "google_cloudfunctions2_function" "function" {
  name     = "vacation-days"
  location = var.gcp_region

  build_config {
    runtime     = "python312"
    entry_point = "on_request"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  service_config {
    available_memory   = "512M"
    timeout_seconds    = "300"
    ingress_settings   = "ALLOW_INTERNAL_AND_GCLB"
    max_instance_count = 4
    environment_variables = {
      GCP_REGION     = var.gcp_region
      GCP_PROJECT_ID = var.gcp_project_id
    }
    service_account_email = data.google_compute_default_service_account.gce_default.email
  }

  # event_trigger {
  #   event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
  #   pubsub_topic = google_pubsub_topic.pubsub_topic.id
  # }

  depends_on = [
    time_sleep.wait_until_functions_sa_ready
  ]
}
