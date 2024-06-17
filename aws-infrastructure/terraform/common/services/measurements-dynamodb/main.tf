provider "aws" {
  region                  = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile                 = var.profile
}

terraform {
  backend "s3" {}
}

module "dynamodb_measurements" {
  source     = "../../../modules/measurements-dynamodb"
  table_name = "Measurements"
  common_tags = var.common_tags
}

