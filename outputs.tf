# ==============================================================
# Outputs - Root Module
# Exports important values from the deployment
# ==============================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "argocd_loadbalancer_dns" {
  description = "DNS name of the ArgoCD LoadBalancer"
  value       = module.argocd.argocd_loadbalancer_dns
}
