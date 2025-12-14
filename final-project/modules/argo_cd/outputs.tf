data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "${var.release_name}-server"
    namespace = var.namespace
  }
  depends_on = [helm_release.argocd]
}

output "argocd_url" {
  description = "URL to access Argo CD server"
  value       = "https://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_namespace" {
  description = "Kubernetes namespace where Argo CD is installed"
  value       = var.namespace
}

output "admin_password_command" {
  description = "Command to get Argo CD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d && echo"
}

