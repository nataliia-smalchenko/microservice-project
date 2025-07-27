# Terraform Project for AWS Infrastructure

This project uses Terraform to deploy a scalable and secure AWS infrastructure following Infrastructure as Code (IaC) principles. It includes state management, network configuration, container image storage, and Kubernetes cluster deployment for repeatable and reliable deployments.

## Project Structure

The project is organized into several directories within the root directory (`lesson-7/`):

### Root Directory Structure

```
lesson-7/
├── main.tf          # Main configuration file orchestrating all modules
├── backend.tf       # Remote S3 backend configuration for state storage
├── outputs.tf       # Critical output values from deployed resources
├── modules/         # Reusable Terraform modules
│   ├── s3-backend/  # S3 backend and DynamoDB state locking
│   ├── vpc/         # Virtual Private Cloud configuration
│   ├── ecr/         # Elastic Container Registry setup
│   └── eks/         # Elastic Kubernetes Service cluster
└── charts/          # Helm charts for Kubernetes applications
```

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 1.0+)
- Docker installed
- kubectl installed
- Helm installed

### Initialization and Deployment Commands

```bash
# 1. Navigate to project directory
cd lesson-7

# 2. Initialize Terraform working directory
terraform init

# 3. Preview infrastructure changes
terraform plan

# 4. Deploy infrastructure
terraform apply

# 5. Destroy infrastructure when no longer needed
terraform destroy
```

## Deployment Workflow

### Initial Setup Process

1. **Prepare Backend Configuration**

   - Temporarily comment out all code in `backend.tf`
   - Run `terraform init` to initialize the working directory

2. **First Deployment**

   - Run `terraform plan` to preview resources
   - Execute `terraform apply` to create initial infrastructure

3. **Configure Remote State**

   - Uncomment all code in `backend.tf`
   - Run `terraform init -reconfigure` to migrate state to S3
   - Execute `terraform apply` again to ensure consistency

4. **Cleanup**
   - Use `terraform destroy` to remove all resources when done

## Module Documentation

### S3 Backend Module

Creates secure and collaborative Terraform state management.

**Features:**

- S3 bucket for state file storage
- DynamoDB table for state locking
- Versioning and encryption enabled
- Multi-user collaboration support

**Benefits:**

- Prevents state corruption through locking
- Enables team collaboration
- Provides state history and rollback capabilities

### VPC Module

Establishes a secure and isolated network environment.

**Features:**

- Custom VPC with specified CIDR block
- Public and private subnet configuration
- NAT Gateway for outbound internet access
- Internet Gateway for public access
- Route tables and security groups

**Usage:**

```hcl
module "vpc" {
  source = "./modules/vpc"
  # Configuration parameters defined in module
}
```

### ECR Module

Manages Docker container image storage and security.

**Features:**

- ECR repository with specified naming
- Image scanning on push for vulnerability detection
- Repository access policies
- Image lifecycle management
- Cross-region replication support

**Usage:**

```hcl
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}
```

### EKS Module

Deploys a managed Kubernetes cluster with worker nodes.

**Features:**

- EKS cluster with specified configuration
- Auto-scaling worker node groups
- IAM roles and policies for secure access
- Multiple instance types support
- Integration with VPC subnets

**Usage:**

```hcl
module "eks" {
  source        = "./modules/eks"
  cluster_name  = "eks-cluster-demo"
  subnet_ids    = module.vpc.public_subnets
  instance_type = "t3.medium"
  desired_size  = 3
  max_size      = 4
  min_size      = 2
}
```

## Step-by-Step Deployment Guide

### 1. Create Kubernetes Cluster

Deploy a Kubernetes cluster in the existing VPC using Terraform.

**Steps:**

1. Navigate to project directory:

   ```bash
   cd lesson-7
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review deployment plan:

   ```bash
   terraform plan
   ```

4. Apply configuration:
   ```bash
   terraform apply
   ```

**Configure kubectl access:**

```bash
# Get cluster configuration
aws eks update-kubeconfig --region eu-central-1 --name eks-cluster-demo

