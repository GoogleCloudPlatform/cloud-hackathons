variable "gcp_project_id" {
  type        = string
  description = "The Google Cloud project ID."
  default     = "stark-prod-2024"
}

variable "gcp_project_number" {
  type        = string
  description = "The Google Cloud project number for the service account."
}

variable "teamname" {
  type        = string
  description = "A unique team name for the instance."
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC network."
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet."
}
