# Terraform Deployment for Techex Core, Edge, and Darwin

This Terraform configuration automates the provisioning of three Google Cloud Platform (GCP) Compute Engine instances, each dedicated to a specific Techex product: `tx-core`, `tx-edge`, and `tx-darwin`.

The script ensures that all instances are configured with the necessary machine types, custom images, startup scripts, and security settings to run their respective Techex software components.

## Products Deployed

This configuration will create virtual machines ready for the installation of the following Techex products:

* **Techex Core (`tx-core`)**: Deploys the core media gateway. This component is central to processing, managing, and routing broadcast-quality video streams over IP networks, handling standards like SMPTE ST 2110 and ST 2022.

* **Techex Edge (`tx-edge`)**: Deploys the edge gateway. This component is designed for secure, reliable contribution and distribution of video feeds from remote locations or at the network edge, ensuring streams are correctly ingested into and delivered from the core network.

* **Techex Darwin (`tx-darwin`)**: Deploys the Darwin Software-Defined Video Platform. Darwin provides the orchestration, monitoring, and management layer for the entire video workflow, allowing operators to control and visualize their IP and cloud broadcast infrastructure.

## Prerequisites

Before applying this configuration, ensure you have the following:

1.  **Terraform**: Terraform v1.0 or later installed on your local machine.
2.  **Google Cloud SDK (`gcloud`)**: The `gcloud` CLI installed and authenticated.
3.  **GCP Project**: A Google Cloud project with the Compute Engine API enabled.
4.  **Permissions**: Your GCP user or service account must have the necessary IAM permissions to create Compute Engine instances, manage service accounts, and access the custom images.
5.  **Custom Images**: The custom images `tx-core-custom-image`, `tx-edge-custom-image`, and `tx-darwin-custom-image` must exist in the `ghack-student` project.

## Usage

1.  **Clone the Repository**:
    Clone the repository containing the `.tf` file to your local machine.

2.  **Initialize Terraform**:
    Navigate to the directory and run the `init` command to initialize the Terraform providers.
    ```bash
    terraform init
    ```

3.  **Plan the Deployment**:
    Run the `plan` command to see what resources will be created. This is a dry run and will not make any changes.
    ```bash
    terraform plan
    ```

4.  **Apply the Configuration**:
    Run the `apply` command to provision the resources in Google Cloud. You will be prompted to confirm the action.
    ```bash
    terraform apply
    ```
    Type `yes` when prompted to proceed.

5.  **Destroy Resources**:
    When you no longer need the instances, you can destroy all the created resources to avoid ongoing charges.
    ```bash
    terraform destroy
    ```

## Configuration Details

* **Project**: `ghack-student`
* **Region**: `europe-west2`
* **Zone**: `europe-west2-b`
* **Instance Type**: `c2-standard-8` for all instances.
* **Security**: Shielded VM features (Secure Boot, vTPM, and Integrity Monitoring) are enabled on all instances.
