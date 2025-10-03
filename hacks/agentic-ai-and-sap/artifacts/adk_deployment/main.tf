
resource "time_sleep" "wait_start" {
  create_duration = "60s"
}

resource "google_compute_instance" "lab_setup_vm" {

  project      = var.gcp_project_id
  name         = "lab-server"
  machine_type = "e2-medium"
  zone         = var.gcp_zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    network = "default"
    access_config { 
      // Ephemeral public IP
    }
  }

  metadata = {
    startup-script = <<SCRIPT
        #!/bin/bash

        export DATE=$(date '+%Y%m%d%H%M%S')
        export YYMM=$(date '+%Y%m')
        echo Recording Lab information into LFS Logs bucket
        export ZONE=${var.gcp_zone}
        export REGION=${var.gcp_region}
        export PROJECT_ID=${var.gcp_project_id}
        export USER_ACCOUNT=$(gcloud config list --format="value(core.account)")
        export PROJECT_ID=$(gcloud info --format='value(config.project)')
        export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

        gcloud services disable cloudbuild.googleapis.com
        gcloud services disable iap.googleapis.com
        sleep 10
        gcloud services enable cloudbuild.googleapis.com
        gcloud services enable iap.googleapis.com

        sleep 300
        gcloud compute instances delete lab-server --zone=$ZONE  --quiet 

      SCRIPT
  }

  service_account {
    scopes = ["cloud-platform"]
  }
 depends_on = [ time_sleep.wait_start]

}

resource "time_sleep" "wait" {
  depends_on = [ google_compute_instance.lab_setup_vm]
  create_duration = "60s"
}


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
  depends_on = [ time_sleep.wait]
}

resource "google_project_service_identity" "iap" {
  provider = google-beta

  project = var.gcp_project_id
  service = "iap.googleapis.com"
}


resource "google_project_iam_member" "cloud_build_run_admin" {
  project = var.gcp_project_id
  role    = "roles/run.admin"

  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
 depends_on = [ time_sleep.wait,google_project_service_identity.iap]
}

resource "google_project_iam_member" "cloud_build_registry_admin" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.admin"

  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
  depends_on = [ time_sleep.wait]
}

resource "google_project_iam_member" "cloud_build_iam" {
  project = var.gcp_project_id
  role    = "roles/resourcemanager.projectIamAdmin"

  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
  depends_on = [ time_sleep.wait]
}

resource "google_project_iam_member" "cloud_build_iap_admin" {
  project = var.gcp_project_id
  role    = "roles/iap.admin"
  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
  depends_on = [ time_sleep.wait]
}


resource "google_project_iam_member" "iap_run_invoke" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member = "serviceAccount:service-${local.project_number}@gcp-sa-iap.iam.gserviceaccount.com"
  depends_on = [ time_sleep.wait]
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



