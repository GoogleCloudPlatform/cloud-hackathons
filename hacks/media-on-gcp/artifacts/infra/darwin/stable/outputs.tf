output "darwin_instance_group_manager_instance_group" {
  description = "The full URL of the Ateme NL instance group created by the manager"
  value = module.darwin.instance_group_manager_instance_group
}

output "darwin_instance_group_manager_self_link" {
  description = "The self-link of the Darwin instance group manager."
  value       = module.darwin.instance_group_manager_self_link
}

output "darwin_instance_template_self_link" {
  description = "The self-link of the Darwin instance template."
  value       = module.darwin.instance_template_self_link
}

output "darwin_named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.darwin.named_ports
}

# output "darwin_port" {
#   description = "The port for the Darwin instance group."
#   value       = module.darwin.port
# }

# output "darwin_port_name" {
#   description = "The port name for the Darwin instance group."
#   value       = module.darwin.port_name
# }
