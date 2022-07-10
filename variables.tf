data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_partition" "current" {}

data "aws_eks_cluster_auth" "eks_test_cluster" {
  name = aws_eks_cluster.eks_test_cluster.name
}

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
  default = "eks-test-cluster"
  type    = string
}

variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.22"
}

variable "managed_node_group_config" {
  description = "Managed node group scaling configuration"
  default = {
    update_config = {
      max_unavailable = 1
    }
    scaling_config = {
      desired_size = 1
      max_size     = 1
      min_size     = 1
    }
  }
}

variable "eks_control_plane_creation_wait" {
  description = "Wait duration after control plane creation"
  default     = "90s"
}

# eks config map variables

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_accounts" {
  description = "List of account maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}


# # service accounts
# variable "alb_service_account_name" {
#   default = "aws-load-balancer-controller"
#   type    = string
# }

# variable "external_dns_service_account_name" {
#   default = "aws-external-dns-controller"
#   type    = string
# }

# # dns variables
# variable "domain_name" {
#   default = "unhosted.me"
#   type    = string
# }
