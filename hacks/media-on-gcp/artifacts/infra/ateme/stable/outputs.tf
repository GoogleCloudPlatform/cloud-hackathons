output "nea_instance_group_manager_instance_group" {
  description = "The full URL of the Ateme Nea instance group created by the manager"
  value = module.nea.instance_group_manager_instance_group
}

output "nea_instance_group_manager_self_link" {
  description = "The self-link of the Ateme Nea instance group manager."
  value       = module.nea.instance_group_manager_self_link
}

output "nea_instance_template_self_link" {
  description = "The self-link of the Ateme Nea instance template."
  value       = module.nea.instance_template_self_link
}

output "nea_named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.nea.named_ports
}

output "nea_port" {
  description = "The port for the Ateme Nea instance group."
  value       = module.nea.port
}

output "nea_port_name" {
  description = "The port name for the Ateme Nea instance group."
  value       = module.nea.port_name
}

output "titan_instance_group_manager_instance_group" {
  description = "The full URL of the Ateme Titan instance group created by the manager"
  value = module.titan.instance_group_manager_instance_group
}

output "titan_instance_group_manager_self_link" {
  description = "The self-link of the Ateme Titan instance group manager."
  value       = module.titan.instance_group_manager_self_link
}

output "titan_instance_template_self_link" {
  description = "The self-link of the Ateme Titan instance template."
  value       = module.titan.instance_template_self_link
}

output "titan_named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.titan.named_ports
}

output "titan_port" {
  description = "The port for the Ateme Titan instance group."
  value       = module.titan.port
}

output "titan_port_name" {
  description = "The port name for the Ateme Titan instance group."
  value       = module.titan.port_name
}