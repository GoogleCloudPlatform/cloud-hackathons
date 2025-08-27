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
  description = "A map of backend services to create. The key is the subdomain identifier (e.g., 'instance1') and the value is an object containing the 'instance_group', 'port', 'port_name', and 'healthcheck_protocol'."
  type = map(object({
    instance_group       = string
    port                 = number
    port_name            = string
    protocol             = string
    healthcheck_protocol = string
    enable_cdn           = bool
  }))
  default = {}
}