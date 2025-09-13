# stage5_governance.tf
#
# v1.2: Updated depends_on to reference the new google_project_service resource.

resource "google_storage_bucket" "temporary_public_bucket" {
  name          = "${var.project_id}-cygnus-temporary-public-bucket"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  depends_on = [google_project_service.cygnus_apis]
}

resource "google_storage_bucket_iam_member" "public_temp_bucket_access" {
  bucket = google_storage_bucket.temporary_public_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
