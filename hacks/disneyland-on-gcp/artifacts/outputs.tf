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

output "project_id" {
  value = var.gcp_project_id
}

output "alloydb_ip" {
  value = google_alloydb_instance.default.ip_address
}

output "alloydb_usr" {
  value = google_alloydb_cluster.default.initial_user[0].user
}

output "alloydb_pwd" {
  value     = google_alloydb_cluster.default.initial_user[0].password
  sensitive = true
}

output "bq_connection_id" {
  value = google_bigquery_connection.vertex_ai_conn.connection_id
}
