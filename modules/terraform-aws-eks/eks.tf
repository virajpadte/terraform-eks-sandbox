### OIDC config
data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

### EKS cluster config
resource "aws_eks_cluster" "eks_cluster" {
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  version                   = var.kubernetes_version
  vpc_config {
    subnet_ids              = flatten([var.public_subnets, var.private_subnets])
    security_group_ids      = [var.eks_control_plane_security_group]
    endpoint_private_access = var.enable_endpoint_private_access
    endpoint_public_access  = var.enable_endpoint_public_access
    public_access_cidrs     = var.cluster_access_cidrs
  }
  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_cloudwatch_log_group.eks_cluster_log_group
  ]
}

### EKS cluster logging
resource "aws_cloudwatch_log_group" "eks_cluster_log_group" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 1
}

resource "aws_iam_openid_connect_provider" "eks_cluster_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

### Node groups
resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets
  scaling_config {
    desired_size = var.managed_node_group_config.scaling_config.desired_size
    max_size     = var.managed_node_group_config.scaling_config.max_size
    min_size     = var.managed_node_group_config.scaling_config.min_size

  }
  update_config {
    max_unavailable = var.managed_node_group_config.update_config.max_unavailable
  }
}

### EKS Config map

resource "time_sleep" "eks_control_plane_creation_wait" {
  create_duration = var.eks_control_plane_creation_wait
  depends_on      = [aws_eks_cluster.eks_cluster, ]
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      [{
        rolearn  = element(compact(aws_iam_role.eks_node_role.*.arn), 0)
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }],
      var.aws_auth_roles
    ))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
  depends_on = [time_sleep.eks_control_plane_creation_wait]
}