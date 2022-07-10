data "aws_caller_identity" "current" {
  provider = aws
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

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

variable "cluster_name" {
  default = "eks-test-cluster"
  type    = string
}

variable "alb_service_account_name" {
  default = "aws-load-balancer-controller"
  type    = string
}

variable "external_dns_service_account_name" {
  default = "aws-external-dns-controller"
  type    = string
}

variable "domain_name" {
  default = "unhosted.me"
  type    = string
}
