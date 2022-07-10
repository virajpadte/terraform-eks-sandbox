### EKS cluster config
resource "aws_eks_cluster" "eks_test_cluster" {
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_test_cluster_role.arn
  version                   = "1.22"
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

### OIDC config
data "tls_certificate" "eks_test_cluster" {
  url = aws_eks_cluster.eks_test_cluster.identity[0].oidc[0].issuer
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

  # update_config {
  #   max_unavailable = 1
  # }

  depends_on = [
    aws_iam_role.eks_test_node_role
  ]

  # ignore_changes = [scaling_config[0].desired_size]

}

