# Provisioning resources with Terraform

## Introduction

Welcome to the coach's guide for the Infrastructure as Code with Terraform. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Bootstrapping
- Challenge 2: Your very first provisioning
- Challenge 3: Open the gates!
- Challenge 4: Roll out an HTTP server on a VM
- Challenge 5: Automation


## Challenge 1: Bootstrapping

### Notes & Guidance

Creating the bucket to hold the Terraform state should be trivial, just make sure that _Object versioning_ is turned on. You could use the console or the following command line:

```shell
REGION=...
PROJECT_ID=...
BUCKET="gs://$PROJECT_ID-tf"
gsutil mb -l $REGION $BUCKET
gsutil versioning set on $BUCKET
```

Terraform backend config should look like this:

```terraform
terraform {
  backend "gcs" {
    bucket  = "..."  # can't use variables here, has to be hardcoded
    prefix  = "env/dev"
  }
}
```

Git requires users to set up their identity before anything can be committed. So users need do the following:

```shell
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"
```

If users miss this step, they'll be prompted the first time they want to do a commit and they can complete it by that time.

After that a local git repository in the root of the extracted archive needs to be created, cd to `gcp-iac-with-tf-template` (if the archive is downloaded as a zip file and extracted with default options) and run the following commands.

```shell
git init .
git add .
git commit -m "initial commit"
```

> **Warning**  
> If participants initialize the repo in their home directory instead of in the root of the extracted archive, that will cause problems in the next challenges.

If users ignored the instructions and cloned the repo, they can skip the local Git repo creation, but they'll have to do the following steps.

In order to add the SSH key see the vertical ellipsis on the right side of the top bar for Cloud Source Repositories.

The following command will generate an SSH key pair and show the contents of the public key to be copied to the Cloud Source Repositories.

```shell
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub
```

Then users need to add the Cloud Source Repository as a remote. This is all documented on the landing page of the newly created repository if users choose the _Push code from a local Git repository_ option.

```shell
git remote add google ssh://STUDENT...@ORGANIZATION...@source.developers.google.com:2022/p/PROJECT/r/iac-with-tf
```

And finally push the changes.

```shell
git push --all google
```

## Challenge 2: Your very first provisioning

### Notes & Guidance

The required configuration looks like this:

```terraform
resource "google_compute_network" "sample" {
  name                    = "vpc-sample"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "sub-sample"
  network       = google_compute_network.sample.self_link
  ip_cidr_range = var.cidr_block
}
```

It will require the following provider configuration:

```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"  # or anything more recent
    }
  }
}

# this block sets some of the variables for the resources
provider "google" {
  project = var.gcp_project
  region  = "us-central1" 
  zone    = "us-central1-a" 

}
```

And a `variables.tf` file with the following content:

```terraform
variable "gcp_project" {
  type        = string
  description = "The GCP project ID to create resources in."
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block definition in the format 0.0.0.0/0"
}
```

## Challenge 3: Open the gates!

### Notes & Guidance

Use the following snippet for configuring the firewall:

```terraform
resource "google_compute_firewall" "allow_http" {
  name        = "fwr-ingress-allow-http"
  network     = google_compute_network.sample.name

  allow {
    protocol  = "tcp"
    ports     = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}
```

## Challenge 4: Roll out an HTTP server on a VM

### Notes & Guidance

Creating the VM and installing the nginx engine can be done as follows:

```terraform
resource "google_compute_address" "web_vm_eip" {
  name = "eip-web-vm"

  depends_on = [
    google_compute_network.sample
  ]
}

resource "google_compute_instance" "web_vm" {
  name         = "gce-lnx-web-001"
  machine_type = "e2-standard-2"
  tags         = ["http"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # Ubuntu is fine too
    }
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm        = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
      nat_ip = google_compute_address.web_vm_eip.address
    }
  }

  metadata_startup_script = "apt-get update && apt-get install -y nginx"
}

output "vm_db_ip" {
  value = google_compute_address.web_vm_eip.address
}
```

## Challenge 4: Automation

### Notes & Guidance

This should be trivial, make sure that the path to the `cloudbuild.yaml` is correct and the variables are set properly. Also important to know is the service account that's used. The service account used (either the Cloud Build service agent, Compute Engine Default or a custom one) must have sufficient priviliges to create resources. 

In addition, if any service account other than Cloud Buid service agent is used, the logging configuration must be set, for example:

```yaml
options:
  logging: CLOUD_LOGGING_ONLY
```