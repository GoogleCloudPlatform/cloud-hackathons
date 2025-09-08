variable "gcp_project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "host_gcp_project_id" {
  description = "The ID of the host project."
  type        = string
}

variable "location" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "US"
}

variable "populate_hp_client_bucket" {
  description = "If true, populates the hp_client bucket with artifacts from a remote source."
  type        = bool
  default     = false
}

variable "hp_client_artifacts_source_uri" {
  description = "The URI of the remote bucket to source artifacts from for the hp_client bucket."
  type        = string
  default     = ""
}

variable "host_centralized_serviceaccount_name" {
  description = "The name of the service account to impersonate for the copy operation."
  type        = string
  default     = ""
}