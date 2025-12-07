data "kubernetes_service" "jenkins" {
  metadata {
    name      = "${var.release_name}"
    namespace = var.namespace
  }
  depends_on = [helm_release.jenkins]
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].hostname}:8080"
}

output "jenkins_namespace" {
  description = "Kubernetes namespace where Jenkins is installed"
  value       = var.namespace
}

output "admin_password_command" {
  description = "Command to get Jenkins admin password"
  value       = "kubectl exec --namespace ${var.namespace} -it svc/${var.release_name} -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo"
}

