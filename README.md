# Terraform Multi-Environment EKS Deployment

This project provides a production-ready Terraform configuration for deploying Amazon EKS (Elastic Kubernetes Service) across multiple environments using Terraform Workspaces.

## Project Overview

This Terraform project creates a complete Kubernetes infrastructure on AWS including:

- VPC with public, private, and intra subnets across 3 availability zones
- EKS cluster with managed node groups
- IAM roles with IRSA (IAM Roles for Service Accounts)
- EKS add-ons (coredns, kube-proxy, vpc-cni, pod-identity, ebs-csi-driver, metrics-server)
- ArgoCD installed via Helm for GitOps deployments

## Project Structure

```
terraweek-capstone/
├── main.tf              # Root module orchestrating child modules
├── variables.tf         # Root module variables
├── outputs.tf           # Root module outputs
├── providers.tf         # Provider configurations
├── locals.tf            # Local values
├── dev.tfvars           # Development environment variables
├── staging.tfvars       # Staging environment variables
├── prod.tfvars          # Production environment variables
├── .gitignore           # Git ignore rules
├── README.md            # This file
└── modules/
    ├── vpc/             # VPC networking module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/             # EKS cluster module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── argocd/          # ArgoCD installation module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── providers.tf
```

## Requirements

### Software Requirements

- Terraform >= 1.6
- AWS CLI configured with credentials
- kubectl (for cluster management)
- Git

### AWS Requirements

- AWS account with appropriate permissions
- IAM user/role with permissions to create:
  - VPC, subnets, route tables, NAT Gateway
  - EKS clusters and node groups
  - IAM roles and policies
  - EC2 instances
  - Load Balancers

### Terraform Providers

- AWS Provider v6.x
- Kubernetes Provider v2.30.x
- Helm Provider v2.15.x
- terraform-aws-modules/vpc/aws
- terraform-aws-modules/eks/aws v21.x

## Architecture

### VPC Module

Creates the networking infrastructure with:

- 1 VPC with CIDR 10.0.0.0/16
- Internet Gateway for public internet access
- 1 NAT Gateway for private subnet egress
- 9 subnets across 3 availability zones:
  - Public subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24) for Load Balancers
  - Private subnets (10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24) for worker nodes
  - Intra subnets (10.0.7.0/24, 10.0.8.0/24, 10.0.9.0/24) for EKS control plane ENIs
- DNS hostnames enabled
- Proper EKS subnet tagging

### EKS Module

Creates the Kubernetes cluster with:

- EKS control plane (Kubernetes 1.35)
- Managed node group with 3 t3.medium instances
- IAM roles for cluster and nodes
- OIDC provider for IRSA
- EKS Pod Identity enabled
- Access entries for cluster administration
- 6 EKS add-ons:
  - coredns
  - kube-proxy
  - vpc-cni
  - eks-pod-identity-agent
  - aws-ebs-csi-driver
  - metrics-server
- IAM role and policy for EBS CSI Driver (IRSA)

### ArgoCD Module

Installs ArgoCD via Helm with:

- ArgoCD chart from argoproj repository
- LoadBalancer service type
- Insecure mode (for lab/testing)
- Automatic namespace creation

## Terraform Workspaces

This project uses Terraform Workspaces for environment isolation:

- dev: Development environment
- staging: Staging environment
- prod: Production environment

Resource names automatically include the workspace name:
- terraweek-dev
- terraweek-staging
- terraweek-prod

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/ravicharan11/terraform-prod.git
cd terraform-prod
```

### 2. Configure AWS Credentials

Ensure AWS CLI is configured with your credentials:

```bash
aws configure
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Create and Switch to Workspace

For development:

```bash
terraform workspace new dev
terraform workspace select dev
```

For staging:

```bash
terraform workspace new staging
terraform workspace select staging
```

For production:

```bash
terraform workspace new prod
terraform workspace select prod
```

### 5. Review the Plan

```bash
terraform plan -var-file=dev.tfvars
```

Replace dev.tfvars with staging.tfvars or prod.tfvars for other environments.

### 6. Apply the Configuration

```bash
terraform apply -var-file=dev.tfvars
```

Type yes when prompted to confirm.

### 7. Wait for Deployment

The deployment takes approximately 15-20 minutes due to EKS cluster provisioning.

### 8. Access Outputs

After deployment, view the outputs:

```bash
terraform output
```

This will display:
- cluster_name
- cluster_endpoint
- cluster_security_group
- vpc_id
- private_subnets
- public_subnets
- argocd_loadbalancer_dns

### 9. Configure kubectl

