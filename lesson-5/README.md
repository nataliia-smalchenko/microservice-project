# Terraform Project for AWS Infrastructure

This project uses Terraform to deploy a scalable and secure AWS infrastructure. It covers state management, network configuration, and container image storage, adhering to "infrastructure as code" principles for repeatable deployments.

## Project Structure

The project is organized into the several directories. Root Directory (`lesson-5/`) contains:

- `main.tf`: the main configuration file that connects and orchestrates all modules.
- `backend.tf`: remote S3 backend configuration for secure and versioned Terraform state storage.
- `outputs.tf`: gathers all critical output values from the deployed resources.
- `modules/`: contains reusable Terraform modules (in separate folders) for each infrastructure component (`s3-backend`, `vpc`, `ecr`).

## Initialization and Deployment

To initialize and deploy the infrastructure, use the following commands:

1. `terraform init`: initializes the Terraform working directory and downloads the necessary providers
2. `terraform plan`: generates a plan for the infrastructure deployment
3. `terraform apply`: applies the plan and creates the infrastructure
4. `terraform destroy`: destroys the infrastructure and removes all resources

## Usage

To use this project, simply clone the repository and navigate to the lesson-5 directory: `cd lesson-5`
Temporarily comment out all code in the `backend.tf` file. Then run the `terraform init` command to initialize the Terraform working directory. After that, you can use `terraform plan` to preview the resources that will be created, and use the `terraform apply` command to deploy the infrastructure. Next, uncomment all code in the `backend.tf` file. Run the `terraform init -reconfigure` command to apply the new configuration and use the created bucket to store the Terraform state file. Then run the `terraform apply` command again to redeploy the infrastructure.

Finally, you can use `terraform destroy` to remove all resources.

## Module Descriptions

### s3-backend

The `s3-backend` module creates an S3 bucket to store the Terraform state file. This allows multiple users to collaborate on the infrastructure deployment and ensures that the state file is stored securely. This module also uses `DynamoDB` for state locking.

### vpc

The `vpc` module creates a Virtual Private Cloud (VPC) with a specified CIDR block, subnet configuration and NAT. This provides a secure and isolated network environment for the infrastructure.

### ecr

The `ecr` module creates an Elastic Container Registry (ECR) repository to store Docker images. This allows for secure and efficient deployment of containerized applications.

## Terraform Backend Configuration

The `backend.tf` file in the root directory configures Terraform to use S3 as its backend:

```
terraform {
    backend "s3" {
        bucket = "your_bucket_name" # Replace with your S3 bucket name
        key = "lesson-5/terraform.tfstate"
        region = "eu-central-1"
        dynamodb_table = "terraform-locks"
        encrypt = true
    }
}
```
