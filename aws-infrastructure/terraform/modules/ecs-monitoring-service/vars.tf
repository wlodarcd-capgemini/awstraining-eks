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

variable "ecs_monitoring_cluster_id" {
  description = "ECS cluster id generated when creating ECS cluster"
}

variable "subnets" {
  type = list(string)
  description = "Subnets for ECS instances to run."
}

variable "sg_monitoring_id" {
  description = "Security group for ECS instances."
}

variable "kibana_target_group_arn" {
  description = "Target group for Kibana monitoring"
}

variable "prometheus_target_group_arn" {
  description = "Target group for Prometheus monitoring"
}

variable "grafana_target_group_arn" {
  description = "Target group for Grafana monitoring"
}

variable "discovery_filter" {
  description = "The filter to set for discovering ECS instances to scrape"
  type = string
}

variable "ecr_repository_url" {
  description = "URL to Monitoring ECR"
  type = string
}

variable "environment" {}

variable "common_tags" {}