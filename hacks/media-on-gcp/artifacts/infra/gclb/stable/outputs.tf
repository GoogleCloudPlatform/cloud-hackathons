output "lb_ip_address" {
  description = "The reserved static IP address of the load balancer."
  value       = google_compute_global_address.default.address
}

output "endpoint_dns_addresses" {
  description = "The DNS addresses for the Cloud Endpoints services."
  value       = { for key, service in google_endpoints_service.dynamic : key => service.service_name }
}
