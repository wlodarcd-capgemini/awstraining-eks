output "ecr_repository_url" {
  description = "The repo URL for ECR"
  value = aws_ecr_repository.ecr_repository.repository_url
}