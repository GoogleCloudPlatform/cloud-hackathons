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

