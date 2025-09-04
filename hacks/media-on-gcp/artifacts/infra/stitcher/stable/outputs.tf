output "instance_group_manager_instance_group" {
  description = "The full URL of the DaVinci Resolve instance group created by the manager"
  value = module.compute.instance_group_manager_instance_group
}

output "instance_group_manager_self_link" {
  description = "The self-link of the DaVinci Resolve instance group manager."
  value       = module.compute.instance_group_manager_self_link
}

output "instance_template_self_link" {
  description = "The self-link of the DaVinci Resolve instance template."
  value       = module.compute.instance_template_self_link
}

output "named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.compute.named_ports
}

output "resolve_admin_username" {
  description = "Resolve admin username for RDP access."
  value       = "admin"
}

output "resolve_admin_password" {
  description = "Resolve admin password for RDP access."
  value       = random_password.admin_password.result
}

output "resolve_dns_address" {
  description = "URL for Davinci Resolve service"
  value       = google_endpoints_service.dynamic.dns_address
}
