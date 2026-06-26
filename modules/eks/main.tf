# ==============================================================
# EKS CLUSTER
# Creates:
# 1. EKS control plane (managed by AWS — API server, etcd, scheduler)
# 2. Managed node group (EC2 worker nodes where pods run)
# 3. 6 add-ons: coredns, kube-proxy, vpc-cni, pod-identity,
#    ebs-csi-driver, metrics-server
# 4. IAM role (IRSA) for the EBS CSI driver
# Uses EKS module v21.x with Kubernetes 1.35, AL2023 AMI,
# EKS Pod Identity, access_entries, and AWS provider v6.0+
# ==============================================================

# EKS Module from terraform-aws-modules/eks/aws v21.x
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  version = "~> 21.0"

  # Cluster Name
  cluster_name    = "${var.project}-${var.environment}"
  cluster_version = var.cluster_version

  # VPC Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Cluster Endpoint Configuration
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Cluster IAM Role
  iam_role_arn = aws_iam_role.eks_cluster_role.arn

  # OIDC Provider
  enable_irsa = true

  # EKS Pod Identity
  enable_pod_identity = true

  # Cluster Add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
    }
    metrics-server = {
      most_recent = true
    }
  }

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default_node_group = {
      name           = "${var.project}-${var.environment}-node-group"
      instance_types = [var.instance_type]

      # Node Group Configuration
      min_size     = 3
      max_size     = 3
      desired_size = 3

      # Node IAM Role
      iam_role_arn = aws_iam_role.eks_node_role.arn

      # AMI Configuration
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "ON_DEMAND"

      # Node Group Labels
      labels = {
        Environment = var.environment
        Project     = var.project
      }

      # Node Group Tags
      tags = {
        Name        = "${var.project}-${var.environment}-node"
        Environment = var.environment
        Project     = var.project
        ManagedBy   = "Terraform"
      }
    }
  }

  # Access Entries for EKS Pod Identity
  access_entries = {
    # Admin access for cluster creator
    admin_access = {
      principal_arn = data.aws_caller_identity.current.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Cluster Tags
  tags = {
    Name        = "${var.project}-${var.environment}-eks"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ==============================================================
# IAM Roles
# ==============================================================

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-eks-cluster-role"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Attach EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach EKS VPC Resource Controller Policy
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node IAM Role
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project}-${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-eks-node-role"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Attach EKS Worker Node Policy
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# Attach EKS CNI Policy
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# Attach EC2 Container Registry Readonly Policy
resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# EBS CSI Driver IAM Role (IRSA)
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.project}-${var.environment}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-ebs-csi-driver-role"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# EBS CSI Driver IAM Policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role.name
}

# ==============================================================
# Data Sources
# ==============================================================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}
