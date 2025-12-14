terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# S3 Backend для Terraform state
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name         = var.s3_bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  tags                = var.tags
}

# VPC модуль
module "vpc" {
  source = "./modules/vpc"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
  tags                 = var.tags
}

# RDS модуль
module "rds" {
  source = "./modules/rds"

  name_prefix  = var.name_prefix
  use_aurora   = var.use_aurora
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr
  subnet_ids   = module.vpc.private_subnet_ids

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  database_name   = var.rds_database_name
  master_username = var.rds_master_username
  master_password = var.rds_master_password

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage  = var.rds_max_allocated_storage
  storage_type          = var.rds_storage_type

  aurora_reader_count = var.aurora_reader_count

  multi_az            = var.rds_multi_az
  publicly_accessible = var.rds_publicly_accessible
  storage_encrypted    = var.rds_storage_encrypted

  backup_retention_period = var.rds_backup_retention_period
  backup_window          = var.rds_backup_window
  maintenance_window     = var.rds_maintenance_window

  skip_final_snapshot       = var.rds_skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.rds_enabled_cloudwatch_logs_exports

  parameter_max_connections = var.rds_parameter_max_connections
  parameter_log_statement   = var.rds_parameter_log_statement
  parameter_work_mem       = var.rds_parameter_work_mem

  tags = var.tags
}

