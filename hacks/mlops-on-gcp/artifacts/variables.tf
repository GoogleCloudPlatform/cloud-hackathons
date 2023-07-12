# --------------------------------------------------------------
## Mandatory variable definitions
## --------------------------------------------------------------

variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to create resources in."
}

# Default value passed in
variable "gcp_region" {
  type        = string
  description = "Region to create resources in."
}

# Default value passed in
variable "gcp_zone" {
  type        = string
  description = "Zone to create resources in."
}

# Relevant when running on Argolis and/or no default network exists yet
variable "create_default_network" {
  type        = bool
  default     = false
  description = "Whether to create a default network with subnets for all regions"
}
