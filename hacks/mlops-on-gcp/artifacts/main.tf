terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.63.1"
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

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "notebooks_api" {
  service            = "notebooks.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "vertex_api" {
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "build_api" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "source_repository_api" {
  service            = "sourcerepo.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "scheduler_api" {
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "pubsub_api" {
  service            = "pubsub.googleapis.com"
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

# This piece of code makes it possible to deal with the default network the same way, regardless of how it has
# been created. Make sure to refer to the default network through this resource when needed.
data "google_compute_network" "default_network" {
  name       = "default"
  depends_on = [
    google_compute_network.default_network_created
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/aiplatform.admin",
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/monitoring.notificationChannelViewer",
    "roles/source.reader",
    "roles/logging.logWriter"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_iam_member" "build_default_iam" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.admin"
  member  = "serviceAccount:${local.build_default_sa}"
  depends_on = [
    google_project_service.build_api,
    google_project_service.iam_api
  ]
}

resource "google_service_account_iam_member" "gce_default_account_user_iam" {
  service_account_id = data.google_compute_default_service_account.gce_default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.build_default_sa}"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_service_identity" "monitoring_default_sa" {
  provider = google-beta

  project = data.google_project.project.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_iam_member" "monitoring_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/pubsub.publisher",
    "roles/monitoring.notificationServiceAgent"
  ])
  role   = each.key
  member = "serviceAccount:${google_project_service_identity.monitoring_default_sa.email}"
  depends_on = [
    google_project_service.pubsub_api,
    google_project_service.iam_api
  ]
}
