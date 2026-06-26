# ==============================================================
# Variables - ArgoCD Module (in ec2-instance directory)
# ==============================================================

variable "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  type        = string
}

variable "cluster_certificate" {
  description = "Base64 encoded certificate for the EKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_region" {
  description = "AWS region where the EKS cluster is located"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}
