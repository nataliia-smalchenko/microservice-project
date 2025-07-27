# Підключаємо модуль для S3 та DynamoDB
module "s3_backend" {
  source = "./modules/s3-backend"                # Шлях до модуля
  bucket_name = "terraform-state-bucket-yark12398023"  # Ім'я S3-бакета
  table_name  = "terraform-locks"                # Ім'я DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source              = "./modules/vpc"           # Шлях до модуля VPC
  vpc_cidr_block      = "10.0.0.0/16"             # CIDR блок для VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Публічні підмережі
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Приватні підмережі
  availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]            # Зони доступності
  vpc_name            = "vpc"              # Ім'я VPC
}

# Підключаємо модуль ECR
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "lesson-5-ecr"
  scan_on_push = true
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"            # Назва кластера
  subnet_ids      = module.vpc.public_subnets     # ID підмереж
  instance_type   = "t3.medium"                   # Тип інстансів (більше ресурсів)
  desired_size    = 3                             # Бажана кількість нодів
  max_size        = 4                             # Максимальна кількість нодів
  min_size        = 2                             # Мінімальна кількість нодів
}

# module "jenkins" {
#   source       = "./modules/jenkins"
#   cluster_name = module.eks.eks_cluster_name
#   kubeconfig = "~/.kube/config"
#   providers = {
#     helm = helm
#   }
#   oidc_provider_arn = module.eks.oidc_provider_arn
#   oidc_provider_url = module.eks.oidc_provider_url
# }