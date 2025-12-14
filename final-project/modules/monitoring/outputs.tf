data "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }
  depends_on = [helm_release.grafana]
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}"
}

output "grafana_namespace" {
  description = "Kubernetes namespace where Grafana is installed"
  value       = var.namespace
}

output "prometheus_namespace" {
  description = "Kubernetes namespace where Prometheus is installed"
  value       = var.namespace
}

