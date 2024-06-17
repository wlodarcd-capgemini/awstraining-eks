resource "null_resource" "next" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --profile ${var.profile} --region ${var.region}"
    interpreter = ["/bin/bash", "-c"]
  }
}
