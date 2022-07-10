# resource "aws_route53_zone" "eks_test_cluster" {
#   name = var.domain_name
# }

# resource "aws_route53_record" "eks_test_cluster" {
#   for_each = {
#     for dvo in aws_acm_certificate.eks_test_cluster.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.eks_test_cluster.zone_id
# }

# resource "aws_acm_certificate_validation" "eks_test_cluster" {
#   certificate_arn         = aws_acm_certificate.eks_test_cluster.arn
#   validation_record_fqdns = [for record in aws_route53_record.eks_test_cluster : record.fqdn]
# }