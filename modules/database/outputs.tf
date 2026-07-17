output "aws_database_endpoint" {
  description = "The endpoint of the AWS database instance."
  value       = aws_db_instance.database_instance.endpoint
}
output "aws_database_port" {
  description = "The port of the AWS database instance."
  value       = aws_db_instance.database_instance.port
}

output "aws_db_instance_id" {
  description = "The ID of the AWS database instance."
  value       = aws_db_instance.database_instance.id
}

output "aws_db_security_group_id" {
  description = "The ID of the security group created for the AWS database."
  value       = aws_security_group.database_sg.id
}