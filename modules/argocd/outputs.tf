# ==============================================================
# Outputs - ArgoCD Module (in ec2-instance directory)
# Exports ArgoCD configuration
# ==============================================================

output "argocd_loadbalancer_dns" {
  description = "DNS name of the ArgoCD LoadBalancer"
  value       = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname, null)

  depends_on = [
    helm_release.argocd
  ]
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = helm_release.argocd.namespace
}

output "argocd_release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  value       = helm_release.argocd.chart
}
