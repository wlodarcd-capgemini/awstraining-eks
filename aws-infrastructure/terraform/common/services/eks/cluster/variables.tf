variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_instance_types" {
  type = list(string)
}

variable "eks_number_of_nodes" {
  type = number
}
