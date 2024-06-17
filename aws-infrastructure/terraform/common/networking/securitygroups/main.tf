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

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "vpc.tfstate"
    region = var.region
  }
}

resource "aws_security_group" "sg_backend" {
  description = "Controls access to backend instances"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name = "sg_backend"

  ingress {
    description = "Access to HTTP"
    from_port = 8081
    protocol = "tcp"
    to_port = 8081
    cidr_blocks = [ data.terraform_remote_state.vpc.outputs.vpc_cidr ]
  }

  ingress {
    description = "Access to endpoints"
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [ data.terraform_remote_state.vpc.outputs.vpc_cidr ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = "SG ECS backend"
    }
  )
}



