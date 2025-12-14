variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lesson-rds"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# RDS variables
variable "use_aurora" {
  description = "Whether to create Aurora cluster (true) or regular RDS instance (false)"
  type        = bool
  default     = false
}

variable "rds_engine" {
  description = "Database engine (postgres or mysql)"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "Instance class for RDS or Aurora"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "mydb"
}

variable "rds_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "rds_master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB (for RDS only)"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage in GB (for RDS only)"
  type        = number
  default     = 100
}

variable "rds_storage_type" {
  description = "Storage type (for RDS only)"
  type        = string
  default     = "gp3"
}

variable "aurora_reader_count" {
  description = "Number of Aurora reader instances"
  type        = number
  default     = 0
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "rds_publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "rds_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_backup_window" {
  description = "Backup window (e.g., '03:00-04:00')"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_maintenance_window" {
  description = "Maintenance window (e.g., 'mon:04:00-mon:05:00')"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = true
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "rds_parameter_max_connections" {
  description = "Maximum number of connections"
  type        = string
  default     = "100"
}

variable "rds_parameter_log_statement" {
  description = "Log statement setting (for PostgreSQL: 'none', 'ddl', 'mod', 'all')"
  type        = string
  default     = "all"
}

variable "rds_parameter_work_mem" {
  description = "Work memory in MB (PostgreSQL only)"
  type        = string
  default     = "4MB"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "lesson-rds"
    Environment = "development"
    ManagedBy   = "terraform"
  }
}

