variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "7.2.0"
}


variable "git_repository_url" {
  description = "URL of the Git repository with Helm charts"
  type        = string
}

variable "git_repository_path" {
  description = "Path to Helm chart in Git repository"
  type        = string
  default     = "charts/django-app"
}

variable "target_revision" {
  description = "Git branch or tag to track"
  type        = string
  default     = "main"
}

variable "destination_namespace" {
  description = "Kubernetes namespace for deployed applications"
  type        = string
  default     = "default"
}

