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

module "ateme" {
  source = "./infra/ateme/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "darwin" {
  source = "./infra/darwin/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "norsk_gw" {
  source = "./infra/norsk-gw/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone
  # domain_name = "norsk.${local.endpoint_url}"

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "norsk_ai" {
  source = "./infra/norsk-ai/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone
  # domain_name = "gemini.${local.endpoint_url}"

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "davinci" {
  source = "./infra/davinci/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "vizrt" {
  source = "./infra/vizrt-vectar/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "stitcher" {
  source = "./infra/stitcher/stable"

  project_id = local.project.id
  region     = var.gcp_region
  zone       = var.gcp_zone

  networks = [module.vpc.network_name]

  depends_on = [ google_project_iam_member.centralized_project_binding ]
}

module "team_setup" {
  source = "./infra/team-setup"

  providers = {
    google                              = google
    google.bootstrap_user_account_googl = google.bootstrap_user_account_googl
  }

  gcp_project_id      = local.project.id
  host_gcp_project_id = local.host_project.id

  api_endpoint = "https://team-name-vendor-669648730623.us-central1.run.app/team"

  host_centralized_serviceaccount_name = var.host_centralized_serviceaccount_name
}
