module "vizrt_vectar" {
  source = "../../gce-mig/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "vizrt-vectar-mig"
  base_instance_name   = "vizrt-vectar"
  target_size          = 1
  machine_type         = "g2-standard-8"
  source_image         = "projects/qwiklabs-resources/global/images/vizrt-vectar-machine"
  boot_disk_type       = "pd-balanced"
  boot_disk_size       = 50

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = var.external_ips

  accelerator_type  = "nvidia-l4-vws"
  accelerator_count = 1

}

resource "google_compute_firewall" "fwr_vizrt_vectar" {
  name    = "fwr-allow-vizrt-vectar"
  network = element(var.networks, 0)

  allow {
    ports    = ["4172", "8444", "22350"]
    protocol = "tcp"
  }

  allow {
    ports    = ["4173", "8443", "22350"]
    protocol = "udp"
  }

  source_ranges = ["0.0.0.0/0"]
}