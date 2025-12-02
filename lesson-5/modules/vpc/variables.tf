variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "public_subnets" {
  description = "CIDR блоки для публічних підмереж"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR блоки для приватних підмереж"
  type        = list(string)
}

variable "availability_zones" {
  description = "Зони доступності для підмереж"
  type        = list(string)
}

variable "vpc_name" {
  description = "Ім'я VPC"
  type        = string
}

