# All outputs are written to an S3 bucket

output "remote_state_bucket" {
  description = "The S3 Bucket for all Remote States"
  value = var.remote_state_bucket
}