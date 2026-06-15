# Copyright 2026 Google LLC
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
    "bigquery.googleapis.com",
    "agentregistry.googleapis.com",
    "aiplatform.googleapis.com",
    "apphub.googleapis.com",
    "apptopology.googleapis.com",
    "cloudapiregistry.googleapis.com",
    "iamconnectors.googleapis.com",
    "iap.googleapis.com",
    "modelarmor.googleapis.com",
    "networksecurity.googleapis.com",
    "networkservices.googleapis.com",
    "observability.googleapis.com",
    "saasservicemgmt.googleapis.com",
    "texttospeech.googleapis.com",
    "geminidataanalytics.googleapis.com",
    "sourcerepo.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
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
  name       = "ghacks-adk-ge"
  depends_on = [google_project_service.default]
}

resource "google_bigquery_dataset" "retail_banking" {
  dataset_id                 = "retail_banking"
  friendly_name              = "Retail Banking"
  description                = "Dataset containing retail banking customers and accounts data"
  location                   = var.gcp_region
  delete_contents_on_destroy = true

  depends_on = [google_project_service.default]
}

resource "random_id" "job_suffix" {
  byte_length = 8
  keepers = {
    # Re-run the job when the SQL query content or dataset ID changes
    sql_hash   = sha256(file("${path.module}/generate_data.sql"))
    dataset_id = google_bigquery_dataset.retail_banking.dataset_id
  }
}

resource "google_bigquery_job" "generate_data" {
  job_id   = "generate_data_${random_id.job_suffix.hex}"
  location = var.gcp_region

  query {
    query = templatefile("${path.module}/generate_data.sql", {
      dataset_id = google_bigquery_dataset.retail_banking.dataset_id
    })
    create_disposition = ""
    write_disposition  = ""
  }

  depends_on = [google_bigquery_dataset.retail_banking]
}

resource "google_service_account" "startup_vm_sa" {
  account_id   = "sa-startup-vm"
  display_name = "Startup VM Service Account"
}

resource "google_project_iam_member" "startup_vm_sa_roles" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/source.admin",
    "roles/logging.logWriter"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.startup_vm_sa.email}"
}


resource "google_compute_instance" "startup_vm" {
  name         = "gce-lnx-env-setup"
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
    source_repo    = google_sourcerepo_repository.repo.url
  })

  depends_on = [
    google_project_iam_member.startup_vm_sa_roles
  ]
}

