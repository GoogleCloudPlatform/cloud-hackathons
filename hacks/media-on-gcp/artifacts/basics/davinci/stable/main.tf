module "davinci" {
  source = "../../gce-mig/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "davinci-resolve-mig"
  base_instance_name   = "davinci-resolve"
  target_size          = 1
  machine_type         = "g2-standard-8"
  source_image         = "projects/qwiklabs-resources/global/images/davinci-remote-edit-machine"
  boot_disk_type       = "pd-balanced"
  boot_disk_size       = 600

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = var.external_ips

  accelerator_type  = "nvidia-l4-vws"
  accelerator_count = 1

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
  }

  metadata = {
    enable-osconfig = "TRUE"
    enable-oslogin  = "true"
  }

  named_ports = [{
    name = "https"
    port = 443
  }]
}

module "ops_agent_policy" {
  source        = "github.com/terraform-google-modules/terraform-google-cloud-operations/modules/ops-agent-policy"
  project       = var.project_id
  zone          = var.zone
  assignment_id = "goog-ops-agent-v2-x86-template-1-5-0-europe-west4-b"
  agents_rule = {
    package_state = "installed"
    version       = "latest"
  }
  instance_filter = {
    all = false
    inclusion_labels = [{
      labels = {
        goog-ops-agent-policy = "v2-x86-template-1-5-0"
      }
    }]
  }
}