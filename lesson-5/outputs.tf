# Виведення інформації про S3 бекенд
output "s3_backend_bucket_name" {
  description = "Ім'я S3 бакета для стейт-файлів"
  value       = module.s3_backend.bucket_name
}

output "s3_backend_bucket_arn" {
  description = "ARN S3 бакета"
  value       = module.s3_backend.bucket_arn
}

output "dynamodb_table_name" {
  description = "Ім'я DynamoDB таблиці для блокування"
  value       = module.s3_backend.table_name
}

# Виведення інформації про VPC
output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "ID публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "ID NAT Gateway"
  value       = module.vpc.nat_gateway_ids
}

# Виведення інформації про ECR
output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN ECR репозиторію"
  value       = module.ecr.repository_arn
}

