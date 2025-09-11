output "instance_group_manager_instance_group" {
  description = "The full URL of the instance group created by the manager"
  value       = google_compute_region_instance_group_manager.mig.instance_group
}

output "instance_group_manager_self_link" {
  description = "The self-link of the instance group manager."
  value       = google_compute_region_instance_group_manager.mig.self_link
}

output "instance_template_self_link" {
  description = "The self-link of the instance template."
  value       = google_compute_instance_template.instance_template.self_link
}

output "named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = var.named_ports
}

output "port" {
  description = "The first port from the list of named ports."
  value       = length(var.named_ports) > 0 ? var.named_ports : null
}

output "port_name" {
  description = "The first port name from the list of named ports."
  value       = length(var.named_ports) > 0 ? var.named_ports : null
}


# output "port" {
#   description = "The first port from the list of named ports."
#   value       = length(var.named_ports) > 0 ? var.named_ports[0].port : null
# }

# output "port_name" {
#   description = "The first port name from the list of named ports."
#   value       = length(var.named_ports) > 0 ? var.named_ports[0].name : null
# }
