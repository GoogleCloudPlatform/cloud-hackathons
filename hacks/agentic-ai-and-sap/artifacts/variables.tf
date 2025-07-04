variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to apply this config to."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region to apply this config to."
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone to apply this config to."
}

variable "username" {
  type        = string
  description = "The lab username"
}

variable "ssh_pvt_key" {
  type        = string
  description = "The public SSH key for user"
}

#The service account key for cloud run command execution
variable "service_account_key_file" {
  type = string
  description = "key file location"
}