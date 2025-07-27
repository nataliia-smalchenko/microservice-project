# Terraform Project for AWS Infrastructure

This project uses Terraform to deploy a scalable and secure AWS infrastructure. It covers state management, network configuration, container image storage, and Kubernetes cluster deployment, adhering to "infrastructure as code" principles for repeatable deployments.

## Project Structure

The project is organized into the several directories. Root Directory (`lesson-7/`) contains:

- `main.tf`: the main configuration file that connects and orchestrates all modules.
- `backend.tf`: remote S3 backend configuration for secure and versioned Terraform state storage.
- `outputs.tf`: gathers all critical output values from the deployed resources.
- `modules/`: contains reusable Terraform modules (in separate folders) for each infrastructure component (`s3-backend`, `vpc`, `ecr`, `eks`).
- `charts/`: contains Helm charts for deploying applications to Kubernetes.

## Initialization and Deployment

To initialize and deploy the infrastructure, use the following commands:

1. `terraform init`: initializes the Terraform working directory and downloads the necessary providers
2. `terraform plan`: generates a plan for the infrastructure deployment
3. `terraform apply`: applies the plan and creates the infrastructure
4. `terraform destroy`: destroys the infrastructure and removes all resources

## Usage

To use this project, simply clone the repository and navigate to the lesson-7 directory: `cd lesson-7`
Temporarily comment out all code in the `backend.tf` file. Then run the `terraform init` command to initialize the Terraform working directory. After that, you can use `terraform plan` to preview the resources that will be created, and use the `terraform apply` command to deploy the infrastructure. Next, uncomment all code in the `backend.tf` file. Run the `terraform init -reconfigure` command to apply the new configuration and use the created bucket to store the Terraform state file. Then run the `terraform apply` command again to redeploy the infrastructure.

Finally, you can use `terraform destroy` to remove all resources.

## Module Descriptions

### s3-backend

The `s3-backend` module creates an S3 bucket to store the Terraform state file. This allows multiple users to collaborate on the infrastructure deployment and ensures that the state file is stored securely. This module also uses `DynamoDB` for state locking.

### vpc

The `vpc` module creates a Virtual Private Cloud (VPC) with a specified CIDR block, subnet configuration and NAT. This provides a secure and isolated network environment for the infrastructure.

### ecr

The `ecr` module creates an Elastic Container Registry (ECR) repository to store Docker images. This allows for secure and efficient deployment of containerized applications.

**Features:**

- Creates ECR repository with specified name
- Enables image scanning on push for security
- Configures repository policy for access control
- Supports image lifecycle management

**Usage:**

```hcl
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "lesson-5-ecr"
  scan_on_push = true
}
```

### eks

The `eks` module creates an Amazon Elastic Kubernetes Service (EKS) cluster with worker nodes. This provides a managed Kubernetes environment for running containerized applications.

**Features:**

- Creates EKS cluster with specified configuration
- Provisions worker nodes with auto-scaling capabilities
- Configures IAM roles and policies for cluster and node access
- Supports multiple instance types and node groups

**Usage:**

```hcl
module "eks" {
  source          = "./modules/eks"
  cluster_name    = "eks-cluster-demo"
  subnet_ids      = module.vpc.public_subnets
  instance_type   = "t3.medium"
  desired_size    = 3
  max_size        = 4
  min_size        = 2
}
```

## Step-by-Step Deployment Guide

### 1. Створіть кластер Kubernetes

Використовуючи Terraform, створіть кластер Kubernetes у вже існуючій мережі (VPC).

**Кроки:**

1. Перейдіть до директорії проекту: `cd lesson-7`
2. Ініціалізуйте Terraform: `terraform init`
3. Перегляньте план розгортання: `terraform plan`
4. Застосуйте конфігурацію: `terraform apply`

**Забезпечте доступ до кластера за допомогою kubectl:**

```bash
# Отримайте конфігурацію кластера
aws eks update-kubeconfig --region eu-central-1 --name eks-cluster-demo

# Перевірте підключення
kubectl get nodes
```

### 2. Налаштуйте ECR

Використовуючи Terraform, створіть репозиторій в Amazon Elastic Container Registry (ECR).

**Кроки:**

1. ECR репозиторій створюється автоматично через Terraform модуль
2. Отримайте URL репозиторію:

```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 658301803468.dkr.ecr.eu-central-1.amazonaws.com
```

**Завантажте Docker-образ Django до ECR:**

```bash
# Перейдіть до директорії з Django проектом
cd lesson-4/django

# Створіть multi-platform образ
docker buildx build --platform linux/amd64,linux/arm64 -t 658301803468.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest --push .
```

### 3. Створіть Helm чарт

У Helm-чарті має бути реалізовано:

#### Deployment

- З образом Django з ECR та підключенням ConfigMap (через envFrom)

#### Service

- Типу LoadBalancer для зовнішнього доступу

#### HPA (Horizontal Pod Autoscaler)

- Масштабування подів від 2 до 6 при навантаженні > 70%

#### ConfigMap

- Для змінних середовища (перенесених із теми 4)

#### values.yaml

- З параметрами образу, сервісу, конфігурації та autoscaler

**Розгортання Helm чарту:**

```bash
# Перейдіть до директорії з чартом
cd lesson-7/charts/django-app

# Встановіть чарт
helm install my-django-app .

# Перевірте статус
kubectl get pods
kubectl get services
kubectl get hpa
```

**Структура чарту:**

```
charts/django-app/
├── Chart.yaml          # Метадані чарту
├── values.yaml         # Параметри за замовчуванням
└── templates/
    ├── deployment.yaml # Deployment з ConfigMap
    ├── service.yaml    # Service типу LoadBalancer
    ├── hpa.yaml       # Horizontal Pod Autoscaler
    └── configmap.yaml # ConfigMap для змінних середовища
```

## Terraform Backend Configuration

The `backend.tf` file in the root directory configures Terraform to use S3 as its backend:

```
terraform {
    backend "s3" {
        bucket = "your_bucket_name" # Replace with your S3 bucket name
        key = "lesson-7/terraform.tfstate"
        region = "eu-central-1"
        dynamodb_table = "terraform-locks"
        encrypt = true
    }
}
```

## Troubleshooting Useful Commands

```bash
# Перевірка вузлів
kubectl get nodes

# Перевірка подів
kubectl get pods

# Перевірка сервісів
kubectl get services

# Логи поду
kubectl logs <pod-name>

# Опис поду
kubectl describe pod <pod-name>

# Перевірка HPA
kubectl get hpa

# Перевірка ConfigMap
kubectl get configmap
```
