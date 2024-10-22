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
# limitations under the License.data "google_client_config" "default" {}


resource "google_container_cluster" "primary" {
  name               = "movie-guru-gke"
  location           = var.gcp_region
  project = var.gcp_project_id
  initial_node_count = 1
  network = module.gcp-network.network_name
  subnetwork = "cluster-subnet"
  
  node_config {
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_container_node_pool" "np" {
  name       = "workload-node-pool"
  cluster    = google_container_cluster.primary.id
  project = var.gcp_project_id
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }
  node_config {
    machine_type = "e2-medium"
    service_account = google_service_account.default.email
    oauth_scopes    = [
       "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}