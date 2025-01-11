output "argocd_admin_password" {
  value = random_password.argocd_admin_password.result
}

output "argocd_url" {
  value = "https://argocd.${var.base_domain}"
}

output "argocd_username" {
  value = "admin"
}

output "aws_eks_command" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.cluster.name} --region ${var.aws_region}"
}

output "aws_eks_cluster_name" {
  value = aws_eks_cluster.cluster.name
}
