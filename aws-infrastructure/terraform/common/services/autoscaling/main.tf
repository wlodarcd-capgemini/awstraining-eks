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

module "autoscaling" {
  source = "../../../modules/autoscaling/"
  cluster_name = "backend-ecs-${var.environment}"
  service_name = "backend"
  service_deployment_min_desired_task_count = data.terraform_remote_state.globals.outputs.min_desired_task_count
  service_deployment_max_desired_task_count = data.terraform_remote_state.globals.outputs.max_desired_task_count
  environment = var.environment
  region = var.region
  common_tags = var.common_tags
}