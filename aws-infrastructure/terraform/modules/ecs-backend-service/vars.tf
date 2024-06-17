# Variables for the ecs-vsn-deployment module
variable "service_name" {
  description = "Name of service to deploy"
}

variable "region" {
  description = "Name of the region on which the service runs"
}

variable "profile" {
  description = "AWS profile name to use for the setup (e.g. ebc-e2e)"
}

variable "account_id" {
  description = "AWS account id"
}

variable "ecs_backend_cluster_id" {
  description = "ECS cluster id generated when creating ECS cluster"
}

variable "service_deployment_desired_task_count" {
  description = "Number of instances of task definition to keep running"
}

variable "service_deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can run during a deployment (percentage of desired count)"
}

variable "service_deployment_minimum_healthy_percent" {
  description = "Minimum percentage of tasks that must be healthy during a deployment (percentage of desired count)"
}

variable "subnets" {
  type = list(string)
  description = "Subnets for ECS instances to run. Property needed for network mode 'awsvpc'"
}

variable "sg_ecs_backend_id" {
  description = "Security group for ECS instances. Property needed for network mode 'awsvpc'"
}

variable "lb_target_group_arn" {
  description = "Target group for backend load balancer "
}

variable "sns_alarm_topic_arn" {
  description = "ARN of the SNS used for alarming by Cloudwatch and to which the Cloudwatch Alertmanager shall listen to"
  type = string
}

variable "ecr_repository_url" {
  description = "URL to the ECR repository"
  type = string
}

variable "hub" {
  description = "HUB"
  type = string
}

variable "environment" {}

variable "common_tags" {}
