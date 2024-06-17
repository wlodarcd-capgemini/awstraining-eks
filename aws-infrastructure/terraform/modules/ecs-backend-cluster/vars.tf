variable "ecs_cluster_name" {
  description = "ECS cluster name"
}

variable "aws_vpc_id" {
  description = "VPC AWS id"
}

variable "public_subnets_id" {
  description = "Public subnets id"
  type        = list(string)
}

variable "backend_service_deployment_desired_task_count" {
  description = "Desired count of running backend tasks"
}

variable "sns_alarm_topic_arn" {
  description = "ARN of the SNS used for alarming by Cloudwatch and to which the Cloudwatch Alertmanager shall listen to"
  type = string
}

variable "environment" {}
variable "region" {}

variable "common_tags" {}