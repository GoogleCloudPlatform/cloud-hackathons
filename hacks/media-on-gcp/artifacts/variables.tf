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
variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to create resources in."
}

# Default value passed in
variable "gcp_region" {
  type        = string
  description = "Region to create resources in."
  default     = "europe-west4"
}

# Default value passed in
variable "gcp_zone" {
  type        = string
  description = "Zone to create resources in."
  default     = "europe-west4-a"
}

# Relevant when running on a system where no default network exists yet
variable "create_default_network" {
  type        = bool
  default     = false
  description = "Whether to create a default network with subnets for all regions"
}

# This is an access token for a user running in the QL org that is the one running this tf script
variable "access_token" {
  type        = string
  description = "access token for the qwiklab.net account."
  default     = ""
}

variable "host_gcp_project_id" {
  type        = string
  default     = "media-on-gcp-storage"
  description = "The GCP project ID to pull resouces from."
}

variable "host_centralized_serviceaccount_name" {
  type        = string
  default     = "ql-manager-sa"
  description = "Centralized SA for project connnection"
}
