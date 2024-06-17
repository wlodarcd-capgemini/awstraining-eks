variable "environment" {
  description = "Environment in which this resource is created (e.g. e2e)"
}

variable "region" {
  description = "Region to launch configuration in"
}

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