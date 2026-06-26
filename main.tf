# ==============================================================
# Root Module - Orchestrates all child modules
# This module coordinates the deployment flow:
# VPC Module → EKS Module → ArgoCD Module
# ==============================================================

# Module: VPC
# Creates the networking infrastructure (VPC, subnets, NAT Gateway)
module "vpc" {
  source = "./modules/vpc"

  # Variables from tfvars
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  # Tags
  environment = local.environment
  project     = var.project
}

# Module: EKS (in modules/eks directory)
# Creates the EKS cluster, node groups, IAM roles, and add-ons
module "eks" {
  source = "./modules/eks"

  # VPC outputs from vpc module
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Variables from tfvars
  region             = var.region
  cluster_version    = var.cluster_version
  instance_type      = var.instance_type

  # Tags
  environment = local.environment
  project     = var.project
}

# Module: ArgoCD (in modules/argocd directory)
# Installs ArgoCD using Helm provider into the EKS cluster
module "argocd" {
  source = "./modules/argocd"

  # EKS outputs from eks module
  cluster_endpoint     = module.eks.cluster_endpoint
  cluster_certificate  = module.eks.cluster_certificate
  cluster_name         = module.eks.cluster_name
  cluster_region       = var.region

  # Tags
  environment = local.environment
  project     = var.project
}
