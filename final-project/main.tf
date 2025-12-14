terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
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

# ECR модуль
module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  tags            = var.tags
}

# EKS модуль
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_desired_size  = var.node_desired_size
  instance_types     = var.instance_types
  capacity_type      = var.capacity_type
  tags               = var.tags
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
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = var.rds_storage_type

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

# Jenkins модуль
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name  = module.eks.cluster_name
  namespace     = var.jenkins_namespace
  release_name  = var.jenkins_release_name
  chart_version = var.jenkins_chart_version
}

# Argo CD модуль
module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name          = module.eks.cluster_name
  namespace             = var.argocd_namespace
  release_name          = var.argocd_release_name
  chart_version         = var.argocd_chart_version
  git_repository_url    = var.git_repository_url
  git_repository_path   = var.git_repository_path
  target_revision       = var.target_revision
  destination_namespace = var.destination_namespace
}

# Monitoring модуль
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name           = module.eks.cluster_name
  namespace              = var.monitoring_namespace
  prometheus_chart_version = var.prometheus_chart_version
  grafana_chart_version  = var.grafana_chart_version
}

