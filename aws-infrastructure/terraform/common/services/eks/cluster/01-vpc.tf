module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.0"

  name                    = var.vpc_name
  cidr                    = var.vpc_cidr
  azs                     = local.azs
  private_subnets         = var.private_subnet_cidrs
  public_subnets          = var.public_subnet_cidrs
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  tags = merge(local.mandatory_tags, {})
}
