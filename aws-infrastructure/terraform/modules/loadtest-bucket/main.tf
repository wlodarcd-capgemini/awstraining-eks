resource "aws_s3_bucket" "single" {
  bucket = var.bucket
  acl = var.acl
  force_destroy = var.force_destroy

  policy = templatefile("../../../templates/loadtest-result-policy.json.tpl", {
    bucket_name = var.bucket
    vpce_backend = var.vpce_backend
  })
  tags = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_expiration_days
    content {
      enabled = lifecycle_rule.value["enabled"]
      expiration {
        days = lifecycle_rule.value["days"]
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.single.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}