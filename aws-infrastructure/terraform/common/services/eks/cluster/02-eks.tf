module "eks" {
  source     = "terraform-aws-modules/eks/aws"
  version    = "~> 20.5.0"
  depends_on = [module.vpc]

  cluster_name    = var.eks_cluster_name
  cluster_version = local.eks_cluster_version

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.public_subnets
  enable_cluster_creator_admin_permissions = true

  node_security_group_additional_rules = {
    allowPublicSubnet = {
      description = "allow traffic from public subnets"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = var.public_subnet_cidrs
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = merge(local.mandatory_tags, {})
}
