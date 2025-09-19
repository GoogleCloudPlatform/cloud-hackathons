# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
resource "google_project_service" "default" {
  project = var.gcp_project_id
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "logging.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
}

locals {
  yesterday = formatdate("YYYY-MM-DD", timeadd(timestamp(), "-24h"))
  test_vms = [
    {
      name   = "gce-sbx-lnx-blob-01",
      labels = {
        "janitor-scheduled" = local.yesterday
      }
    },
    {
      name   = "gce-dev-lnx-tomcat-01",
      labels = {}
    },
    {
      name   = "gce-dev-lnx-tomcat-02",
      labels = {}
    }
  ]
}

data "google_compute_default_service_account" "gce_default" {
  depends_on = [
    google_project_service.default
  ]
}

resource "google_project_iam_member" "gce_default_iam" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/aiplatform.user",
    "roles/compute.instanceAdmin.v1",
    "roles/run.invoker"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_compute_default_service_account.gce_default.email}"
}

# In case a default network is not present in the project the variable `create_default_network` needs to be set.
resource "google_compute_network" "default_network_created" {
  name                    = "default"
  auto_create_subnetworks = true
  count                   = var.create_default_network ? 1 : 0
  depends_on = [
    google_project_service.default
  ]
}

resource "google_compute_firewall" "fwr_allow_custom" {
  name          = "fwr-ingress-allow-custom"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["10.128.0.0/9"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "fwr_allow_iap" {
  name          = "fwr-ingress-allow-iap"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# This piece of code makes it possible to deal with the default network the same way, 
# regardless of how it has been created. Make sure to refer to the default network through
# this resource when needed.
data "google_compute_network" "default_network" {
  name = "default"
  depends_on = [
    google_project_service.default,
    google_compute_network.default_network_created
  ]
}

resource "google_sourcerepo_repository" "repo" {
  name       = "ghacks-adk-intro"
  depends_on = [google_project_service.default]
}

resource "google_service_account" "build_sa" {
  account_id   = "sa-build"
  display_name = "Build Service Account"
}

resource "google_project_iam_member" "build_sa_roles" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/run.builder"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.build_sa.email}"
}

resource "google_service_account" "startup_vm_sa" {
  account_id   = "sa-startup-vm"
  display_name = "Startup VM Service Account"
}

resource "google_project_iam_member" "startup_vm_sa_roles" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/source.admin",
    "roles/run.sourceDeveloper",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.startup_vm_sa.email}"
}

resource "google_artifact_registry_repository" "cloud_run_source_deploy" {
  location      = var.gcp_region
  repository_id = "cloud-run-source-deploy"
  format        = "DOCKER"

  depends_on = [
    google_project_service.default
  ]
}

resource "google_compute_instance" "startup_vm" {
  name         = "gce-prd-lnx-env-setup"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm        = true
  }

  network_interface {
    network = data.google_compute_network.default_network.self_link
    access_config {}
  }

  service_account {
    email  = google_service_account.startup_vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile("${path.module}/setup.tftpl", {
    gcp_project_id = var.gcp_project_id,
    gcp_region     = var.gcp_region,
    source_repo    = google_sourcerepo_repository.repo.url,
    build_sa       = google_service_account.build_sa.email,
  })

  depends_on = [
    google_project_iam_member.build_sa_roles,
    google_project_iam_member.startup_vm_sa_roles,
    google_artifact_registry_repository.cloud_run_source_deploy
  ]
}

resource "google_compute_instance" "test_vms" {
  for_each     = { for vm in local.test_vms : vm.name => vm }

  name         = each.value.name
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm        = true
  }

  network_interface {
    network = data.google_compute_network.default_network.self_link
  }

  labels = each.value.labels
}
