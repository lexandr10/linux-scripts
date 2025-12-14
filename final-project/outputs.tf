output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.rds.database_endpoint
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = module.jenkins.jenkins_url
}

output "jenkins_admin_password" {
  description = "Command to get Jenkins admin password"
  value       = module.jenkins.admin_password_command
  sensitive   = false
}

output "argocd_url" {
  description = "URL to access Argo CD server"
  value       = module.argo_cd.argocd_url
}

output "argocd_admin_password" {
  description = "Command to get Argo CD admin password"
  value       = module.argo_cd.admin_password_command
  sensitive   = false
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = module.monitoring.grafana_url
}

