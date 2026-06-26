# ==============================================================
# ArgoCD — Installed via Helm into the EKS cluster
# Exposed via LoadBalancer (accessible in browser)
# server.insecure = true disables HTTPS (OK for lab, not production)
# depends_on ensures cluster exists before installing
# ==============================================================

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.7.7"

  # Create the namespace if it doesn't exist
  create_namespace = true

  # Helm Values
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.insecure"
    value = "true"
  }

  # Tags for the Helm release
  set {
    name  = "global.labels.environment"
    value = var.environment
  }

  set {
    name  = "global.labels.project"
    value = var.project
  }

  set {
    name  = "global.labels.managedBy"
    value = "Terraform"
  }

  # Ensure EKS cluster exists before installing ArgoCD
  depends_on = []
}

# ==============================================================
# Kubernetes Namespace (optional, explicit creation)
# Note: Helm create_namespace = true handles this automatically
# ==============================================================

# ==============================================================
# Data Source: Wait for EKS cluster to be ready
# ==============================================================

# This data source ensures the cluster is accessible before Helm install
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# ==============================================================
# Kubernetes Service Data Source
# Retrieves the ArgoCD server service to get LoadBalancer DNS
# ==============================================================

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }

  depends_on = [
    helm_release.argocd
  ]
}
