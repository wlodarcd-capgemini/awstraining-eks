variable "vpc_id" {
  description = "The VPC id"
}

variable "subnet_ids" {
  description = "The IDs of subnets in which to create a network interface for the endpoint"
}

variable "security_group_ids" {
  description = "One or more security group IDs"
}

variable "endpoints" {
  description = "Names vpce"
}

variable "common_tags" {}