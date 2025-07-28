output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_db_name" {
  description = "Database name for the RDS instance"
  value       = module.rds.rds_db_name
}

output "rds_username" {
  description = "Master username for the RDS instance"
  value       = module.rds.rds_username
}

output "rds_port" {
  description = "Port for the RDS instance"
  value       = module.rds.rds_port
}