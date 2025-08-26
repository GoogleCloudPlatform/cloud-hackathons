variable "project_id" {
  description = "The Google Cloud Project ID."
  type        = string
}

variable "region" {
  description = "The region for the instance groups."
  type        = string
}

variable "network" {
  description = "The name of the VPC network to deploy resources in."
  type        = string
  default     = "default"
}

variable "backend_services" {
  description = "A map of backend services to create. The key is the subdomain identifier (e.g., 'instance1') and the value is the 'instance_group' attribute of a google_compute_region_instance_group_manager."
  type        = map(string)
  default     = {}
}