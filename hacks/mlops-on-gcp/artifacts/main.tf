terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.57.0"
    }
  }
}

locals {
  build_default_sa      = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  monitoring_default_sa = "service-${data.google_project.project.number}@gcp-sa-monitoring-notification.iam.gserviceaccount.com"
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
    "roles/storage.admin",
    "roles/monitoring.notificationChannelViewer"
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

# fake email setup to force monitoring service acccount creation
resource "google_monitoring_notification_channel" "basic" {
  display_name = "Test Notification Channel"
  type         = "email"
  labels = {
    email_address = "noreply@example.com"
  }
  force_delete = false
}

resource "google_project_iam_member" "monitoring_default_iam" {
  project = var.gcp_project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${local.monitoring_default_sa}"
  depends_on = [
    google_project_service.pubsub_api,
    google_monitoring_notification_channel.basic
  ]
}