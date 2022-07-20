resource "aws_acm_certificate" "eks_cluster" {
  domain_name       = "2048.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_zone" "eks_cluster" {
  name = var.domain_name
}

resource "aws_route53_record" "eks_cluster" {
  for_each = {
    for dvo in aws_acm_certificate.eks_cluster.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.eks_cluster.zone_id
}