# Verify connection
kubectl get nodes
```

### 2. Configure ECR Repository

Set up Amazon Elastic Container Registry using Terraform.

**ECR Setup:**

1. ECR repository is created automatically through Terraform module
2. Authenticate Docker with ECR:
   ```bash
   aws ecr get-login-password --region eu-central-1 | \
   docker login --username AWS --password-stdin \
   658301803468.dkr.ecr.eu-central-1.amazonaws.com
   ```

**Upload Django Docker Image:**

```bash
# Navigate to Django project directory
cd lesson-4

# Build and push multi-platform image
docker-compose up
docker tag yarokrilka/microservice-project:latest 658301803468.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest
docker push 658301803468.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest
```

### 3. Deploy Helm Chart

Create and deploy a comprehensive Helm chart with the following components:

#### Deployment Configuration

- Django image from ECR
- ConfigMap integration via `envFrom`
- Resource limits and requests
- Health checks and probes

#### Service Configuration

- LoadBalancer type for external access
- Port mapping and target ports
- Service annotations for AWS Load Balancer

#### Horizontal Pod Autoscaler (HPA)

- Scaling from 2 to 6 pods
- CPU utilization threshold > 70%
- Memory-based scaling metrics

#### ConfigMap

- Environment variables (migrated from lesson 4)
- Application configuration
- Database connection strings

#### Values Configuration

- Image repository and tag parameters
- Service configuration options
- Autoscaler thresholds
- Resource specifications

**Helm Chart Structure:**

```
charts/django-app/
├── Chart.yaml              # Chart metadata and version
├── values.yaml             # Default configuration values
└── templates/
    ├── deployment.yaml     # Django deployment with ConfigMap
    ├── service.yaml        # LoadBalancer service
    ├── hpa.yaml           # Horizontal Pod Autoscaler
    ├── configmap.yaml     # Environment variables
    └── NOTES.txt          # Post-installation notes
```

**Deploy Helm Chart:**

```bash
# Navigate to chart directory
cd lesson-7/charts/django-app

# Install the chart
helm install my-django-app .

# Verify deployment
kubectl get pods
kubectl get services
kubectl get hpa

# Check application logs
kubectl logs -l app=django-app
```

## Backend Configuration

The `backend.tf` file configures Terraform to use S3 for remote state storage:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"  # Replace with your bucket name
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Backend Benefits:**

- Shared state for team collaboration
- State locking prevents concurrent modifications
- Encryption at rest for security
- Versioning for state history

## Monitoring and Troubleshooting

### Essential kubectl Commands

```bash
# Cluster and node information
kubectl cluster-info
kubectl get nodes -o wide

# Pod management
kubectl get pods --all-namespaces
kubectl describe pod <pod-name>
kubectl logs <pod-name> --follow

# Service inspection
kubectl get services
kubectl describe service <service-name>

# ConfigMap verification
kubectl get configmaps
kubectl describe configmap <configmap-name>

# HPA monitoring
kubectl get hpa
kubectl describe hpa <hpa-name>

# Resource usage
kubectl top nodes
kubectl top pods
```

### Helm Management Commands

```bash
# List installed releases
helm list

# Upgrade release
helm upgrade my-django-app .

# Rollback to previous version
helm rollback my-django-app 1

# Uninstall release
helm uninstall my-django-app

# Debug chart templates
helm template my-django-app . --debug
```

### AWS-Specific Troubleshooting

```bash
# Check EKS cluster status
aws eks describe-cluster --name eks-cluster-demo --region eu-central-1

# List ECR repositories
aws ecr describe-repositories --region eu-central-1

# Check Load Balancer status
aws elbv2 describe-load-balancers --region eu-central-1

# View CloudWatch logs
aws logs describe-log-groups --region eu-central-1
```
