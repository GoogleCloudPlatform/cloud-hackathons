variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to apply this config to."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region to apply this config to."
}

#The service account key for cloud run command execution
variable "service_account_key_file" {
  type = string
  description = "key file location"
}