output "project_id" {
  value = var.gcp_project_id
}

output "gcp_zone" {
  value = var.gcp_zone
}

resource "random_shuffle" "shop_name" {
  input        = ["Cymbal Sales Data", "Cymbal Data"]
  result_count = 1
}
output "shop_name" {
  value       = random_shuffle.shop_name.result[0]
  description = "Shop Name for Google Drive"
}

resource "random_shuffle" "cal_name" {
  input        = ["Sales Data Review Meeting", "Review Meeting of Sales Data"]
  result_count = 1
}
output "cal_name" {
  value       = random_shuffle.cal_name.result[0]
  description = "Event Name in google calender"
}

resource "random_shuffle" "drive_name" {
  input        = ["google-drive-cymbal", "cymbal-google-drive"]
  result_count = 1
}
output "drive_name" {
  value       = random_shuffle.drive_name.result[0]
  description = "Google Drive Data Store Name"
}

resource "random_shuffle" "calender_name" {
  input        = ["cymbal-google-calendar", "google-calendar-cymbal"]
  result_count = 1
}
output "calender_name" {
  value       = random_shuffle.calender_name.result[0]
  description = "Google Calender Data Store Name"
}

resource "random_shuffle" "agentspace_app" {
  input        = ["cymbal-agentspace-app", "agentspace-app-cymbal"]
  result_count = 1
}
output "agentspace_app" {
  value       = random_shuffle.agentspace_app.result[0]
  description = "Agentspace App Name"
}

resource "random_shuffle" "company_name" {
  input        = ["Cymbal Shops"]
  result_count = 1
}
output "company_name" {
  value       = random_shuffle.company_name.result[0]
  description = "Company Name"
}

resource "random_shuffle" "auth_app_name" {
  input        = ["Cymbal Shops Agentspace"]
  result_count = 1
}
output "auth_app_name" {
  value       = random_shuffle.auth_app_name.result[0]
  description = "Google Auth App Name"
}

resource "random_shuffle" "agent_client" {
  input        = ["Cymbal Agentspace Client", "Agentspace Client for Cymbal"]
  result_count = 1
}
output "agent_client" {
  value       = random_shuffle.agent_client.result[0]
  description = "Google Auth App Name"
}

resource "random_shuffle" "gmail_action" {
  input        = ["Cymbal gmail action", "Cymbal action"]
  result_count = 1
}
output "gmail_action" {
  value       = random_shuffle.gmail_action.result[0]
  description = "Gmail Action Name"
}