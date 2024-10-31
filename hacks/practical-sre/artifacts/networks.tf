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

module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  project_id   = var.gcp_project_id
  network_name = "movie-guru-vpc"

  subnets = [
    {
      subnet_name   = "cluster-subnet"
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.gcp_region
    },
  ]
  }
