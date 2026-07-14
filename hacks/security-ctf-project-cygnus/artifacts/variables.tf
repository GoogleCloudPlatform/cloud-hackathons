# variables.tf
# Defines the input variables needed to run the Terraform code.

variable "project_id" {
  type        = string
  description = "The unique ID of the Google Cloud project for the CTF."
}

variable "region" {
  type        = string
  description = "The primary region for deploying resources."
  default     = "europe-west4"
}

variable "project_number" {
  type        = string
  description = "The project number for the GCP project. Needed for default service account names."
}
