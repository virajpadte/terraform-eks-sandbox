output "endpoint" {
  value = aws_eks_cluster.eks_test_cluster.endpoint
}

output "oidc_issuer" {
  value = aws_eks_cluster.eks_test_cluster.identity[0].oidc[0].issuer
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_test_cluster.certificate_authority[0].data
}

output "aws_route53_zone_nameservers" {
  value = aws_route53_zone.eks_test_cluster.name_servers
}