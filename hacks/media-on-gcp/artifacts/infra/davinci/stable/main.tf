module "compute" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "davinci-resolve-mig"
  base_instance_name   = "davinci-resolve"
  target_size          = 1
  machine_type         = "g2-standard-8"
  source_image         = "projects/media-on-gcp-storage/global/images/davinci-resolve-machine"
  boot_disk_type       = "pd-balanced"
  boot_disk_size       = 600

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = [google_compute_address.resolve.address]

  distribution_policy_zones = ["europe-west4-c", "europe-west4-a"]

  accelerator_type  = "nvidia-l4-vws"
  accelerator_count = 1

  metadata = {
    enable-oslogin  = "true"
    windows-startup-script-ps1 = <<-EOF
      & "C:\Program Files\Teradici\pcoip-activation.ps1"
    EOF
  }
}

resource "google_compute_address" "resolve" {
  project = var.project_id
  region  = var.region
  name    = "resolve-vm-ip-address"
}

# Cloud Endpoints Services (Dynamic)
resource "google_endpoints_service" "dynamic" {
  project        = var.project_id
  service_name   = "resolve.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<-EOF
    swagger: "2.0"
    info:
      title: "API for davinci resolve"
      description: "A simple API for the davinci resolve service"
      version: "1.0.0"
    host: "resolve.endpoints.${var.project_id}.cloud.goog"
    x-google-endpoints:
    - name: "resolve.endpoints.${var.project_id}.cloud.goog"
      target: "${google_compute_address.resolve.address}"
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

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*"
  upper            = true
  lower            = true
  numeric          = true
}
