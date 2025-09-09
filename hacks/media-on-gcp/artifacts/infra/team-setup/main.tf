terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

resource "google_storage_bucket" "ad_creative" {
  provider = google.bootstrap_user_account_googl

  name          = "${var.gcp_project_id}-ad_creative"
  location      = var.location
  project       = var.gcp_project_id
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "hp_client" {
  provider = google.bootstrap_user_account_googl

  name          = "${var.gcp_project_id}-hp_client"
  location      = var.location
  project       = var.gcp_project_id
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "null_resource" "populate_hp_client" {
  count = var.populate_hp_client_bucket ? 1 : 0

  provisioner "local-exec" {
    command = "gcloud storage cp -r ${var.hp_client_artifacts_source_uri}/* gs://${google_storage_bucket.hp_client.name}/ --impersonate-service-account=${var.host_centralized_serviceaccount_name}"
  }

  depends_on = [google_storage_bucket.hp_client]
}

resource "google_storage_bucket_object" "team_folder" {
  provider = google

  bucket  = "ibc2025-ad-creative"
  name    = "team-${lower(jsondecode(data.http.api_call.response_body).name)}/"
  content = " "
}

data "http" "api_call" {
  url = var.api_endpoint
}
