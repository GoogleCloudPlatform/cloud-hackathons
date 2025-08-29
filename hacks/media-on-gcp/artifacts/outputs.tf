# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
output "project_id" {
    value = var.gcp_project_id
}

output "norsk_admin_user" {
  description = "Norsk admin username."
  value       = module.norsk_gw.admin_user
}

output "norsk_admin_password" {
  description = "Norsk admin password."
  value       = module.norsk_gw.admin_password
  sensitive   = true
}

output "vectar_admin_username" {
  description = "Vectar admin username for RDP access."
  value       = module.vizrt.vectar_admin_username
}

output "vectar_admin_password" {
  description = "Vectar admin password for RDP access."
  value       = module.vizrt.vectar_admin_password
  sensitive   = true
}

output "vectar_dns_address" {
  description = "URL for Vizrt Vectar RDP service"
  value       = module.vizrt.vectar_dns_address
}

output "resolve_admin_username" {
  description = "Resolve admin username for RDP access."
  value       = module.davinci.resolve_admin_username
}

output "resolve_admin_password" {
  description = "Resolve admin password for RDP access."
  value       = module.davinci.resolve_admin_password
  sensitive   = true
}

output "resolve_dns_address" {
  description = "URL for Davinci Resolve RDP service"
  value       = module.davinci.resolve_dns_address
}

output "gclb_dns_addresses" {
  description = "The DNS addresses for the services behind the Global Load Balancer."
  value       = module.gclb.endpoint_dns_addresses
}

output "gclb_dns_address_nea" {
  description = "The DNS address for the 'nea' service."
  value       = module.gclb.endpoint_dns_addresses["nea"]
}

output "gclb_dns_address_cdn" {
  description = "The DNS address for the 'cdn' service."
  value       = module.gclb.endpoint_dns_addresses["cdn"]
}

output "gclb_dns_address_titan" {
  description = "The DNS address for the 'titan' service."
  value       = module.gclb.endpoint_dns_addresses["titan"]
}

output "gclb_dns_address_darwin" {
  description = "The DNS address for the 'darwin' service."
  value       = module.gclb.endpoint_dns_addresses["darwin"]
}

output "gclb_dns_address_gemini" {
  description = "The DNS address for the 'gemini' service."
  value       = module.gclb.endpoint_dns_addresses["gemini"]
}

output "gclb_dns_address_norsk" {
  description = "The DNS address for the 'norsk' service."
  value       = module.gclb.endpoint_dns_addresses["norsk"]
}

