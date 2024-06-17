provider "aws" {
  region                  = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile                 = var.profile
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

module "sns_email" {
  source             = "../../../modules/sns"
  region             = var.region
  environment        = var.environment
  profile            = var.profile
  account_id         = data.terraform_remote_state.globals.outputs.account_id
  common_tags = var.common_tags
}

