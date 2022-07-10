### OIDC config
data "tls_certificate" "eks_test_cluster" {
  url = aws_eks_cluster.eks_test_cluster.identity[0].oidc[0].issuer
}

### EKS cluster config
resource "aws_eks_cluster" "eks_test_cluster" {
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_test_cluster_role.arn
  version                   = var.kubernetes_version
  vpc_config {
    subnet_ids              = flatten([aws_subnet.eks_test_public_subnet[*].id, aws_subnet.eks_test_private_subnet[*].id])
    security_group_ids      = [aws_security_group.eks_test_control_plane_security_group.id]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }
  depends_on = [
    aws_iam_role.eks_test_cluster_role,
    aws_cloudwatch_log_group.eks_test_cluster_log_group
  ]
}

### EKS cluster logging
resource "aws_cloudwatch_log_group" "eks_test_cluster_log_group" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 1
}

resource "aws_iam_openid_connect_provider" "eks_test_cluster_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_test_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_test_cluster.identity.0.oidc.0.issuer
}

### Node groups
resource "aws_eks_node_group" "eks_test_cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_test_cluster.name
  node_group_name = "eks-test-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_test_node_role.arn
  subnet_ids      = aws_subnet.eks_test_private_subnet[*].id
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  # update config
}

### EKS Config map

resource "time_sleep" "eks_control_plane_creation_wait" {
  create_duration = var.eks_control_plane_creation_wait
  depends_on      = [aws_eks_cluster.eks_test_cluster, ]
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
        rolearn  = element(compact(aws_iam_role.eks_test_node_role.*.arn), 0)
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }],
      var.aws_auth_roles
    ))
    mapUsers = yamlencode(concat(
      [
        {
          userarn  = aws_iam_user.eks_test_cluster_super_admin_user.arn
          username = aws_iam_user.eks_test_cluster_super_admin_user.name
          groups   = ["system:masters"]
        },
        {
          userarn  = aws_iam_user.eks_test_cluster_namespace_admin_user.arn
          username = aws_iam_user.eks_test_cluster_namespace_admin_user.name
          groups   = ["system:masters"]
        }
      ],
      var.aws_auth_roles
    ))
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
  depends_on = [time_sleep.eks_control_plane_creation_wait]
}