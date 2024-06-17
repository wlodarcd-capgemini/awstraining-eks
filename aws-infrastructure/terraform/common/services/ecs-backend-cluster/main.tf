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

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "vpc.tfstate"
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

module "ecs_backend_cluster" {
  source = "../../../modules/ecs-backend-cluster"
  ecs_cluster_name = "backend-ecs-${var.environment}"
  aws_vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  environment = var.environment
  common_tags = var.common_tags
  region = var.region
  backend_service_deployment_desired_task_count = data.terraform_remote_state.globals.outputs.backend_service_deployment_desired_task_count
  sns_alarm_topic_arn = data.terraform_remote_state.sns.outputs.sns_alarm_cloudwatch_topic_arn
  public_subnets_id = data.terraform_remote_state.vpc.outputs.public_subnets_id
}
