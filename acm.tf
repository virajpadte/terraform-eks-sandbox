# resource "aws_acm_certificate" "eks_test_cluster" {
#   domain_name       = "2048.${var.domain_name}"
#   validation_method = "DNS"
# }