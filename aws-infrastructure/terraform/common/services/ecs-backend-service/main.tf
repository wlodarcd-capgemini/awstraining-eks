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

data "terraform_remote_state" "ecs_backend_cluster" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "ecs-backend-cluster.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "sns" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "sns.tfstate"
    region         = var.region
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

module "ecs_backend_service" {
  source = "../../../modules/ecs-backend-service"
  service_name = "backend"
  service_deployment_desired_task_count = data.terraform_remote_state.globals.outputs.backend_service_deployment_desired_task_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 50
  ecs_backend_cluster_id = data.terraform_remote_state.ecs_backend_cluster.outputs.cluster_id
  lb_target_group_arn = data.terraform_remote_state.ecs_backend_cluster.outputs.backend_ecs_lb_target_group_arn
  sg_ecs_backend_id = data.terraform_remote_state.security_groups.outputs.sg_backend_id
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets_id
  profile = var.profile
  environment = var.environment
  region= var.region
  account_id = data.terraform_remote_state.globals.outputs.account_id
  common_tags = var.common_tags
  sns_alarm_topic_arn = data.terraform_remote_state.sns.outputs.sns_alarm_cloudwatch_topic_arn
  ecr_repository_url = data.terraform_remote_state.ecr.outputs.ecr_repository_url
  hub = data.terraform_remote_state.globals.outputs.hub
}

module "specific_endpoints" {
  source = "../../../modules/vpc-endpoints"
  common_tags = var.common_tags
  security_group_ids = [ data.terraform_remote_state.security_groups.outputs.sg_backend_id ]
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets_id
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  endpoints = data.terraform_remote_state.globals.outputs.endpoints
}
