# ==============================================================
# Variables - Root Module
# These variables are passed from tfvars files
# ==============================================================

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     ="us-east-1"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
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

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "terraweek"
}
