output "argocd_admin_password" {
  value = data.kubernetes_secret.argocd_admin_password.data["password"]
}

output "argocd_url" {
  value = "https://argocd.${var.base_domain}"
}

output "argocd_username" {
  value = "admin"
}

output "aws_eks_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${data.aws_region.current.name}"
}

output "kubectl_port_forward_command" {
  value = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

output "aws_eks_cluster_name" {
  value = module.eks.cluster_name
}
