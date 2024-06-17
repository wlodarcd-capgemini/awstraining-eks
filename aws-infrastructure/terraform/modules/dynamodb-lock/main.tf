
# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb_terraform_state_lock" {
  name = var.table_name
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
 
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = "DynamoDB Terraform State Lock Table"
    }
  )
}
