data "google_project" "project" {}

// Enable the APIs we need: computer, logging, monitoring and recaptcha
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "logging_api" {
  service = "logging.googleapis.com"
}

resource "google_project_service" "monitoring_api" {
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "recaptcha_api" {
  service = "recaptchaenterprise.googleapis.com"
}

// Create the "default" VPC with auto subnets enabled
resource "google_compute_network" "vpc_network" {
  name = "ghack"
  auto_create_subnetworks = true
}