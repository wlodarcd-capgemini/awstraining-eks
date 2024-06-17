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
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "vpc.tfstate"
    region         = var.region
  }
}

module "ecs_monitoring_cluster" {
  source = "../../../modules/ecs-monitoring-cluster"
  ecs_cluster_name = "backend-monitoring-ecs-${var.environment}"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  environment = var.environment
  common_tags = var.common_tags
  subnets = data.terraform_remote_state.vpc.outputs.public_subnets_id
  region = var.region
  hub = data.terraform_remote_state.globals.outputs.hub
}
