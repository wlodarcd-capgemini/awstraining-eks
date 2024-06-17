# Base setting for the modules like which credentials are to be used etc.
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

module "vpc" {
  source             = "../../../modules/vpc"
  availability_zones = data.terraform_remote_state.globals.outputs.availability_zones
  environment        = var.environment
  common_tags = var.common_tags
  region = var.region
}


