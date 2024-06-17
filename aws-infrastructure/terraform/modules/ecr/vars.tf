variable "name" {
  type        = string
  description = "Name of the ECR repo, prefix for tag"
}

variable "environment" {
  type        = string
  description = "A environment tag that will be added to the resources."
}

variable "common_tags" {}