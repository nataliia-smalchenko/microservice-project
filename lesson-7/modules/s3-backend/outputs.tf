output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = var.bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = var.table_name
}