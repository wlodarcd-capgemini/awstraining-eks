variable "environment" {
  description = "Environment to create ECS service in"
  default = "int"
}

variable "region" {
  description = "Region to launch configuration in"
}

# The bucket where the remote states are being stored
variable "remote_state_bucket" {
  description = "Remote state bucket for saving state"
}

variable "profile" {
  description = "Default profile id"
}

variable "shared_credentials_file" {
  description = "Path to cloud credentials"
}

variable "common_tags" {
  type = map(string)
}