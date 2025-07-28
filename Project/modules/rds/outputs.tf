# RDS Endpoint (POSTGRES_HOST)
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

# RDS Port (POSTGRES_PORT)
output "rds_port" {
  description = "RDS instance port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.standard[0].port
}

# Database Name (POSTGRES_NAME)
output "rds_db_name" {
  description = "RDS database name"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].database_name : aws_db_instance.standard[0].db_name
}

# Master Username (POSTGRES_USER)
output "rds_username" {
  description = "RDS master username"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].master_username : aws_db_instance.standard[0].username
}

# Additional useful outputs
output "rds_id" {
  description = "RDS identifier"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].cluster_identifier : aws_db_instance.standard[0].identifier
}

output "rds_arn" {
  description = "RDS ARN"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].arn : aws_db_instance.standard[0].arn
}

# Aurora-specific outputs
output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "aurora_writer_instance_id" {
  description = "Aurora writer instance identifier"
  value       = var.use_aurora ? aws_rds_cluster_instance.aurora_writer[0].identifier : null
}

output "aurora_reader_instance_ids" {
  description = "Aurora reader instance identifiers"
  value       = var.use_aurora ? aws_rds_cluster_instance.aurora_readers[*].identifier : []
}

# Security Group ID
output "security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

# Subnet Group Name
output "subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.default.name
}