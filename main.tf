module "eks_cluster" {
  source             = "./modules/terraform-aws-eks"
  cluster_name       = "eks-cluster"
  kubernetes_version = "1.22"
  managed_node_group_config = {
    scaling_config = {
      desired_size = 1
      max_size     = 1
      min_size     = 1
    }
    update_config = {
      max_unavailable = 1
    }
  }
  aws_auth_roles                   = []
  aws_auth_users                   = []
  aws_auth_accounts                = []
  public_subnets                   = aws_subnet.eks_public_subnet[*].id
  private_subnets                  = aws_subnet.eks_private_subnet[*].id
  eks_control_plane_security_group = aws_security_group.eks_control_plane_security_group.id
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
