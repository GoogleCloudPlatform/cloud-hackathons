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

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.primary.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster.primary.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

resource "google_compute_address" "server-address" {
  name         = "server-address"
  address_type = "EXTERNAL"
  project = var.gcp_project_id
  region = var.gcp_region
}

resource "google_compute_address" "frontend-address" {
  name         = "frontend-address"
  address_type = "EXTERNAL"
  project = var.gcp_project_id
  region = var.gcp_region
}

resource "google_compute_address" "mockserver-address" {
  name         = "mockerserver-address"
  address_type = "EXTERNAL"
  project = var.gcp_project_id
  region = var.gcp_region
}


data "http" "locustfile" {
  url = var.locust_file
}

resource "helm_release" "movie_guru" {
  name  = "movie-guru"
  chart = var.helm_chart
  set {
    name  = "Config.Image.Repository"
    value = "manaskandula"
  }
  set {
    name  = "Config.serverIP"
    value = google_compute_address.server-address.address
  }
    set {
    name  = "Config.mockserverIP"
    value = google_compute_address.mockserver-address.address
  }
  
    set {
    name  = "Config.frontendIP"
    value = google_compute_address.frontend-address.address
  }
  set {
    name  = "Config.projectID"
    value = var.gcp_project_id
  }
  depends_on = [ google_compute_address.server-address ]
}

resource "kubernetes_config_map" "loadtest_locustfile" {
  metadata {
    name      = "loadtest-locustfile"
    namespace = "locust"
  }

  data = {
    "locustfile.py" = (
      data.http.locustfile.response_body
    )
  }
  depends_on = [helm_release.movie_guru]
}

resource "helm_release" "locust" {
  name      = "locust"
  chart     = "oci://ghcr.io/deliveryhero/helm-charts/locust"
  namespace = "locust"
  version   = "0.31.6"

  set {
    name  = "loadtest.name"
    value = "movieguru-loadtest"
  }

  set {
    name  = "loadtest.locust_locustfile_configmap"
    value = "loadtest-locustfile" 
  }

  set {
    name  = "loadtest.locust_locustfile"
    value = "locustfile.py"
  }
  set {
    name  = "loadtest.locust_host"
    value = "http://mockserver-service.movie-guru.svc.cluster.local"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "worker.replicas"
    value = "3"
  }

    depends_on = [helm_release.movie_guru, kubernetes_config_map.loadtest_locustfile]
}

data "kubernetes_service" "locust" {
  metadata {
    name      = "locust"  
    namespace = "locust"   
  }
    depends_on = [ helm_release.locust ]

}

