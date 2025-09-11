output "instance_group_manager_instance_group" {
  description = "The full URL of the Vizrt Vectar instance group created by the manager"
  value = module.compute.instance_group_manager_instance_group
}

output "instance_group_manager_self_link" {
  description = "The self-link of the Vizrt Vectar instance group manager."
  value       = module.compute.instance_group_manager_self_link
}

output "instance_template_self_link" {
  description = "The self-link of the Vizrt Vectar instance template."
  value       = module.compute.instance_template_self_link
}

output "named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.compute.named_ports
}

output "vectar_admin_username" {
  description = "Vectar admin username for RDP access."
  value       = "admin"
}

output "vectar_admin_password" {
  description = "Vectar admin password for RDP access."
  value       = random_password.admin_password.result
}

output "vectar_dns_address" {
  description = "URL for Vizrt Vectar service"
  value       = google_endpoints_service.dynamic.dns_address
}
