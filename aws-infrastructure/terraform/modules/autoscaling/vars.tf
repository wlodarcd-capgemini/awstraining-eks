variable "cluster_name" {
  description = "ECS cluster name"
}

variable "service_name" {
  description = "Name of service to deploy"
}

variable "service_deployment_min_desired_task_count" {
  description = "Number of instances of task definition to keep running"
}

variable "service_deployment_max_desired_task_count" {
  description = "Maximal number of instances of task definition to scale up to"
}

variable "environment" {}

variable "region" {}

variable "common_tags" {}