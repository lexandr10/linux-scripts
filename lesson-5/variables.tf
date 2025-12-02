variable "aws_region" {
  description = "AWS регіон для розгортання ресурсів"
  type        = string
  default     = "us-west-2"
}

variable "backend_bucket_name" {
  description = "Ім'я S3 бакета для стейт-файлів Terraform"
  type        = string
  default     = "terraform-state-bucket-name"
}

variable "backend_table_name" {
  description = "Ім'я DynamoDB таблиці для блокування стейтів"
  type        = string
  default     = "terraform-locks"
}

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR блоки для публічних підмереж"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDR блоки для приватних підмереж"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "Зони доступності для підмереж"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  description = "Ім'я VPC"
  type        = string
  default     = "lesson-5-vpc"
}

variable "ecr_name" {
  description = "Ім'я ECR репозиторію"
  type        = string
  default     = "lesson-5-ecr"
}

variable "ecr_scan_on_push" {
  description = "Увімкнути автоматичне сканування образів при push"
  type        = bool
  default     = true
}

