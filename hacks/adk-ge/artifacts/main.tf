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
    "geminidataanalytics.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
}

# "roles/bigquery.dataViewer" BQ Toolset
# "roles/bigquery.user" BQ Toolset (Job User also fine)
# "roles/cloudaicompanion.user" x
# "roles/dataplex.catalogAdmin" MCP KC (Viewer also fine)
# "roles/geminidataanalytics.dataAgentStatelessUser" BQ Toolset ask_data_insights
# "roles/geminidataanalytics.dataAgentUser" BQ Toolset ask_data_insights
# "roles/mcp.toolUser" MCP KC


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
    query              = file("${path.module}/generate_data.sql")
    create_disposition = ""
    write_disposition  = ""
  }

  depends_on = [google_bigquery_dataset.retail_banking]
}
