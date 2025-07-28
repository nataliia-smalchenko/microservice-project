# Django Microservice Project: Full CI/CD with Jenkins, Helm, Terraform, and Argo CD

## Overview
This project demonstrates a complete CI/CD pipeline for a Django application using Jenkins, Helm, Terraform, and Argo CD, with comprehensive monitoring using Prometheus and Grafana. The pipeline is designed to:

1. Automatically build a Docker image for the Django application.
2. Publish the image to Amazon ECR.
3. Update the Helm chart in the repository with the correct image tag.
4. Synchronize the application in the Kubernetes cluster via Argo CD, which tracks changes from Git.
5. Monitor the entire infrastructure and applications using Prometheus and Grafana.

### Key Components:
- **Jenkins**: CI/CD automation and pipeline execution
- **Argo CD**: GitOps continuous deployment
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Metrics visualization and dashboards
- **Amazon EKS**: Managed Kubernetes cluster
- **Amazon ECR**: Container registry
- **Terraform**: Infrastructure as Code

The Jenkins pipeline logic is defined in the [Jenkinsfile](https://github.com/nataliia-smalchenko/django-app/blob/main/Jenkinsfile) in the `django-app` repository.

---

## Project Structure
```
lesson-7/
│
├── main.tf                  # Main Terraform file for module integration
├── backend.tf               # Backend config for state (S3 + DynamoDB)
├── outputs.tf               # Global resource outputs
│
├── modules/                 # All infrastructure modules
│   ├── s3-backend/          # S3 & DynamoDB backend module
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/                 # VPC module
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/                 # ECR module
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/                 # Kubernetes cluster module
│   │   ├── eks.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── jenkins/             # Jenkins Helm module
│   │   ├── jenkins.tf
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   ├── values.yaml
│   │   └── outputs.tf
│   └── argo-cd/             # Argo CD Helm module
│       ├── argo-cd.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── values.yaml
│       ├── outputs.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml          # List of applications, repositories
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap with environment variables
```

## Infrastructure Components

The project deploys the following infrastructure components:

- **VPC with public/private subnets** across 3 availability zones
- **EKS cluster** with managed node groups
- **ECR repositories** for container images
- **RDS Aurora PostgreSQL** for database
- **S3 + DynamoDB** for Terraform state management
- **Jenkins** for CI/CD pipelines
- **Argo CD** for GitOps deployment
- **Prometheus** for metrics collection
- **Grafana** for monitoring dashboards

---

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

### Jenkins Module

Automates the installation and configuration of Jenkins using Helm and Terraform.

**Features:**

- Installs Jenkins via Helm chart
- Configures Jenkins to run on Kubernetes with dynamic agents
- Integrates with Kaniko for Docker builds and Git for SCM
- Manages credentials and resource settings via values.yaml
- Outputs Jenkins admin password and service URL

**Usage:**

```hcl
module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.eks_cluster_name
  kubeconfig   = "~/.kube/config"
  providers = {
    helm = helm
  }
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}
```

### Argo CD Module

Automates the installation and configuration of Argo CD using Helm and Terraform.

**Features:**

- Installs Argo CD via Helm chart
- Manages Argo CD Applications and Repositories via subcharts or Kubernetes manifests
- Enables GitOps deployment and automatic synchronization of applications
- Supports custom values.yaml for advanced configuration
- Outputs Argo CD admin password and service URL

**Usage:**

```hcl
module "argo_cd" {
  source        = "./modules/argo-cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
}
```

---

## Universal RDS Module

### Functionality Description

The `rds` module allows you to create either an Aurora Cluster or a standard RDS instance based on the `use_aurora` variable. It automatically creates:
- A DB Subnet Group (for private or public subnets)
- A Security Group with port 5432 open (can be changed)
- A Parameter Group for the selected DB type (RDS/Aurora)

The module supports multiple use cases and works with minimal variable changes.

### Usage Example
```hcl
module "rds" {
  source                = "./modules/rds"
  name                  = "myapp-db"
  db_name               = "myapp"
  username              = "postgres"
  password              = "<your_password>"
  vpc_id                = module.vpc.vpc_id
  subnet_private_ids    = module.vpc.private_subnets
  subnet_public_ids     = module.vpc.public_subnets
  use_aurora            = true # or false for standard RDS
  engine                = "postgres"
  engine_version        = "14.7"
  engine_cluster        = "aurora-postgresql"
  engine_version_cluster= "15.3"
  instance_class        = "db.t3.medium"
  multi_az              = false
  publicly_accessible   = false
  aurora_replica_count  = 1
  aurora_instance_count = 2
  parameters = {
    max_connections = "100"
    log_statement   = "all"
    work_mem        = "4096"
  }
  tags = {
    Environment = "dev"
  }
}
```

### Outputs
- `rds_endpoint` — endpoint for DB connection
- `rds_port` — port
- `rds_db_name` — database name
- `rds_username` — user
- `security_group_id` — SG for access
- `subnet_group_name` — DB subnet group
- Aurora-specific: `aurora_reader_endpoint`, `aurora_writer_instance_id`, `aurora_reader_instance_ids`

### Variable Descriptions
- `use_aurora` (bool): if true — creates Aurora Cluster, if false — standard RDS instance
- `name` (string): resource name
- `db_name` (string): database name
- `username` (string): master user
- `password` (string): password
- `vpc_id` (string): VPC ID
- `subnet_private_ids` (list): private subnets
- `subnet_public_ids` (list): public subnets
- `engine` (string): DB type for RDS (e.g., "postgres")
- `engine_version` (string): version for RDS
- `engine_cluster` (string): type for Aurora (e.g., "aurora-postgresql")
- `engine_version_cluster` (string): version for Aurora
- `instance_class` (string): instance class (e.g., "db.t3.micro")
- `multi_az` (bool): whether to use Multi-AZ
- `publicly_accessible` (bool): whether DB is publicly accessible
- `parameters` (map): additional parameters for parameter group
- `aurora_replica_count` (number): number of Aurora replicas
- `aurora_instance_count` (number): number of Aurora instances (primary + replicas)
- `backup_retention_period` (string): backup retention period
- `tags` (map): tags
- `parameter_group_family_aurora` (string): parameter group family for Aurora
- `parameter_group_family_rds` (string): parameter group family for RDS

### How to change DB type, engine, instance class
- For Aurora: `use_aurora = true`, `engine_cluster = "aurora-postgresql"`, `engine_version_cluster = "15.3"`
- For standard RDS: `use_aurora = false`, `engine = "postgres"`, `engine_version = "14.7"`
- Instance class: change `instance_class` (e.g., "db.t3.medium")
- Multi-AZ: `multi_az = true`

---

## CI/CD Pipeline Description

### Jenkins + Helm + Terraform
- Jenkins is installed via Helm and automated with Terraform.
- Jenkins runs on Kubernetes agents (Kaniko for Docker builds, Git for repo operations).
- The pipeline (see [Jenkinsfile](https://github.com/nataliia-smalchenko/django-app/blob/main/Jenkinsfile)):
  - Builds a Docker image from the Django app's Dockerfile.
  - Pushes the image to Amazon ECR.
  - Updates the image tag in the `values.yaml` of the Helm chart.
  - Pushes the updated chart to the main branch.

### Argo CD + Helm + Terraform
- Argo CD is installed via Helm using Terraform.
- Argo CD Application is configured to watch for changes in the Helm chart repository.
- When the chart is updated, Argo CD automatically synchronizes the application in the Kubernetes cluster.

---

## How to Use

### 1. Apply Terraform
```
cd lesson-7
terraform init
terraform apply
```
This will provision all infrastructure, including ECR, VPC, EKS, Jenkins, and Argo CD.

### 2. Check Jenkins Job
- Access Jenkins via the LoadBalancer URL (output from Terraform or via `kubectl get svc -n jenkins`).
- Run the seed job and then run the pipeline job goit-django-docker.
- The pipeline will build, push, and update the Helm chart automatically.

### 3. Verify in Argo CD
- Access Argo CD via the LoadBalancer URL (output from Terraform or via `kubectl get svc -n argocd`).
- Login as `admin` (initial password: see Terraform output or run `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`).
- You will see the application status, sync state, and deployment history.

---

## Monitoring with Prometheus and Grafana

This project includes monitoring infrastructure using Prometheus for metrics collection and Grafana for visualization.

### Prometheus
Prometheus is deployed in the `monitoring` namespace and automatically discovers and scrapes metrics from:
- Kubernetes cluster components
- Node metrics
- Pod and container metrics
- Application metrics (if exposed)

**Features:**
- Automatic service discovery
- Built-in alerting rules
- Persistent storage for metrics
- Web UI for querying metrics

### Grafana
Grafana provides rich dashboards and visualization for the metrics collected by Prometheus.

**Features:**
- Pre-configured Prometheus data source
- Built-in Kubernetes dashboards
- Custom dashboard creation
- Alerting and notification support

### Accessing Monitoring Services

**Prometheus:**
```bash
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
```
Then open: http://localhost:9090

**Grafana:**
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
Then open: http://localhost:3000

Default Grafana credentials:
- Username: `admin`
- Password: Get from secret: `kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d`

---

## Testing and Verification Commands

### 1. Infrastructure Deployment
Deploy the infrastructure:
```bash
terraform init
terraform apply
```

### 2. Verify Resource Status
Check the status of all deployed resources:
```bash
# Jenkins resources
kubectl get all -n jenkins

# Argo CD resources
kubectl get all -n argocd

# Monitoring resources (Prometheus & Grafana)
kubectl get all -n monitoring

# Check all namespaces
kubectl get namespaces

# Check cluster nodes
kubectl get nodes
```

### 3. Access Services via Port-Forward

**Jenkins:**
```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```
Access: http://localhost:8080

**Argo CD:**
```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```
Access: https://localhost:8081

**Grafana:**
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
Access: http://localhost:3000

**Prometheus:**
```bash
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
```
Access: http://localhost:9090

### 4. Get Service Credentials

**Jenkins Admin Password:**
```bash
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d
```

**Argo CD Admin Password:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Grafana Admin Password:**
```bash
kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
```

### 5. Monitor Application Deployment

**Watch pods in real-time:**
```bash
kubectl get pods -A -w
```

**Check application logs:**
```bash
# Django app logs
kubectl logs -f deployment/django-app-django -n default

# Jenkins logs
kubectl logs -f deployment/jenkins -n jenkins

# Argo CD logs
kubectl logs -f deployment/argocd-server -n argocd
```

### 6. Verify Monitoring Stack

**Check Prometheus targets:**
- Go to Prometheus UI → Status → Targets
- Verify all targets are "UP"

**Check Grafana dashboards:**
- Login to Grafana
- Navigate to Dashboards
- Import Kubernetes dashboards from Grafana.com (IDs: 315, 1860, 6417)

**Test metrics collection:**
```bash
# Check if Prometheus is scraping metrics
curl http://localhost:9090/api/v1/query?query=up

# Check Grafana API
curl -u admin:$(kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d) http://localhost:3000/api/health
```

---

## Notes
- The Jenkinsfile for the pipeline is located in the [django-app repository](https://github.com/nataliia-smalchenko/django-app).
- All infrastructure is fully automated and reproducible via Terraform.
- The pipeline is designed for educational/demo purposes and can be extended for production use.

---

## How to access the Django app via port-forward

If the service is of type ClusterIP or LoadBalancer without an external IP, you can access the app locally via port-forward:

```sh
kubectl port-forward svc/django-app-django 8000:80 -n default
```

Then open in your browser:
```
http://localhost:8000/
```

---
