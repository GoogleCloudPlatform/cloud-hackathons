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
  default     = "europe-west4-c"
}

variable "helm_chart" {
  description = "URL of the movie guru helm chart"
  default = "https://mkand.github.io/movie-guru/movie-guru-0.6.0.tgz"
}

variable "locust_file" {
  description = "URL of the locustfile"
  default = "https://raw.githubusercontent.com/MKand/movie-guru/refs/heads/ghack-sre/locust/locustfile.py"
}
