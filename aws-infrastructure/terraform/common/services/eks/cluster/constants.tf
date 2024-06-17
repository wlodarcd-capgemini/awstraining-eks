locals {
  mandatory_tags = {
    managed_by = "terraform"
    module     = "training"
  }
  azs                 = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
  eks_cluster_version = 1.29
}
