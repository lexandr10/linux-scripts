output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].id
}

output "rds_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.main[0].endpoint
}

output "aurora_cluster_id" {
  description = "ID of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].id : null
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.main[0].endpoint : null
}

output "database_endpoint" {
  description = "Database endpoint (works for both RDS and Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.main[0].endpoint : aws_db_instance.main[0].endpoint
}

output "database_port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.main[0].port : aws_db_instance.main[0].port
}

output "database_name" {
  description = "Database name"
  value       = var.database_name
}

