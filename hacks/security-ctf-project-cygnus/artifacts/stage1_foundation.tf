# stage1_foundation.tf
#
# Sets up the intentionally vulnerable resources for Stage 1.
# v2.3: Adds the final, definitive permission identified in build logs:
#       grants the Default Compute Engine SA the Artifact Registry Writer role.

# --- Data Source to get the Cloud Storage service account ---
data "google_storage_project_service_account" "gcs_account" {
}

# Buckets for data flow
resource "google_storage_bucket" "raw_telemetry" {
  name          = "${var.project_id}-cygnus-raw-telemetry"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  depends_on = [google_project_service.cygnus_apis]
}

resource "google_storage_bucket" "processed_telemetry" {
  name     = "${var.project_id}-cygnus-processed-telemetry"
  location = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  depends_on = [google_project_service.cygnus_apis]
}

resource "google_storage_bucket_iam_member" "public_raw_bucket_access" {
  bucket = google_storage_bucket.raw_telemetry.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# --- Cloud Function and Triggering Resources ---

resource "local_file" "function_source_py" {
  content  = <<-EOT
    import functions_framework

    @functions_framework.cloud_event
    def trigger_dlp_scan(cloud_event):
        print(f"Processing file: {cloud_event.data['name']}")
        print("This function is running as a dedicated service account.")
  EOT
  filename = "${path.module}/function_source/main.py"
}

resource "local_file" "function_source_reqs" {
    content = "functions-framework"
    filename = "${path.module}/function_source/requirements.txt"
}

data "archive_file" "function_source_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function_source"
  output_path = "${path.module}/function_source.zip"
  depends_on  = [local_file.function_source_py, local_file.function_source_reqs]
}

resource "google_storage_bucket" "function_source_bucket" {
  name          = "${var.project_id}-cygnus-func-source"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  depends_on = [google_project_service.cygnus_apis]
}

resource "google_storage_bucket_object" "function_source_upload" {
  name   = "source.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = data.archive_file.function_source_zip.output_path
}

data "google_project" "project" {}

# --- START: Definitive Permissions ---

# 1. Grant Log Writer to the Default Compute SA (for build logging)
resource "google_project_iam_member" "default_compute_can_write_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# 2. Grant Storage Viewer to the Default Compute SA on the Google-managed staging bucket (for source fetching)
resource "google_storage_bucket_iam_member" "default_compute_can_read_staging" {
  bucket = "gcf-v2-sources-${data.google_project.project.number}-${var.region}"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# 3. Grant Artifact Registry Writer to the Default Compute SA (for storing build artifacts)
#    THIS IS THE FINAL FIX IDENTIFIED IN THE LATEST LOGS.
resource "google_project_iam_member" "default_compute_is_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# We still create a dedicated SA for the function's RUNTIME for best practice.
resource "google_service_account" "function_runtime_sa" {
  account_id   = "cygnus-func-runtime-sa"
  display_name = "Cygus CTF Function Runtime SA"
}

# 4. We still need to allow the Cloud Build service to impersonate our new runtime SA.
resource "google_service_account_iam_member" "build_account_can_impersonate_runtime_sa" {
  service_account_id = google_service_account.function_runtime_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}


# --- END: Definitive Permissions ---

resource "google_cloudfunctions2_function" "dlp_trigger_function" {
  name     = "cygnus-dlp-trigger"
  location = var.region
  
  build_config {
    runtime     = "python311"
    entry_point = "trigger_dlp_scan"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source_bucket.name
        object = google_storage_bucket_object.function_source_upload.name
      }
    }
  }

  service_config {
    # Use our new, dedicated service account for the runtime.
    service_account_email = google_service_account.function_runtime_sa.email
    ingress_settings      = "ALLOW_ALL"
  }

  event_trigger {
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.function_trigger_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  depends_on = [
    # Depend on all necessary permissions being in place for all service accounts.
    google_project_iam_member.default_compute_can_write_logs,
    google_storage_bucket_iam_member.default_compute_can_read_staging,
    google_project_iam_member.default_compute_is_artifact_writer,
    google_service_account_iam_member.build_account_can_impersonate_runtime_sa
  ]
}

resource "google_pubsub_topic" "function_trigger_topic" {
    name = "cygnus-dlp-trigger-topic"
}

resource "google_storage_notification" "raw_telemetry_notification" {
  bucket = google_storage_bucket.raw_telemetry.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.function_trigger_topic.id
  depends_on = [
    google_pubsub_topic_iam_member.gcs_pubsub_publisher
  ]
}

resource "google_pubsub_topic_iam_member" "gcs_pubsub_publisher" {
  topic  = google_pubsub_topic.function_trigger_topic.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}
