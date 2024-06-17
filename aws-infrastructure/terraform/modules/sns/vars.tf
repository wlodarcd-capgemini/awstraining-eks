variable "environment" {
  description = "Environment name"
}

variable "region" {
  description = "AWS region"
}

variable "account_id" {
  description = "Account Id used"
}

variable "profile" {
    description = "Default profile id"
}

variable "notification_email" {
  description = "Email address for alarms"
  default = [
    "piotr.strojek@capgemini.com",
    "damian.cywinski@capgemini.com"
  ]
}

variable "common_tags" {}