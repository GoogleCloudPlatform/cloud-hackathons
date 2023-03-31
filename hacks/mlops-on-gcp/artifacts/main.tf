terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.57.0"
    }
  }
}

locals {
  build_default_sa = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

data "google_project" "project" {}

resource "google_project_service" "compute_api" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "notebooks_api" {
  service = "notebooks.googleapis.com"
}

resource "google_project_service" "vertex_api" {
  service = "aiplatform.googleapis.com"
}

resource "google_project_service" "build_api" {
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "source_repository_api" {
  service = "sourcerepo.googleapis.com"
}

resource "google_project_service" "scheduler_api" {
  service = "cloudscheduler.googleapis.com"
}

resource "google_project_service" "functions_api" {
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "cloudrun_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "firestore_api" {
  service = "firestore.googleapis.com"
}

resource "google_project_service" "registry_api" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "pubsub_api" {
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}


data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/aiplatform.admin",
    "roles/bigquery.admin",
    "roles/storage.objectAdmin",
    "roles/run.invoker",
    "roles/datastore.user"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
}

resource "google_project_iam_member" "build_default_iam" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.admin"
  member  = "serviceAccount:${local.build_default_sa}"
  depends_on = [
    google_project_service.build_api
  ]
}

resource "google_service_account_iam_member" "gce_default_account_user_iam" {
  service_account_id = data.google_compute_default_service_account.gce_default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.build_default_sa}"
}

# --- 

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_project_service.functions_api]
  create_duration = "60s"
}

resource "google_pubsub_topic" "pubsub_topic" {
  name = "batch-monitoring"

  depends_on = [
    google_project_service.pubsub_api
  ]
}

resource "google_firestore_database" "database" {
  name                        = "(default)"

  project                     = var.gcp_project_id
  location_id                 = "nam5"  # or eur3 for europe
  type                        = "DATASTORE_MODE"

  depends_on = [
    google_project_service.firestore_api
  ]
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "python"
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
  name     = "scan-batch-monitoring"
  location = var.gcp_region

  build_config {
    runtime     = "python310"
    entry_point = "scan_batch_predictions"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    ingress_settings   = "ALLOW_ALL"
    available_memory   = "256M"
    timeout_seconds    = "300"
    environment_variables = {
      GCP_REGION      = var.gcp_region
      GCP_PROJECT_ID  = var.gcp_project_id
      PUBSUB_TOPIC_ID = google_pubsub_topic.pubsub_topic.name
    }
  }

  depends_on = [
    time_sleep.wait_60_seconds,  # wait for IAM permissions to propagate for service agent
    google_project_service.functions_api,
    google_project_service.cloudrun_api,
    google_project_service.registry_api,
    google_firestore_database.database
  ]
}

resource "google_cloud_scheduler_job" "batch_monitoring_poll" {
  name      = "poll-batch-monitoring-scan"
  schedule  = "*/15 * * * *"
  time_zone = "Europe/Amsterdam"

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions2_function.function.service_config[0].uri
    oidc_token {
      service_account_email = data.google_compute_default_service_account.gce_default.email
    }
  }

  depends_on = [
    google_project_service.scheduler_api
  ]
}

