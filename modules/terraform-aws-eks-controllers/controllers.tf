resource "helm_release" "aws_alb_controller" {
  name            = lookup(var.helm_charts.alb, "name", "aws-load-balancer-controller")
  chart           = lookup(var.helm_charts.alb, "chart", "aws-load-balancer-controller")
  version         = lookup(var.helm_charts.alb, "version", null)
  repository      = lookup(var.helm_charts.alb, "repository", "https://aws.github.io/eks-charts")
  namespace       = lookup(var.helm_charts.alb, "namespace", "kube-system")
  cleanup_on_fail = lookup(var.helm_charts.alb, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({
      "clusterName"                                               = var.cluster_name
      "serviceAccount.name"                                       = lookup(var.helm_charts.alb, "serviceaccount", "aws-load-balancer-controller")
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.eks_aws_load_balancer_controller_service_account_iam_role.arn
    }, lookup(var.helm_charts.alb, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "aws_external_dns_controller" {
  name            = lookup(var.helm_charts.external_dns, "name", "external-dns")
  chart           = lookup(var.helm_charts.external_dns, "chart", "external-dns")
  version         = lookup(var.helm_charts.external_dns, "version", null)
  repository      = lookup(var.helm_charts.external_dns, "repository", "https://kubernetes-sigs.github.io")
  namespace       = lookup(var.helm_charts.external_dns, "namespace", "kube-system")
  cleanup_on_fail = lookup(var.helm_charts.external_dns, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({
      "clusterName"                                               = var.cluster_name
      "serviceAccount.name"                                       = lookup(var.helm_charts.external_dns, "serviceaccount", "aws-external-dns-controller")
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.eks_external_dns_controller_service_account_iam_role.arn
      "policy"                                                    = lookup(var.helm_charts.external_dns, "policy", "sync")
    }, lookup(var.helm_charts.external_dns, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}