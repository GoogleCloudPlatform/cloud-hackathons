variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The zone for the solution to be deployed."
  type        = string
  default     = "europe-west4-a"
}

variable "networks" {
  description = "The network name to attach the GCLB"
  type        = list(string)
  default     = ["default"]
}

variable "sub_networks" {
  description = "The sub network name to attach the GCLB"
  type        = list(string)
  default     = []
}

variable "external_ips" {
  description = "The external IPs assigned to the GCLB for public access."
  type        = list(string)
  default     = ["EPHEMERAL"]
}
