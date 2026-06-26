# ==============================================================
# Variables - EKS Module (in eks directory)
# ==============================================================

variable "region" {
  description = "AWS region where EKS cluster will be created"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for EKS worker nodes"
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
