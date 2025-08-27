# Google Cloud Engine Managed Instance Group Terraform Module

This Terraform module creates a Google Cloud Engine (GCE) instance template and a regional managed instance group (MIG).

## Usage

```hcl
module "gce_mig" {
  source = "./basics/compute/stable"

  project_id           = "your-gcp-project-id"
  region               = "your-gcp-region"
  instance_group_name  = "my-mig"
  base_instance_name   = "my-instance"
  target_size          = 2
  source_image         = "projects/debian-cloud/global/images/family/debian-11"
  machine_type         = "e2-medium"
}
```