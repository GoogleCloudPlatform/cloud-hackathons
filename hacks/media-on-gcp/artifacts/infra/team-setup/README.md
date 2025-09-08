# Team Setup Terraform Module

This module creates a set of Google Cloud Storage buckets for each team specified.

## Usage

```hcl
module "team_setup" {
  source      = "./infra/team-setup"
  project_id  = var.gcp_project_id
  teams       = ["alpha", "beta", "gamma"]
  bucket_prefix = "my-team-buckets"
}
```
