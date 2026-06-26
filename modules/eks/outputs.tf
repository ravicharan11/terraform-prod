# ==============================================================
# Outputs - EKS Module (in security-group directory)
# Exports EKS configuration for use by ArgoCD module
# ==============================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate" {
  description = "Base64 encoded certificate for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider" {
  description = "OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN for the EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for the EBS CSI driver"
  value       = aws_iam_role.ebs_csi_driver_role.arn
}
