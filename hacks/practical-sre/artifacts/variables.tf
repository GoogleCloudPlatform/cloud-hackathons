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

variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "repo_prefix" {
  type        = string
  description = "Docker/Artifact registry prefix"
  default     = "us-central1-docker.pkg.dev/o11y-movie-guru/movie-guru"
}

variable "image_tag" {
  description = "TAG of the movie guru docker images"
  default     = "sre-5e670f8"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "Region"
}

# Default value passed in
variable "gcp_zone" {
  type        = string
  description = "Zone to create resources in."
  default     = "us-central1-c"
}

variable "locust_py_file" {
  type = string

  description = "URL of the locustfile"
  default     = "https://raw.githubusercontent.com/MKand/movie-guru/refs/heads/main/ghacks/practical-sre/locust/locustfile.py"
}


variable "otel_file" {
  type = string

  description = "URL of the otel config"
  default     = "https://raw.githubusercontent.com/MKand/movie-guru/refs/heads/main/utils/metrics/otel.values.yaml"
}

