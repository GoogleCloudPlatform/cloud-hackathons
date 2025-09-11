output "nea_instance_group_manager_instance_group" {
  description = "The full URL of the Ateme Nea instance group created by the manager"
  value = module.compute_nea.instance_group_manager_instance_group
}

output "nea_instance_group_manager_self_link" {
  description = "The self-link of the Ateme Nea instance group manager."
  value       = module.compute_nea.instance_group_manager_self_link
}

output "nea_instance_template_self_link" {
  description = "The self-link of the Ateme Nea instance template."
  value       = module.compute_nea.instance_template_self_link
}

output "nea_named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.compute_nea.named_ports
}

output "nea_port" {
  description = "The port for the Ateme Nea instance group."
  value       = module.compute_nea.port
}

output "nea_port_name" {
  description = "The port name for the Ateme Nea instance group."
  value       = module.compute_nea.port_name
}

output "titan_instance_group_manager_instance_group" {
  description = "The full URL of the Ateme Titan instance group created by the manager"
  value = module.compute_titan.instance_group_manager_instance_group
}

output "titan_instance_group_manager_self_link" {
  description = "The self-link of the Ateme Titan instance group manager."
  value       = module.compute_titan.instance_group_manager_self_link
}

output "titan_instance_template_self_link" {
  description = "The self-link of the Ateme Titan instance template."
  value       = module.compute_titan.instance_template_self_link
}

output "titan_named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.compute_titan.named_ports
}
