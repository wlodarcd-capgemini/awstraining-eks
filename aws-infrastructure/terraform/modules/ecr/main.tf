#setup ecr repository
resource "aws_ecr_repository" "ecr_repository" {
  name = var.name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = var.name
    }
  )
}

# adds Lifecycle policy to ecr repository, this allows the automation of cleaning up unused images
# - first rule deletes all untagged images that are older than 14 days
# - second rule deletes all tagged images with prefix "backend-cloud" starting with the oldest,
#   until there is 40 or fewer images remaining that match
resource "aws_ecr_lifecycle_policy" "expire_images" {
  repository = aws_ecr_repository.ecr_repository.name
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 20 tagged images with prefix 'backend'",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": [ "${ var.name }" ],
                "countType": "imageCountMoreThan",
                "countNumber": 20
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}