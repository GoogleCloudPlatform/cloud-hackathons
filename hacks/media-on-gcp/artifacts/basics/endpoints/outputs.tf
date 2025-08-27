output "lb_ip_address" {
  description = "The reserved static IP address of the load balancer."
  value       = google_compute_global_address.default.address
}

# output "dns_name_servers" {
#   description = "The name servers for the managed DNS zone."
#   value       = google_dns_managed_zone.endpoints_zone.name_servers
# }
