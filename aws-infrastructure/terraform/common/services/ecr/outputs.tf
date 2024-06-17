output "ecr_repository_url" {
  description = "The repo URL for backend ECR"
  value = module.ecr_backend.ecr_repository_url
}

output "ecr_monitoring_repository_url" {
  description = "The repo URL for Monitoring ECR"
  value = module.ecr_monitoring.ecr_repository_url
}