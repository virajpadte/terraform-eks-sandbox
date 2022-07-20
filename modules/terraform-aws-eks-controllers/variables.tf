# EKS variables
# data "aws_eks_cluster" "eks_cluster" {
#   name = var.cluster_name
# }

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "openid_connect_provider" {
  description = "EKS openid connect provider ARN"
  type        = any

}
# service accounts
variable "alb_controller_name" {
  default = "aws-load-balancer-controller"
  type    = string
}

variable "external_dns_controller_name" {
  default = "aws-external-dns-controller"
  type    = string
}

# helm variables
variable "helm_charts" {
  description = "The helm chart release configurations"
  type        = any
}
