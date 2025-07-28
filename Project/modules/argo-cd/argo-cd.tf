resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  
  depends_on = [terraform_data.cluster_ready]

  values = [
    templatefile("${path.module}/values.yaml", {
      repo_url      = var.repo_url
      repo_username = var.repo_username
      repo_password = var.repo_password
    })
  ]

  create_namespace = true
  wait = true
  timeout = 600
}

# Wait for Argo CD CRDs to be available
resource "time_sleep" "wait_for_crds" {
  depends_on = [helm_release.argo_cd]
  create_duration = "300s"
}

# Create repository secret
resource "kubernetes_secret" "repo_secret" {
  metadata {
    name      = "microservice-project-repo"
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.repo_url
    username = var.repo_username
    password = var.repo_password
  }

  depends_on = [time_sleep.wait_for_crds]
}

# Create Argo CD Application
resource "kubernetes_manifest" "django_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "django-app"
      namespace = var.namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo_url
        path           = "Project/charts/django-app"
        targetRevision = "main"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [kubernetes_secret.repo_secret]
}