Update your kubeconfig to access the cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name terraweek-dev
```

Replace terraweek-dev with the appropriate cluster name for your workspace.

### 10. Verify Cluster

```bash
kubectl get nodes
kubectl get pods -A
```

### 11. Access ArgoCD

Get the ArgoCD LoadBalancer DNS:

```bash
terraform output argocd_loadbalancer_dns
```

Access ArgoCD in your browser using the LoadBalancer DNS.

Get the initial ArgoCD password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Environment Variables

### dev.tfvars

- region: AWS region (default: us-east-1)
- vpc_cidr: VPC CIDR block (default: 10.0.0.0/16)
- availability_zones: List of AZs (default: us-east-1a, us-east-1b, us-east-1c)
- cluster_version: Kubernetes version (default: 1.35)
- instance_type: EC2 instance type (default: t3.medium)
- project: Project name (default: terraweek)

### staging.tfvars

Same structure as dev.tfvars for staging environment.

### prod.tfvars

Same structure as dev.tfvars for production environment.

## Cost Estimation

### Daily Cost (us-east-1)

- EKS control plane: $2.40/day
- 3x t3.medium instances: $3.00/day
- NAT Gateway: $1.08/day (plus data transfer)
- LoadBalancer: $0.54/day (plus data transfer)

Total: Approximately $7.02/day (excluding data transfer)

### Monthly Cost

Approximately $210/month (varies with usage and data transfer)

### Cost Optimization

To reduce costs:

1. Use smaller instances (t3.small instead of t3.medium)
2. Reduce node count (1-2 nodes instead of 3)
3. Remove NAT Gateway if not needed
4. Choose cheaper AWS regions (us-east-1, us-west-2, eu-central-1, ap-south-1)

## Outputs

The following outputs are available after deployment:

- cluster_name: Name of the EKS cluster
- cluster_endpoint: API server endpoint URL
- cluster_security_group: Security group ID for the cluster
- vpc_id: VPC ID
- private_subnets: IDs of private subnets
- public_subnets: IDs of public subnets
- argocd_loadbalancer_dns: DNS name of ArgoCD LoadBalancer

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var-file=dev.tfvars
```

Replace dev.tfvars with the appropriate environment file.

To delete a workspace:

```bash
terraform workspace select default
terraform workspace delete dev
```

## Security Considerations

- The ArgoCD installation uses insecure=true for lab/testing purposes
- For production, enable TLS/HTTPS and configure proper authentication
- Review IAM policies and permissions before deploying to production
- Use AWS KMS for encryption in production environments
- Enable VPC flow logs for security monitoring
- Implement proper network ACLs and security group rules

## Troubleshooting

### Terraform Init Fails

Ensure you have Terraform >= 1.6 installed:

```bash
terraform --version
```

### AWS Authentication Errors

Verify AWS credentials are configured:

```bash
aws sts get-caller-identity
```

### Cluster Not Ready

Wait for EKS cluster to become ready:

```bash
aws eks describe-cluster --name terraweek-dev --region us-east-1
```

### kubectl Connection Errors

Update kubeconfig:

```bash
aws eks update-kubeconfig --region us-east-1 --name terraweek-dev
```

### ArgoCD Not Accessible

Check the LoadBalancer status:

```bash
kubectl get svc -n argocd
```

## Module Details

### VPC Module

Location: modules/vpc/

Uses the official terraform-aws-modules/vpc/aws module to create:
- VPC with DNS support
- Public, private, and intra subnets
- Internet Gateway and NAT Gateway
- Route tables and associations
- Proper subnet tagging for EKS

### EKS Module

Location: modules/eks/

Uses terraform-aws-modules/eks/aws v21.x to create:
- EKS control plane with Kubernetes 1.35
- Managed node group with Amazon Linux 2023 AMI
- IAM roles for cluster and nodes
- OIDC provider for IRSA
- EKS Pod Identity
- Access entries for cluster administration
- EKS add-ons with latest versions
- EBS CSI Driver IAM role with IRSA

### ArgoCD Module

Location: modules/argocd/

Uses Helm provider to install:
- ArgoCD chart from argoproj repository
- LoadBalancer service for external access
- Insecure mode for lab/testing
- Automatic namespace creation

## Tags

All resources are tagged with:

- Environment: dev/staging/prod (from workspace)
- Project: terraweek
- ManagedBy: Terraform

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in dev environment
5. Submit a pull request

## License

This project is provided as-is for educational and production use.

## Support

For issues or questions:
- Check AWS EKS documentation
- Review Terraform AWS provider documentation
- Check ArgoCD documentation
- Review Terraform module documentation
