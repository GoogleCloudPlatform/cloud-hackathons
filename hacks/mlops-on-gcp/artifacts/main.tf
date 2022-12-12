terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

locals {
  build_default_sa = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

provider "google" {
  project = var.gcp_project_id
}

data "google_project" "project" {}

resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
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

data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_project_iam_member" "gce-default-iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/aiplatform.admin",
    "roles/bigquery.admin",
    "roles/storage.objectAdmin"
  ])
  # service_account_id = data.google_compute_default_service_account.default.name
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
}

resource "google_project_iam_member" "build-default-iam" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.admin"
  member  = "serviceAccount:${local.build_default_sa}"
}

resource "google_service_account_iam_member" "gce-default-account-user-iam" {
  service_account_id = data.google_compute_default_service_account.gce_default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.build_default_sa}"
}

