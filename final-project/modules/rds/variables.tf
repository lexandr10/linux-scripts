variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "use_aurora" {
  description = "Whether to create Aurora cluster (true) or regular RDS instance (false)"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access the database"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Database engine (postgres or mysql)"
  type        = string
  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Engine must be either 'postgres' or 'mysql'."
  }
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance class for RDS or Aurora"
  type        = string
  default     = "db.t3.medium"
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage in GB (for RDS only)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB (for RDS only)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (for RDS only)"
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window (e.g., '03:00-04:00')"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window (e.g., 'mon:04:00-mon:05:00')"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "parameter_max_connections" {
  description = "Maximum number of connections"
  type        = string
  default     = "100"
}

variable "parameter_log_statement" {
  description = "Log statement setting (for PostgreSQL: 'none', 'ddl', 'mod', 'all')"
  type        = string
  default     = "all"
}

variable "parameter_work_mem" {
  description = "Work memory in MB (PostgreSQL only)"
  type        = string
  default     = "4MB"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

