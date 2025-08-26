# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_storage_bucket" "otel" {
  name                        = "otel-config-${var.gcp_project_id}"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on = [ google_project_service.enable_apis ]
}

resource "google_storage_bucket" "locust" {
  name                        = "locust-config-${var.gcp_project_id}"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on = [ google_project_service.enable_apis ]
}


data "http" "otel-config" {
  url = var.otel_file
  request_headers = {
    Accept = "application/json"
  }
}

data "http" "locust-config" {
  url =  var.locust_py_file
  request_headers = {
    Accept = "application/json"
  }
}

resource "google_storage_bucket_object" "otel" {
  name   = "otel.values.yaml"
  bucket = google_storage_bucket.otel.name
  content = data.http.otel-config.response_body
}

resource "google_storage_bucket_object" "locust" {
  name   = "locust.py"
  bucket = google_storage_bucket.locust.name
  content = data.http.locust-config.response_body
}


resource "google_cloud_run_v2_service" "app" {
  name     = "movieguru-server"
  location = var.gcp_region

  template {
    scaling {
      max_instance_count = 1
    }
    # Revision-level annotations, including container dependencies
    annotations = {
      "run.googleapis.com/container-dependencies" = jsonencode({
        app = ["collector"]
      })
    }

    service_account = google_service_account.service_account.email
    containers {
      # The main application container
      name  = "app"
      image = "${var.repo_prefix}/chatserver:${var.image_tag}"
      ports {
        container_port = 8080
      }
      command = ["/app/mockserver"]

      env {
        name  = "ENABLE_METRICS"
        value = "true"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://localhost:4318"
      }
      env {
        name  = "PROJECT_ID"
        value = var.gcp_project_id
      }
      env {
        name  = "LOCATION"
        value = var.gcp_region
      }
    }

    containers {
      # The OpenTelemetry sidecar container
      name  = "collector"
      image = "us-docker.pkg.dev/cloud-ops-agents-artifacts/google-cloud-opentelemetry-collector/otelcol-google:0.130.0"
      args  = ["--config=/etc/otelcol-google/otel.values.yaml"]

      volume_mounts {
        name       = "config"
        mount_path = "/etc/otelcol-google/"
      }
    }
    volumes {
      name = "config"
      gcs {
        read_only = true
        bucket    = google_storage_bucket.otel.name
      }
    }
  }
  deletion_protection = false
  depends_on = [ google_project_service.enable_apis ]
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.app.location
  service  = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

resource "google_cloud_run_v2_service" "locust" {
  name     = "locust-server"
  location = var.gcp_region
  template {
    scaling {
      max_instance_count = 10
    }

    service_account = google_service_account.service_account.email
    containers {
      name  = "locust"
      image = "locustio/locust:2.38.0"
      args = [
        "-f /mnt/locust/locust.py",
        "--host=${google_cloud_run_v2_service.app.urls[0]}"
      ]
      ports {
        container_port = 8089
      }
      volume_mounts {
        name       = "locust-config"
        mount_path = "/mnt/locust"
      }
    }
    volumes {
      name = "locust-config"
      gcs {
        read_only = true
        bucket    = google_storage_bucket.locust.name
      }
    }
  }
  deletion_protection = false
  depends_on = [ google_project_service.enable_apis ]

}


resource "google_cloud_run_service_iam_binding" "locust" {
  location = google_cloud_run_v2_service.locust.location
  service  = google_cloud_run_v2_service.locust.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}