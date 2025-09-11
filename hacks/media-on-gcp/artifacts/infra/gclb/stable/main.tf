# Global External IP Address
resource "google_compute_global_address" "default" {
  project = var.project_id
  name    = "lb-ip-address"
}

# Cloud Endpoints Services (Dynamic)
resource "google_endpoints_service" "dynamic" {
  for_each       = var.backend_services

  project        = var.project_id
  service_name   = "${each.key}.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<-EOF
    swagger: "2.0"
    info:
      title: "API for ${each.key}"
      description: "A simple API for the ${each.key} service"
      version: "1.0.0"
    host: "${each.key}.endpoints.${var.project_id}.cloud.goog"
    x-google-endpoints:
    - name: "${each.key}.endpoints.${var.project_id}.cloud.goog"
      target: "${google_compute_global_address.default.address}"
    schemes:
      - "https"
    paths: {}
  EOF

  # NOTE:
  # Prevent deletion on destroy.
  # Deleteing this resource will not allow you to reuse again within 30 days. Can undelete service
  # Following, https://cloud.google.com/service-infrastructure/docs/manage-services#undeleting_a_service
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Managed SSL Certificate (Dynamic)
resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "managed-cert"
  managed {
    domains = [for key in keys(var.backend_services) : "${key}.endpoints.${var.project_id}.cloud.goog"]
  }
}

# URL Map for HTTPS (Dynamic)
resource "google_compute_url_map" "default" {
  project = var.project_id
  name    = "url-map"
  # A default service is required, so we pick the first one from the map.
  # This assumes the var.backend_services map is not empty.
  default_service = google_compute_backend_service.dynamic[keys(var.backend_services)[0]].id

  dynamic "host_rule" {
    for_each = var.backend_services
    content {
      hosts        = ["${host_rule.key}.endpoints.${var.project_id}.cloud.goog"]
      path_matcher = "${host_rule.key}-path-matcher"
    }
  }

  dynamic "path_matcher" {
    for_each = var.backend_services
    content {
      name            = "${path_matcher.key}-path-matcher"
      default_service = google_compute_backend_service.dynamic[path_matcher.key].id
      path_rule {
        paths   = ["/", "/*"]
        service = google_compute_backend_service.dynamic[path_matcher.key].id
      }
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

# Target Proxies
resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "http-redirect-proxy"
  url_map = google_compute_url_map.redirect.id
}

# Backend Services & Health Checks (Dynamic)
resource "google_compute_health_check" "http" {
  for_each = { for k, v in var.backend_services : k => v if v.healthcheck_protocol == "http" }
  project  = var.project_id
  name     = "http-health-check-${each.key}"
  http_health_check {
    port = each.value.port
  }
}

resource "google_compute_health_check" "ssl" {
  for_each = { for k, v in var.backend_services : k => v if v.healthcheck_protocol == "ssl" }
  project  = var.project_id
  name     = "ssl-health-check-${each.key}"
  ssl_health_check {
    port = each.value.port
  }
}

resource "google_compute_health_check" "tcp" {
  for_each = { for k, v in var.backend_services : k => v if v.healthcheck_protocol == "tcp" }
  project  = var.project_id
  name     = "tcp-health-check-${each.key}"
  tcp_health_check {
    port = each.value.port
  }
}

resource "google_compute_backend_service" "dynamic" {
  for_each      = var.backend_services
  project       = var.project_id
  name          = "backend-service-${each.key}"
  port_name     = each.value.port_name
  protocol      = each.value.protocol
  health_checks = [
    each.value.healthcheck_protocol == "http" ? google_compute_health_check.http[each.key].id :
    (each.value.healthcheck_protocol == "ssl" ? google_compute_health_check.ssl[each.key].id :
      google_compute_health_check.tcp[each.key].id)
  ]

  backend {
    group = each.value.instance_group
  }

  enable_cdn = each.value.enable_cdn
}

# Firewall Rule
resource "google_compute_firewall" "fwr-allow-health-check-and-lb" {
  project       = var.project_id
  name          = "fwr-allow-health-check-and-lb"
  network       = var.network
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server"] # Assumes the source MIGs have this tag on their instance template
}

# Global Forwarding Rules
resource "google_compute_global_forwarding_rule" "default" {
  project               = var.project_id
  name                  = "https-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "redirect" {
  project               = var.project_id
  name                  = "http-redirect-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.id
  ip_address            = google_compute_global_address.default.id
  load_balancing_scheme = "EXTERNAL"
}
