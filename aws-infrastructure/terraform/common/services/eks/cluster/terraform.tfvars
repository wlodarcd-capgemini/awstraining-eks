vpc_name         = "backend-eks-vpc"
vpc_cidr         = "10.0.0.0/16" # after updating the cidr, always update the public and private cidrs accordingly
public_subnet_cidrs = [
  "10.0.0.0/20",
  "10.0.16.0/20"
]
private_subnet_cidrs = [
  "10.0.32.0/20",
  "10.0.48.0/20"
]
eks_cluster_name    = "backend-eks"
eks_instance_types  = ["t3a.medium"]
eks_number_of_nodes = 1
