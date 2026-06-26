# ==============================================================
# Production Environment Variables
# Used with: terraform workspace new prod
# ==============================================================

region             = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
cluster_version    = "1.35"
instance_type      = "t3.medium"
project            = "terraweek"
