resource "aws_acm_certificate_validation" "eks_cluster" {
  certificate_arn         = aws_acm_certificate.eks_cluster.arn
  validation_record_fqdns = [for record in aws_route53_record.eks_cluster : record.fqdn]
}