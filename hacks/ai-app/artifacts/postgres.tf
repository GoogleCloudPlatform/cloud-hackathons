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

resource "random_password" "postgres_password" {
  length           = 16   # Adjust the length as needed
  special          = true # Include special characters (safe ones)
  override_special = "!@#$%^&*()-_"
  lower            = true
  upper            = true
}

resource "random_password" "postgres_mainuser_password" {
  length  = 16    # Adjust the length as needed
  special = false # Include special characters (safe ones)
  lower   = true
  upper   = true
}

resource "random_password" "postgres_minimaluser_password" {
  length  = 16    # Adjust the length as needed
  special = false # Include special characters (safe ones)
  lower   = true
  upper   = true
}


data "google_compute_network" "network" {
  name = "default"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "cloudsql-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.network.name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google
  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "main" {
  name             = "movie-guru-db-instance"
  database_version = "POSTGRES_15"
  region           = var.gcp_region
  project          = var.gcp_project_id
  root_password    = random_password.postgres_password.result
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = true
      private_network                               = data.google_compute_network.network.self_link
      enable_private_path_for_google_cloud_services = true
      # This is very bad practice in production.
      authorized_networks {
        name            = "All Networks"
        value           = "0.0.0.0/0"
        expiration_time = "3021-11-15T16:19:00.094Z"
      }
    }
    deletion_protection_enabled = true
  }
  depends_on = [google_project_service.default]

}

resource "google_sql_database" "database_fake_movies" {
  name     = "fake-movies-db"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "main_user" {
  name     = "main"
  instance = google_sql_database_instance.main.name
  password = random_password.postgres_mainuser_password.result
}

resource "google_sql_user" "minimal_password" {
  name     = "minimal-user"
  instance = google_sql_database_instance.main.name
  password = random_password.postgres_minimaluser_password.result
}


module "secret-manager" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.4"
  project_id = var.gcp_project_id
  secrets = [
    {
      name        = "postgres-main-user-password"
      secret_id   = "postgres-main-user-password"
      secret_data = random_password.postgres_mainuser_password.result
    },
    {
      name        = "postgres-minimal-user-password"
      secret_id   = "postgres-minimal-user-password"
      secret_data = random_password.postgres_minimaluser_password.result
    },
  ]
  depends_on = [google_project_service.default]

}