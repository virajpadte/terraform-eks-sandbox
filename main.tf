module "eks_cluster" {
  source                           = "./modules/terraform-aws-eks"
  cluster_name                     = "eks-cluster"
  kubernetes_version               = "1.22"
  aws_auth_roles                   = []
  aws_auth_users                   = []
  aws_auth_accounts                = []
  public_subnets                   = aws_subnet.eks_public_subnet[*].id
  private_subnets                  = aws_subnet.eks_private_subnet[*].id
  eks_control_plane_security_group = aws_security_group.eks_control_plane_security_group.id
  enable_endpoint_private_access   = true
  enable_endpoint_public_access    = true
  cluster_access_cidrs = [
    #"${data.http.ip.body}/32"
    "0.0.0.0/0"
  ]

  cluster_secrets_key = aws_kms_key.eks_cluster_secrets_key.arn

  managed_node_group_configs = {
    standard_ng = {
      scaling_config = {
        desired_size = 1
        max_size     = 1
        min_size     = 1
      }
      update_config = {
        max_unavailable = 1
      }

      instance_config = {
        ami_type             = "AL2_x86_64"
        capacity_type        = "ON_DEMAND"
        disk_size            = 20
        force_update_version = false
        instance_types       = ["t3.medium"]
      }
    }

  }
}

module "eks-cluster-controllers" {
  source                  = "./modules/terraform-aws-eks-controllers"
  cluster_name            = "eks-cluster"
  openid_connect_provider = module.eks_cluster.openid_connect_provider
  helm_charts = {
    alb = {
      repository      = "https://aws.github.io/eks-charts"
      name            = "aws-load-balancer-controller"
      chart           = "aws-load-balancer-controller"
      version         = "1.4.2"
      namespace       = "kube-system"
      serviceaccount  = "aws-load-balancer-controller"
      cleanup_on_fail = true
      vars            = {}

    }
    external_dns = {
      repository      = "https://kubernetes-sigs.github.io/external-dns"
      name            = "external-dns"
      chart           = "external-dns"
      namespace       = "kube-system"
      serviceaccount  = "aws-external-dns-controller"
      policy          = "sync"
      cleanup_on_fail = true
      vars            = {}

    }
  }

}
