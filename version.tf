terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_test_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_test_cluster.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_test_cluster.certificate_authority.0.data)
}