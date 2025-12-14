resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

# Prometheus Operator
resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

# Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/grafana-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

