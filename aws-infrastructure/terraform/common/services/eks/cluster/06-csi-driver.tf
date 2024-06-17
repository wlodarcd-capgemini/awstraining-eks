resource "helm_release" "aws_ebs_csi_driver" {
  depends_on = [null_resource.next, module.eks_managed_node_group]
  name       = "aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.28.1"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "enableVolumeResizing"
    value = true
  }
  set {
    name  = "enableVolumeSnapshot"
    value = false
  }

  set {
    name  = "serviceAccount.controller.create"
    value = false
  }

  set {
    name  = "serviceAccount.controller.name"
    value = "ebs-csi-eks"
  }
}
