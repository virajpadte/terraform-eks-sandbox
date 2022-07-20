# Cluster role
data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [format("eks.%s", local.account_dns_suffix)]
    }
  }
}


resource "aws_iam_role" "eks_cluster_role" {
  name                = "eks-cluster-role"
  assume_role_policy  = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

# Managed node roles
data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [format("ec2.%s", local.account_dns_suffix)]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# IAM users
## cluster admin
# resource "aws_iam_user" "eks_cluster_super_admin_user" {
#   name = "eks_cluster_super_admin_user"
# }

# resource "aws_iam_policy" "eks_cluster_super_admin_user" {
#   name = "eks_cluster_super_admin_policy"
#   path = "/"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "eks:DescribeCluster",
#           "eks:ListClusters"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "eks_cluster_super_admin_user" {
#   name       = "eks_cluster_super_admin_policy_attachment"
#   users      = [aws_iam_user.eks_cluster_super_admin_user.name]
#   policy_arn = aws_iam_policy.eks_cluster_super_admin_user.arn
# }

# resource "aws_iam_access_key" "eks_cluster_super_admin_user_key" {
#   user = aws_iam_user.eks_cluster_super_admin_user.name
# }

# ## namespace admin
# resource "aws_iam_user" "eks_cluster_namespace_admin_user" {
#   name = "eks_cluster_namespace_admin_user"
# }

# resource "aws_iam_policy" "eks_cluster_namespace_admin_user" {
#   name = "eks_cluster_namespace_admin_policy"
#   path = "/"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "eks:DescribeCluster",
#           "eks:ListClusters"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "eks_cluster_namespace_admin_user" {
#   name       = "eks_cluster_namespace_admin_policy_attachment"
#   users      = [aws_iam_user.eks_cluster_namespace_admin_user.name]
#   policy_arn = aws_iam_policy.eks_cluster_namespace_admin_user.arn
# }

# resource "aws_iam_access_key" "eks_cluster_namespace_admin_user_key" {
#   user = aws_iam_user.eks_cluster_namespace_admin_user.name
# }
