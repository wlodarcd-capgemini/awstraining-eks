provider "aws" {
  region                  = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile                 = var.profile
}

module "remote_state_bucket" {
  source = "../../../modules/remote-state-bucket"
  remote_state_bucket = var.remote_state_bucket
  common_tags = var.common_tags
}


