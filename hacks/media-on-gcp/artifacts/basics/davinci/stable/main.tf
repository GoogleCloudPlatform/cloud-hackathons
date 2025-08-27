module "davinci" {
  source = "../../gce-mig/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "davinci-resolve-mig"
  base_instance_name   = "davinci-resolve"
  target_size          = 1
  machine_type         = "g2-standard-8"
  source_image         = "projects/media-on-gcp-storage/global/images/davinci-remote-edit-machine"
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
