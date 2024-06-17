resource "aws_iam_policy" "eks_lb_controller_policy" {
  depends_on  = [null_resource.next, module.eks_managed_node_group]
  name        = "AmazonEKSLoadBalancerControllerPolicy"
  path        = "/"
  description = "iam policy for the eks load balancer controller"
  policy      = file("${path.module}/../files/lb-controller-policy.json")
}

data "aws_iam_policy_document" "eks_lb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_lb_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.eks_lb_controller_assume_role_policy.json

  tags = merge(local.mandatory_tags, {})
}

resource "aws_iam_role_policy_attachment" "eks_lb_controller_role_policy_attachment" {
  depends_on = [aws_iam_role.eks_lb_controller_role]
  role       = aws_iam_role.eks_lb_controller_role.name
  policy_arn = aws_iam_policy.eks_lb_controller_policy.arn
}


resource "kubernetes_service_account" "lb_controller_sa" {
  depends_on = [aws_iam_role_policy_attachment.eks_lb_controller_role_policy_attachment]
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.eks_lb_controller_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  depends_on = [kubernetes_service_account.lb_controller_sa]
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.7.1"
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "autoDiscoverAwsRegion"
    value = "false"
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = "false"
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
  set {
    name  = "region"
    value = var.region
  }
}
