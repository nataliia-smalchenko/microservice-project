resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  create_namespace = true
  wait = true
  timeout = 600
}

# Створення Repository для ArgoCD
resource "kubernetes_secret" "argo_repository" {
  depends_on = [helm_release.argo_cd]
  
  metadata {
    name      = "microservice-project-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  
  data = {
    url      = base64encode("https://github.com/nataliia-smalchenko/microservice-project.git")
    username = base64encode("nataliia-smalchenko")
    password = base64encode("github_pat")
  }
}

# Створення Application для ArgoCD
resource "kubernetes_manifest" "argo_application" {
  depends_on = [helm_release.argo_cd, kubernetes_secret.argo_repository]
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "django-app"
      namespace = "argocd"
      labels = {
        app        = "django-app"
        managed-by = "argocd"
      }
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/nataliia-smalchenko/microservice-project.git"
        path           = "lesson-7/charts/django-app"
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
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
      }
    }
  }
}

