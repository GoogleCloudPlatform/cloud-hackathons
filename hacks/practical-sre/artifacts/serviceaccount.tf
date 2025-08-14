
resource "google_service_account" "service_account" {
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run OTel Sample Service Account"
  project      = var.gcp_project_id
}

resource "google_storage_bucket_iam_member" "bucket_reader_otel" {
  bucket = google_storage_bucket.otel.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_storage_bucket_iam_member" "bucket_reader_locust" {
  bucket = google_storage_bucket.locust.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "monitoring-metric-writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "trace-agent" {
  project = var.gcp_project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "log-writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
