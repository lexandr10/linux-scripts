output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# RDS outputs
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.rds.database_endpoint
}

output "database_port" {
  description = "Database port"
  value       = module.rds.database_port
}

output "database_name" {
  description = "Database name"
  value       = module.rds.database_name
}

output "rds_instance_id" {
  description = "RDS instance ID (null for Aurora)"
  value       = module.rds.rds_instance_id
}

output "aurora_cluster_id" {
  description = "Aurora cluster ID (null for RDS)"
  value       = module.rds.aurora_cluster_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster writer endpoint (null for RDS)"
  value       = module.rds.aurora_cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint (null for RDS)"
  value       = module.rds.aurora_cluster_reader_endpoint
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.security_group_id
}

