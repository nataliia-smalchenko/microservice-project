variable "name" {
  description = "Name for the ArgoCD release"
  type        = string
  default     = "argocd"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "repo_username" {
  description = "Git repository username"
  type        = string
}

variable "repo_password" {
  description = "Git repository password or token"
  type        = string
  sensitive   = true
}
