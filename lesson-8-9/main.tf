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

# Jenkins модуль
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name = module.eks.cluster_name
  namespace    = var.jenkins_namespace
  release_name = var.jenkins_release_name
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

