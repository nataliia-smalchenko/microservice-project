terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      configuration_aliases = [kubernetes]
    }
    helm = {
      source  = "hashicorp/helm"
      configuration_aliases = [helm]
    }
    aws = {
      source  = "hashicorp/aws"
    }
  }
}
