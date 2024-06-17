
output "lock_dynamo" {
  description = "The DynamoDB table containing the lock information for Terraform"
  value = var.table_name
}