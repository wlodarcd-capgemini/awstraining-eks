variable "ecs_cluster_name" {
  description = "ECS cluster name"
}

variable "vpc_id" {
  description = "ID of the VPC in which the Prometheus should be created in "
  type = string
}

variable "desired_capacity" {
  description = "Desired size of the auto scaling group"
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the auto scaling group"
  default     = 3
}

variable "min_size" {
  description = "Minimal size of the auto scaling group"
  default     = 2
}

variable "subnets" {
  description = "Subnets of VPC where to create public load balancer"
  type        = list(string)
}

variable "hub" {
  description = "The Hub in which the Prometheus instance runs in"
  type = string
}

variable "environment" {}
variable "region" {}


variable "common_tags" {}