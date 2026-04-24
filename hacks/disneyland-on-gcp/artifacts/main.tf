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
    "alloydb.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "datastream.googleapis.com",
    "aiplatform.googleapis.com",
    "dataplex.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudaicompanion.googleapis.com",
    "geminicloudassist.googleapis.com",
    "geminidataanalytics.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
}

# In case a default network is not present in the project, this variable needs to be set
resource "google_compute_network" "default_network_created" {
  name                    = "default"
  auto_create_subnetworks = true
  count                   = var.create_default_network ? 1 : 0
  depends_on = [
    google_project_service.default
  ]
}

# Enabling comms between VMs for auto mode subnets (needed by Dataproc/Dataflow workers)
resource "google_compute_firewall" "fwr_allow_custom" {
  name          = "fwr-ingress-allow-custom"
  network       = google_compute_network.default_network_created[0].self_link
  count         = var.create_default_network ? 1 : 0
  source_ranges = ["10.128.0.0/9"]
  allow {
    protocol = "all"
  }
}

# Enabling Identity-Aware-Proxy for TCP forwarding (for SSH access from Console)
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

# Allow Datastream to access the TCP Proxy
resource "google_compute_firewall" "fwr_allow_datastream" {
  name        = "fwr-ingress-allow-datastream-us-central1"
  network     = data.google_compute_network.default_network.name
  description = "Allow Datastream public IPs for us-central1 to access PostgreSQL proxy"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [
    "34.72.28.29/32",
    "34.67.234.134/32",
    "34.67.6.157/32",
    "34.72.239.218/32",
    "34.71.242.81/32"
  ]

  target_tags = ["tcp-proxy"]
}

# Reserve a range for Private Service Access
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "alloydb-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default_network.id
}

# Create the VPC Peering connection
resource "google_service_networking_connection" "vpc_connection" {
  network                 = data.google_compute_network.default_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  depends_on              = [google_project_service.default]
}

# Random password for the AlloyDB database user
resource "random_string" "password" {
  length  = 12
  special = false
}

# AlloyDB Cluster
resource "google_alloydb_cluster" "default" {
  cluster_id = "disney-cluster"
  location   = var.gcp_region

  network_config {
    network = data.google_compute_network.default_network.id
  }

  initial_user {
    user     = "postgres"
    password = random_string.password.result
  }

  depends_on = [
    google_project_service.default,
    google_service_networking_connection.vpc_connection
  ]
}

resource "google_alloydb_instance" "default" {
  cluster       = google_alloydb_cluster.default.name
  instance_id   = "disney-instance"
  instance_type = "PRIMARY"

  database_flags = {
    "alloydb.logical_decoding" = "on" # needed for replication
    "bigquery_fdw.enabled"     = "on" # needed for connecting to bq
  }

  machine_config {
    cpu_count = 2
  }

  depends_on = [google_alloydb_cluster.default]
}

# Storage Bucket
resource "google_storage_bucket" "disney" {
  name                        = var.gcp_project_id
  location                    = var.gcp_region
  uniform_bucket_level_access = true
}

# BigQuery Dataset
resource "google_bigquery_dataset" "disney" {
  dataset_id                 = "disney"
  friendly_name              = "Disneyland Data"
  description                = "Dataset for Disneyland Data Analytics"
  location                   = var.gcp_region
  delete_contents_on_destroy = true

  depends_on = [google_project_service.default]
}

resource "google_bigquery_reservation" "bq_edition" {
  name          = "disneyland-analytics"
  location      = var.gcp_region
  edition       = "ENTERPRISE"
  slot_capacity = 0

  autoscale {
    max_slots = 100
  }
}

resource "google_bigquery_reservation_assignment" "default" {
  assignee    = "projects/${var.gcp_project_id}"
  reservation = google_bigquery_reservation.bq_edition.id
  job_type    = "QUERY"
}

# BigQuery Cloud Resource Connection
resource "google_bigquery_connection" "agent_platform" {
  connection_id = "conn"
  location      = var.gcp_region
  friendly_name = "Connection to Agent Platform"
  cloud_resource {}

  depends_on = [google_project_service.default]
}

# Grant Agent Platform User and Storage Viewer to BigQuery Connection Service Account
resource "google_project_iam_member" "bq_connection_roles" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/storage.objectViewer"
  ])
  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_bigquery_connection.agent_platform.cloud_resource[0].service_account_id}"
}

