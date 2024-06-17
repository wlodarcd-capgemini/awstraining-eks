module "eks_managed_node_group" {
  source     = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version    = "~> 20.5.0"
  depends_on = [null_resource.next]

  name                              = "default"
  cluster_name                      = var.eks_cluster_name
  cluster_version                   = local.eks_cluster_version
  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]
  iam_role_additional_policies = {
    ebs = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  min_size     = var.eks_number_of_nodes
  max_size     = var.eks_number_of_nodes
  desired_size = var.eks_number_of_nodes

  instance_types = var.eks_instance_types
  capacity_type  = "ON_DEMAND"

  tags = merge(local.mandatory_tags, {})
}
