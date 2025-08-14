output "locust_address" {
  value = google_cloud_run_v2_service.locust.urls[0]
}

output "movie_guru_address" {
  value = google_cloud_run_v2_service.app.urls[0]
}
