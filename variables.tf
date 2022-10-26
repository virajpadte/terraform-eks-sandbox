data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_region" "current" {}

data "aws_partition" "current" {}

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
    "192.168.0.0/24",
    "192.168.64.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "192.168.128.0/24",
    "192.168.192.0/24"
  ]
}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "vpce_services" {
  default = {
    "gateway" = [
      "s3"
    ]
    "interface" = [
      "autoscaling",
      "ec2",
      "ec2messages",
      "ecr.api",
      "ecr.dkr",
      "elasticloadbalancing",
      "logs",
      "ssm",
      "ssmmessages",
      "sts"
    ]
  }
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

# My IP
data "http" "ip" {
  url = "https://ifconfig.me"
}