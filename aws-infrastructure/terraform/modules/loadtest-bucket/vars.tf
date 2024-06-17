variable "bucket" {
  type = string
  description = "Bucket name"
}

variable "tags" {
  type = map(string)
  description = "Pass common tags here along with any additionals (using merge)"
}

variable "region" {
  type = string
  description = "Bucket region"
}

variable "environment" {
  description = "Environment in which this resource is created (e.g. e2e)"
}

variable "acl" {
  type = string
  description = "ACL type of a bucket [private/public]"
  default = "private"
}

variable "force_destroy" {
  type = string
  description = "Determines if the bucket has to be empty before it can be removed"
  default = "false"
}

variable "lifecycle_expiration_days" {
  description = "This activates the lifecycle for the S3 bucket. If no value is provided the lifecycle is disabled"
  type = list(object({
    enabled = string
    days = number
  }))

  default = []
}

variable "vpce_backend" {
  description = "VPCE backend"
  type = string
}