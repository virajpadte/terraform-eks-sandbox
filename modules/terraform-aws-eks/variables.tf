data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_partition" "current" {}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

locals {
  account_id         = data.aws_caller_identity.current.account_id
  account_dns_suffix = data.aws_partition.current.dns_suffix
}

# EKS cluster variables
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Target version of kubernetes"
  type        = string
}

variable "managed_node_group_config" {
  description = "Managed node group configuration"
  type        = map(any)
}

variable "eks_control_plane_creation_wait" {
  description = "Wait duration after control plane creation"
  default     = "90s"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "cluster_access_cidrs" {
  description = "Cluster access CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "enable_endpoint_private_access" {
  description = "Flag to enable private access for EKS control plane"
  type        = bool
}

variable "enable_endpoint_public_access" {
  description = "Flag to enable private access for EKS control plane"
  type        = bool
}

# EKS config map variables
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

variable "eks_control_plane_security_group" {
  description = "EKS control plane security group"
  type        = string

}