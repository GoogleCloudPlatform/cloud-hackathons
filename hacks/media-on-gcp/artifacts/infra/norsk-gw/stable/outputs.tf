output "instance_group_manager_instance_group" {
  description = "The full URL of the Norsk GW instance group created by the manager"
  value = module.norsk_gw.instance_group_manager_instance_group
}

output "instance_group_manager_self_link" {
  description = "The self-link of the Norsk GW instance group manager."
  value       = module.norsk_gw.instance_group_manager_self_link
}

output "instance_template_self_link" {
  description = "The self-link of the Norsk GW instance template."
  value       = module.norsk_gw.instance_template_self_link
}

output "named_ports" {
  description = "A list of named port configurations for the instance group."
  value       = module.norsk_gw.named_ports
}

# output "port" {
#   description = "The port for the Norsk GW instance group."
#   value       = module.norsk_gw.port
# }

# output "port_name" {
#   description = "The port name for the Norsk GW instance group."
#   value       = module.norsk_gw.port_name
# }

output "admin_user" {
  description = "Username for Admin."
  value       = "norsk-studio-admin"
}

output "admin_password" {
  description = "Password for Admin."
  value       = "Hackfest@IBC"
  sensitive   = true
}