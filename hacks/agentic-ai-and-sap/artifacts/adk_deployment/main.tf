locals {
    services = [
        "cloudbuild.googleapis.com",
        "storage-component.googleapis.com",
        "artifactregistry.googleapis.com",
        "run.googleapis.com",
        "cloudaicompanion.googleapis.com",
        "aiplatform.googleapis.com",
        "iap.googleapis.com"
    ]
    project_number = data.google_project.project.number
}

data "google_project" "project" {
    project_id = var.gcp_project_id
}


resource "google_project_service" "required_api" {
  for_each = toset( local.services )
  
  project = var.gcp_project_id
  service = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  lifecycle {
    
  }
}

resource "google_project_iam_member" "cloud_build_run_admin" {
  project = var.gcp_project_id
  role    = "roles/run.admin"

  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
  
}

resource "google_project_iam_member" "cloud_build_registry_admin" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.admin"

  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_iam" {
  project = var.gcp_project_id
  role    = "roles/resourcemanager.projectIamAdmin"

  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_iap_admin" {
  project = var.gcp_project_id
  role    = "roles/iap.admin"
  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
}


resource "google_project_iam_member" "iap_run_invoke" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member = "serviceAccount:service-${local.project_number}@gcp-sa-iap.iam.gserviceaccount.com"
}

resource "local_file" "deploy_script" {
    content  = templatefile("${path.module}/template_script.sh", {
      gcp_project_id = var.gcp_project_id
      gcp_region = var.gcp_region
    })
    filename = "./cloudrun/deploy_script.sh"
}


module "gcloud" {
  source = "terraform-google-modules/gcloud/google"
  # version = "~> 3.1.0"

  platform = "linux"
  additional_components = []

  create_cmd_entrypoint = "gcloud"
  create_cmd_body = "builds submit --config ${path.module}/cloudbuild.yaml --project ${var.gcp_project_id} --timeout=7200"

  skip_download = false
  upgrade = false
  module_depends_on = [ local_file.deploy_script ]
  gcloud_sdk_version = "399.0.0"
  service_account_key_file = var.service_account_key_file
}



