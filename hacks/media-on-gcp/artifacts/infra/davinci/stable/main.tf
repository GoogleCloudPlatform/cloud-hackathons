module "davinci" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "davinci-resolve-mig"
  base_instance_name   = "davinci-resolve"
  target_size          = 1
  machine_type         = "g2-standard-8"
  source_image         = "projects/qwiklabs-resources/global/images/davinci-resolve-machine"
  boot_disk_type       = "pd-balanced"
  boot_disk_size       = 600

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = var.external_ips

  accelerator_type  = "nvidia-l4-vws"
  accelerator_count = 1

  metadata = {
    enable-oslogin  = "true"
  }
}

resource "google_compute_global_address" "default" {
  project = var.project_id
  name    = "davinci-lb-ip-address"
}

# Cloud Endpoints Services (Dynamic)
resource "google_endpoints_service" "dynamic" {
  project        = var.project_id
  service_name   = "davinci.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<-EOF
    swagger: "2.0"
    info:
      title: "API for davinci"
      description: "A simple API for the davinci service"
      version: "1.0.0"
    host: "davinci.endpoints.${var.project_id}.cloud.goog"
    x-google-endpoints:
    - name: "davinci.endpoints.${var.project_id}.cloud.goog"
      target: "${google_compute_global_address.default.address}"
    schemes:
      - "https"
    paths: {}
  EOF

  # NOTE:
  # Prevent deletion on destroy.
  # Deleteing this resource will not allow you to reuse again within 30 days. Can undelete service
  # Following, https://cloud.google.com/service-infrastructure/docs/manage-services#undeleting_a_service
  # lifecycle {
  #   prevent_destroy = true
  # }
}
