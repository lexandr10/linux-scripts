output "bucket_name" {
  description = "Ім'я S3 бакета"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "ARN S3 бакета"
  value       = aws_s3_bucket.terraform_state.arn
}

output "table_name" {
  description = "Ім'я DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "table_arn" {
  description = "ARN DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_locks.arn
}

