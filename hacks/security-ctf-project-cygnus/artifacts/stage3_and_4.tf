# stage3_and_4.tf (FINAL VERSION - STEP 2)
#
# Sets up the intentionally vulnerable resources for Stages 3 & 4.
# The Cloud Run service has been removed, as deploying it is a task
# for the CTF participant.

resource "google_storage_bucket" "models_output" {
  name          = "${var.project_id}-cygnus-models-output"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  depends_on = [google_project_service.cygnus_apis]
}
