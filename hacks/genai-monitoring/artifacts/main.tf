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
    "storage.googleapis.com",
    "aiplatform.googleapis.com",
    "storage-api.googleapis.com",
    "iam.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
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

resource "google_project_iam_member" "monitoring-writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "trace-agent" {
  project = var.gcp_project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "log-writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_storage_bucket" "static" {
 name          = "${var.gcp_project_id}_posters"
 location      = var.gcp_location
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

// TODO: Set up a Storage Bucket and copy across with the posters zip file
// Solve where the hosting of the zip file should be.... maybe Github, Hosting, Kaggle, something...

# Upload a photos file as an object
# to the storage bucket

# resource "google_storage_bucket_object" "default" {
#  name         = "OBJECT_NAME"
#  source       = "OBJECT_PATH"
#  content_type = "text/plain"
#  bucket       = google_storage_bucket.static.id
# }


