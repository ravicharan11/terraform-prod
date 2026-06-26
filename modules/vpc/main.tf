# ==============================================================
# VPC (Virtual Private Cloud)
# Creates an isolated network where all EKS resources live.
# Uses the official AWS VPC module to create 9 subnets across 3 AZs:
# - Public subnets  (10.0.1-3.0/24) → for internet-facing Load Balancers
# - Private subnets (10.0.4-6.0/24) → for worker nodes (hidden from internet)
# - Intra subnets   (10.0.7-9.0/24) → for EKS control plane ENIs (fully isolated)
# Also creates a NAT Gateway so private nodes can download Docker images
# without being directly reachable from the internet.
# ==============================================================

# VPC Module from terraform-aws-modules/vpc/aws
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # VPC Configuration
  name = "${var.project}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  # Availability Zones
  azs = var.availability_zones

  # Public Subnets (10.0.1-3.0/24)
  # Used for internet-facing Load Balancers
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  # Private Subnets (10.0.4-6.0/24)
  # Used for EKS worker nodes
  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]

  # Intra Subnets (10.0.7-9.0/24)
  # Used for EKS control plane ENIs (fully isolated)
  intra_subnets = [
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/24",
  ]

  # NAT Gateway
  # Enable NAT Gateway for private subnets
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Tags
  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  # Public Subnet Tags
  public_subnet_tags = {
    Name                              = "${var.project}-${var.environment}-public-subnet"
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/${var.project}-${var.environment}" = "shared"
    Environment                       = var.environment
    Project                           = var.project
    ManagedBy                         = "Terraform"
  }

  # Private Subnet Tags
  private_subnet_tags = {
    Name                              = "${var.project}-${var.environment}-private-subnet"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.project}-${var.environment}" = "shared"
    Environment                       = var.environment
    Project                           = var.project
    ManagedBy                         = "Terraform"
  }

  # Intra Subnet Tags
  intra_subnet_tags = {
    Name        = "${var.project}-${var.environment}-intra-subnet"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
