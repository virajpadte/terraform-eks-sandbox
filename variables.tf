data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_partition" "current" {}

# data "aws_eks_cluster" "eks_cluster" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "eks_cluster" {
#   name = module.eks_cluster.cluster_name
# }

locals {
  account_id         = data.aws_caller_identity.current.account_id
  account_dns_suffix = data.aws_partition.current.dns_suffix
}

# terraform variables
variable "region" {
  description = "aws region for deployment"
  default     = ""
}

variable "access_key" {
  description = "aws account access key"
  default     = ""
}

variable "secret_key" {
  description = "aws account secret key"
  default     = ""
}

# network variables
variable "public_subnet_cidrs" {
  default = [
    "192.168.0.0/28",
    "192.168.64.0/28"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "192.168.128.0/28",
    "192.168.192.0/28"
  ]
}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

# eks compute variables
variable "cluster_name" {
  default = "eks-cluster"
  type    = string
}

# DNS variables
variable "domain_name" {
  default = "unhosted.me"
  type    = string
}