resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "argocd" {
  name       = var.release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Застосування Argo CD Applications через Helm chart
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "namespace"
    value = var.namespace
  }

  set {
    name  = "applications[0].source.repoURL"
    value = var.git_repository_url
  }

  set {
    name  = "applications[0].source.targetRevision"
    value = var.target_revision
  }

  set {
    name  = "applications[0].source.path"
    value = var.git_repository_path
  }

  set {
    name  = "applications[0].destination.namespace"
    value = var.destination_namespace
  }

  depends_on = [
    helm_release.argocd
  ]
}

