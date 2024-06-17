variable "name" {
  description = "resource name"
}

variable "region" {
  description = "Name of the region on which the service runs"
}

variable "sg_ecs_backend_id" {
  description = "Security group for FARGATE instances. Property needed for network mode 'awsvpc'"
}

variable "subnets" {
  description = "Subnets for auto scaling group where EC2 instances are spawned"
  type        = list(string)
}

variable "ecr_loadtest_url" {
  description = "ECR Url Loadtest"
}

variable "ecr_loadtest_image_tag" {
  description = "Name of the image tag of loadtest ECR"
}

variable "service_deployment_desired_task_count" {
  description = "Number of instances of task definition to keep running"
}

variable "ecs_loadtest_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "ecs_loadtest_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "load_test_result_bucket_name" {
  description = "bucket name for load test results"
}

variable "load_test_url" {
  description = "URL for Load Tests"
}

variable "environment" {}


variable "common_tags" {}
