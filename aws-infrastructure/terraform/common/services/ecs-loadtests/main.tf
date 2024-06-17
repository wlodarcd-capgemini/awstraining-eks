provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile                 = var.profile
}

provider "template" {
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

data "terraform_remote_state" "ecs_backend_cluster" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "ecs-backend-cluster.tfstate"
    region         = var.region
  }
}

data "aws_vpc_endpoint" "vpc_endpoint_gateway" {
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "securitygroups.tfstate"
    region = var.region
  }
}

module "backend_load_test_result_bucket" {
  bucket = "backend-load-test-result-${data.terraform_remote_state.globals.outputs.account_id}"
  vpce_backend = data.aws_vpc_endpoint.vpc_endpoint_gateway.id
  tags = var.common_tags
  source = "../../../modules/loadtest-bucket"
  region = var.region
  environment = var.environment
}

module "ecr_loadtest" {
  source = "../../../modules/ecr/"
  name = "backend-loadtest"
  environment = var.environment
  common_tags = var.common_tags
}

module "ecs_loadtest" {
  source = "../../../modules/ecs-loadtest/"
  name = "backend-loadtest"
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets_id
  environment = var.environment
  region = var.region
  sg_ecs_backend_id = data.terraform_remote_state.security_groups.outputs.sg_backend_id
  service_deployment_desired_task_count = 0
  load_test_result_bucket_name = module.backend_load_test_result_bucket.name
  load_test_url = "http://${data.terraform_remote_state.ecs_backend_cluster.outputs.load_balancer_dns}"
  common_tags = var.common_tags
  ecr_loadtest_image_tag = "latest"
  ecr_loadtest_url = module.ecr_loadtest.ecr_repository_url
}

