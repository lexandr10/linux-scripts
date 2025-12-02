variable "ecr_name" {
  description = "Ім'я ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Увімкнути автоматичне сканування образів при push"
  type        = bool
  default     = true
}

