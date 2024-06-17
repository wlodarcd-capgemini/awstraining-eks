provider "aws" {
  region                  = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile                 = var.profile
}

terraform {
  backend "s3" {}
}

module "dynamodb_lock" {
  source     = "../../../modules/dynamodb-lock"
  table_name = "backend_tf_lock_remote_dynamo"
  common_tags = var.common_tags
}

