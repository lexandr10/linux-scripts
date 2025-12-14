variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Version of the Prometheus Operator Helm chart"
  type        = string
  default     = "55.0.0"
}

variable "grafana_chart_version" {
  description = "Version of the Grafana Helm chart"
  type        = string
  default     = "7.0.0"
}

