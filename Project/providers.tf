# Default AWS provider
provider "aws" {
  region = "eu-central-1"
}

# Data sources for EKS cluster
data "aws_eks_cluster" "main" {
  name = "eks-cluster-demo"
}

data "aws_eks_cluster_auth" "main" {
  name = "eks-cluster-demo"
}

# Kubernetes provider for main resources
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# Helm provider for main resources
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