# AlloyDB Service Agent
resource "google_project_service_identity" "alloydb_sa" {
  provider = google-beta
  project  = var.gcp_project_id
  service  = "alloydb.googleapis.com"
}

# Grant Agent Platform User, BQ Viewer and BQ Read Session User to AlloyDB Service Agent
resource "google_project_iam_member" "alloydb_sa_roles" {
  for_each = toset([
    "roles/aiplatform.user",
    # "roles/bigquery.dataViewer",  # these need to be granted to another service account
    # "roles/bigquery.readSessionUser"
  ])
  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_project_service_identity.alloydb_sa.email}"
}

# Pre-provided Python UDF for PDF chunking
resource "google_bigquery_routine" "chunk_pdf" {
  provider        = google-beta
  dataset_id      = google_bigquery_dataset.disney.dataset_id
  routine_id      = "chunk_pdf"
  routine_type    = "SCALAR_FUNCTION"
  language        = "PYTHON"
  definition_body = <<-EOT
import io
import json

from pypdf import PdfReader  # type: ignore
from urllib.request import urlopen, Request

def chunk_pdf(src_ref: str, chunk_size: int, overlap_size: int) -> str:
 src_json = json.loads(src_ref)
 srcUrl = src_json["access_urls"]["read_url"]

 req = urlopen(srcUrl)
 pdf_file = io.BytesIO(bytearray(req.read()))
 reader = PdfReader(pdf_file, strict=False)

 # extract and chunk text simultaneously
 all_text_chunks = []
 curr_chunk = ""
 for page in reader.pages:
     page_text = page.extract_text()
     if page_text:
         curr_chunk += page_text
         # split the accumulated text into chunks of a specific size with overlaop
         # this loop implements a sliding window approach to create chunks
         while len(curr_chunk) >= chunk_size:
             split_idx = curr_chunk.rfind(" ", 0, chunk_size)
             if split_idx == -1:
                 split_idx = chunk_size
             actual_chunk = curr_chunk[:split_idx]
             all_text_chunks.append(actual_chunk)
             overlap = curr_chunk[split_idx + 1 : split_idx + 1 + overlap_size]
             curr_chunk = overlap + curr_chunk[split_idx + 1 + overlap_size :]
 if curr_chunk:
     all_text_chunks.append(curr_chunk)

 return all_text_chunks
EOT

  python_options {
    entry_point = "chunk_pdf"
    packages    = ["pypdf==6.10.2"]
  }

  arguments {
    name      = "src_json"
    data_type = "{\"typeKind\": \"STRING\"}"
  }
  arguments {
    name      = "chunk_size"
    data_type = "{\"typeKind\": \"INT64\"}"
  }
  arguments {
    name      = "overlap_size"
    data_type = "{\"typeKind\": \"INT64\"}"
  }
  return_type = "{\"typeKind\": \"ARRAY\", \"arrayElementType\": {\"typeKind\": \"STRING\"}}"


  external_runtime_options {
    runtime_version    = "python-3.11"
    runtime_connection = google_bigquery_connection.agent_platform.id
  }
}


# TCP Proxy for AlloyDB (Datastream)
resource "google_compute_instance" "gce_tcp_proxy" {
  name         = "gce-tcp-proxy"
  machine_type = "e2-micro"
  zone         = var.gcp_zone
  tags         = ["tcp-proxy"]

  boot_disk {
    initialize_params {
      image = "projects/cos-cloud/global/images/family/cos-stable"
    }
  }

  network_interface {
    network = data.google_compute_network.default_network.id
    access_config {
      // Ephemeral public IP
    }
  }

  can_ip_forward = true

  metadata = {
    startup-script = <<-EOT
      #! /bin/bash
      # Configure Docker
      mkdir -p /etc/docker
      cat <<EOF > /etc/docker/daemon.json
      {"bridge":"none"}
      EOF
      systemctl restart docker

      # Run the TCP proxy container
      docker run -d --name=tcp-proxy \
        --restart=always \
        --net=host \
        -e SOURCE_CONFIG=${google_alloydb_instance.default.ip_address}:5432 \
        gcr.io/dms-images/tcp-proxy
      iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
    EOT
  }

  depends_on = [google_alloydb_instance.default]
}
