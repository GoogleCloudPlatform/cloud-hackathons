locals {
  project = {
    id     = var.gcp_project_id
    name   = data.google_project.project.name
    number = data.google_project.project.number
  }
  endpoint_url = "endpoints.${local.project.id}.cloud.goog"
}

data "google_project" "project" {
  provider = google.bootstrap_user_account_googl

  project_id = var.gcp_project_id
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
  member  = "serviceAccount:${var.host_centralized_serviceaccount_name}@${var.host_gcp_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "imageuser_role" {
  project = var.host_gcp_project_id
  role    = "roles/compute.imageUser"
  member  = "serviceAccount:${local.project.number}@cloudservices.gserviceaccount.com"
}
