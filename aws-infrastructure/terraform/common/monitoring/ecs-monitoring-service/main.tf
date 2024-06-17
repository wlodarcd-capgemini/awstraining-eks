provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

terraform {
  backend "s3" {
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "globals" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "globals.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "securitygroups.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs_monitoring_cluster" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "ecs-monitoring-cluster.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "vpc.tfstate"
    region         = var.region
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "ecr.tfstate"
    region         = var.region
  }
}

module "ecs_monitoring_service" {
  source = "../../../modules/ecs-monitoring-service"
  service_name = "backend-monitoring"
  ecs_monitoring_cluster_id = data.terraform_remote_state.ecs_monitoring_cluster.outputs.cluster_id
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets_id
  profile = var.profile
  environment = var.environment
  region= var.region
  common_tags = var.common_tags
  discovery_filter = "application=backend"
  grafana_target_group_arn = data.terraform_remote_state.ecs_monitoring_cluster.outputs.grafana_target_group_arn
  kibana_target_group_arn = data.terraform_remote_state.ecs_monitoring_cluster.outputs.kibana_target_group_arn
  prometheus_target_group_arn = data.terraform_remote_state.ecs_monitoring_cluster.outputs.prometheus_target_group_arn
  sg_monitoring_id = data.terraform_remote_state.ecs_monitoring_cluster.outputs.sg_monitoring_id
  ecr_repository_url = data.terraform_remote_state.ecr.outputs.ecr_monitoring_repository_url
}
