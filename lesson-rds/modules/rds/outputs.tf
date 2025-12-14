# Спільні outputs
output "db_subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

# RDS Instance outputs (коли use_aurora = false)
output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].id
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].arn
}

output "rds_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].endpoint
}

output "rds_instance_address" {
  description = "Address of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].address
}

output "rds_instance_port" {
  description = "Port of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].port
}

# Aurora Cluster outputs (коли use_aurora = true)
output "aurora_cluster_id" {
  description = "ID of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].id : null
}

output "aurora_cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].arn : null
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].endpoint : null
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].reader_endpoint : null
}

output "aurora_cluster_database_name" {
  description = "Database name in the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].database_name : null
}

output "aurora_cluster_port" {
  description = "Port of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].port : null
}

# Універсальні outputs (працюють для обох типів)
output "database_endpoint" {
  description = "Database endpoint (works for both RDS and Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.main[0].endpoint : aws_db_instance.main[0].endpoint
}

output "database_port" {
  description = "Database port (works for both RDS and Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.main[0].port : aws_db_instance.main[0].port
}

output "database_name" {
  description = "Database name"
  value       = var.database_name
}

output "master_username" {
  description = "Master username"
  value       = var.master_username
  sensitive   = true
}

