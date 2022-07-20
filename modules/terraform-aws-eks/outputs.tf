output "token" {
  value = data.aws_eks_cluster_auth.eks_cluster.token
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "oidc_issuer" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "kubeconfig_certificat_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "openid_connect_provider" {
  value = aws_iam_openid_connect_provider.eks_cluster_openid_connect_provider
}