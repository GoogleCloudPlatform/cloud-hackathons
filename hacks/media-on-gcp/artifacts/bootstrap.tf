locals {
  project = {
    id     = var.gcp_project_id
    name   = data.google_project.project.name
    number = data.google_project.project.number
  }

  host_project = {
    id     = var.host_gcp_project_id
    name   = data.google_project.host_project.name
    number = data.google_project.host_project.number
  }

  endpoint_url = "endpoints.${local.project.id}.cloud.goog"
}

data "google_project" "project" {
  provider = google.bootstrap_user_account_googl

  project_id = var.gcp_project_id
}

data "google_project" "host_project" {
  project_id = var.host_gcp_project_id
}

resource "google_project_service" "compute_api" {
  provider = google.bootstrap_user_account_googl

  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "vertexai_api" {
  provider = google.bootstrap_user_account_googl

  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run_api" {
  provider = google.bootstrap_user_account_googl

  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "centralized_project_binding" {
  provider = google.bootstrap_user_account_googl

  project = local.project.id
  role    = "roles/owner"
  member  = "serviceAccount:${var.host_centralized_serviceaccount_name}@${local.host_project.id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "imageuser_role" {
  project = local.host_project.id
  role    = "roles/compute.imageUser"
  member  = "serviceAccount:${local.project.number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_owner_role" {
  project = local.host_project.id
  role    = "roles/owner"
  member  = "serviceAccount:${local.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_serviceaccountuser_role" {
  project = local.host_project.id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${local.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_serviceaccounttokencreator_role" {
  project = local.host_project.id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${local.project.number}-compute@developer.gserviceaccount.com"
}
