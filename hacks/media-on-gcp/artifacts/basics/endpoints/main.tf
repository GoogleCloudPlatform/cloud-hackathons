# Global External IP Address
resource "google_compute_global_address" "default" {
  project = var.project_id
  name    = "lb-ip-address"
}

# Cloud Endpoints Service 1
resource "google_endpoints_service" "service_1" {
  project        = var.project_id
  service_name   = "instance1.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<EOF
swagger: "2.0"
info:
  title: "Cloud Endpoints DNS"
  description: "A simple API to manage DNS settings"
  version: "1.0.0"
host: "instance1.endpoints.${var.project_id}.cloud.goog"
x-google-endpoints:
- name: "instance1.endpoints.${var.project_id}.cloud.goog"
  target: "${google_compute_global_address.default.address}"
paths: {}
EOF
}

# Cloud Endpoints Service 2
resource "google_endpoints_service" "service_2" {
  project        = var.project_id
  service_name   = "instance2.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<EOF
swagger: "2.0"
info:
  title: "Cloud Endpoints DNS"
  description: "A simple API to manage DNS settings"
  version: "1.0.0"
host: "instance2.endpoints.${var.project_id}.cloud.goog"
x-google-endpoints:
- name: "instance2.endpoints.${var.project_id}.cloud.goog"
  target: "${google_compute_global_address.default.address}"
paths: {}
EOF
}

# Cloud Endpoints Service 3
resource "google_endpoints_service" "service_3" {
  project        = var.project_id
  service_name   = "instance3.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<EOF
swagger: "2.0"
info:
  title: "Cloud Endpoints DNS"
  description: "A simple API to manage DNS settings"
  version: "1.0.0"
host: "instance3.endpoints.${var.project_id}.cloud.goog"
x-google-endpoints:
- name: "instance3.endpoints.${var.project_id}.cloud.goog"
  target: "${google_compute_global_address.default.address}"
paths: {}
EOF
}

# Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "managed-cert"
  managed {
    domains = [
      "instance1.endpoints.${var.project_id}.cloud.goog",
      "instance2.endpoints.${var.project_id}.cloud.goog",
      "instance3.endpoints.${var.project_id}.cloud.goog"
    ]
  }
}

# Target HTTPS Proxy
resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# Target HTTP Proxy for Redirect
resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "http-redirect-proxy"
  url_map = google_compute_url_map.redirect.id
}

# URL Map for HTTPS
resource "google_compute_url_map" "default" {
  project         = var.project_id
  name            = "url-map"
  default_service = google_compute_backend_service.bs-mig1.id

  host_rule {
    hosts        = ["instance1.endpoints.${var.project_id}.cloud.goog"]
    path_matcher = "instance1-path-matcher"
  }

  path_matcher {
    name            = "instance1-path-matcher"
    default_service = google_compute_backend_service.bs-mig1.id

    path_rule {
      paths   = ["/", "/*"]
      service = google_compute_backend_service.bs-mig1.id
    }
  }

  host_rule {
    hosts        = ["instance2.endpoints.${var.project_id}.cloud.goog"]
    path_matcher = "instance2-path-matcher"
  }

  path_matcher {
    name            = "instance2-path-matcher"
    default_service = google_compute_backend_service.bs-mig2.id

    path_rule {
      paths   = ["/", "/*"]
      service = google_compute_backend_service.bs-mig2.id
    }
  }

  host_rule {
    hosts        = ["instance3.endpoints.${var.project_id}.cloud.goog"]
    path_matcher = "instance3-path-matcher"
  }

  path_matcher {
    name            = "instance3-path-matcher"
    default_service = google_compute_backend_service.bs-mig3.id

    path_rule {
      paths   = ["/", "/*"]
      service = google_compute_backend_service.bs-mig3.id
    }
  }
}

# URL Map for HTTP-to-HTTPS Redirect
resource "google_compute_url_map" "redirect" {
  project = var.project_id
  name    = "http-redirect-url-map"
  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" # 301
  }
}

# Backend Services & Health Checks
resource "google_compute_backend_service" "bs-mig1" {
  project     = var.project_id
  name        = "backend-service-mig1"
  port_name   = "http"
  protocol    = "HTTP"
  health_checks = [google_compute_health_check.http-health-check-mig1.id]
  backend {
    group = google_compute_region_instance_group_manager.mig1.instance_group
  }
}

resource "google_compute_health_check" "http-health-check-mig1" {
  project = var.project_id
  name    = "http-health-check-mig1"
  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "bs-mig2" {
  project     = var.project_id
  name        = "backend-service-mig2"
  port_name   = "http"
  protocol    = "HTTP"
  health_checks = [google_compute_health_check.http-health-check-mig2.id]
  backend {
    group = google_compute_region_instance_group_manager.mig2.instance_group
  }
}

resource "google_compute_health_check" "http-health-check-mig2" {
  project = var.project_id
  name    = "http-health-check-mig2"
  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "bs-mig3" {
  project     = var.project_id
  name        = "backend-service-mig3"
  port_name   = "http"
  protocol    = "HTTP"
  health_checks = [google_compute_health_check.http-health-check-mig3.id]
  backend {
    group = google_compute_region_instance_group_manager.mig3.instance_group
  }
}

resource "google_compute_health_check" "http-health-check-mig3" {
  project = var.project_id
  name    = "http-health-check-mig3"
  http_health_check {
    port = 80
  }
}

# Firewall Rule
resource "google_compute_firewall" "default" {
  project = var.project_id
  name    = "allow-health-check-and-lb"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server"]
}

# HTTPS Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  project               = var.project_id
  name                  = "https-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
  network_tier          = "PREMIUM"
  load_balancing_scheme = "EXTERNAL"
}

# HTTP Global Forwarding Rule for Redirect
resource "google_compute_global_forwarding_rule" "redirect" {
  project               = var.project_id
  name                  = "http-redirect-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.id
  ip_address            = google_compute_global_address.default.id
  network_tier          = "PREMIUM"
  load_balancing_scheme = "EXTERNAL"
}

# Managed Instance Groups (MIGs)
resource "google_compute_instance_template" "default" {
  project      = var.project_id
  name         = "instance-template"
  machine_type = "e2-medium"
  region       = var.region
  tags         = ["http-server"]
  network_interface {
    network = var.network
  }
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }
}

resource "google_compute_region_instance_group_manager" "mig1" {
  project            = var.project_id
  name               = "mig-1"
  base_instance_name = "mig-1"
  region             = var.region
  target_size        = 1
  version {
    name = "mig-1-v1"
    instance_template  = google_compute_instance_template.default.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "mig2" {
  project            = var.project_id
  name               = "mig-2"
  base_instance_name = "mig-2"
  region             = var.region
  target_size        = 1

  version {
    name = "mig-2-v1"
    instance_template  = google_compute_instance_template.default.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "mig3" {
  project            = var.project_id
  name               = "mig-3"
  base_instance_name = "mig-3"
  region             = var.region
  target_size        = 1
  version {
    name = "mig-3-v1"
    instance_template  = google_compute_instance_template.default.id
  }

  named_port {
    name = "http"
    port = 80
  }
}
