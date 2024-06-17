resource "aws_dynamodb_table" "dynamodb_measurements" {
  name = var.table_name
  hash_key = "deviceId"
  range_key = "creationTime"
  billing_mode = "PAY_PER_REQUEST"
 
  attribute {
    name = "deviceId"
    type = "S"
  }

  attribute {
    name = "creationTime"
    type = "N"
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = "DynamoDB Measurements Table"
    }
  )
}
