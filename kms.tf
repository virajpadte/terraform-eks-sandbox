resource "aws_kms_key" "eks_cluster_secrets_key" {
  description             = "KMS key for encryption cluster secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = true
}