# Terraform configuration for creating multiple Global Network Endpoint Groups (NEGs).
# This configuration is the equivalent of the provided gcloud commands.

# Provider block to configure the Google Cloud provider.
# It's a good practice to specify the project here, and it will be inherited
# by all resources.
provider "google" {
  project = "ghack-student"
}

# NEG for "titan-be-neg"
resource "google_compute_global_network_endpoint_group" "titan_be_neg" {
  name                  = "titan-be-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 443
}

# NEG for "nea-be-neg"
resource "google_compute_global_network_endpoint_group" "nea_be_neg" {
  name                  = "nea-be-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 8080
}

# NEG for "darwin-be-neg"
resource "google_compute_global_network_endpoint_group" "darwin_be_neg" {
  name                  = "darwin-be-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 443
}

# NEG for "norsk-be-neg"
resource "google_compute_global_network_endpoint_group" "norsk_be_neg" {
  name                  = "norsk-be-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 443
}

# NEG for "cdn-be-neg"
resource "google_compute_global_network_endpoint_group" "cdn_be_neg" {
  name                  = "cdn-be-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 80
}

# Reserve a global external IP address
resource "google_compute_global_address" "gclb_ext_ip" {
  name       = "gclb-ext-ip"
  ip_version = "IPV4"
}

# Backend Service for "nea-be"
resource "google_compute_backend_service" "nea_be" {
  name                  = "nea-be"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_global_network_endpoint_group.nea_be_neg.id
  }
}

# Backend Service for "titan-be"
resource "google_compute_backend_service" "titan_be" {
  name                  = "titan-be"
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_global_network_endpoint_group.titan_be_neg.id
  }
}

# Backend Service for "norsk-be"
resource "google_compute_backend_service" "norsk_be" {
  name                  = "norsk-be"
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_global_network_endpoint_group.norsk_be_neg.id
  }
}

# Backend Service for "darwin-be"
resource "google_compute_backend_service" "darwin_be" {
  name                  = "darwin-be"
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_global_network_endpoint_group.darwin_be_neg.id
  }
}

# URL Map to route requests to the backend services
resource "google_compute_url_map" "ghack_url_map" {
  name            = "ghack-url-map"
  default_service = google_compute_backend_service.nea_be.id
}

