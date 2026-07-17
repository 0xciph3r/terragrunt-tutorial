output "replication_id" {
  description = "The ID of the cache replication group."
  value       = aws_elasticache_replication_group.cache_replication_group.id
}
output "replication_endpoint" {
  description = "The primary endpoint of the cache replication group."
  value       = aws_elasticache_replication_group.cache_replication_group.primary_endpoint_address
}

output "reader_endpoint" {
  description = "The primary reader endpoint of the cache replication group."
  value       = aws_elasticache_replication_group.cache_replication_group.reader_endpoint_address
}

output "security_group_id" {
  description = "The ID of the security group created for the cache."
  value       = aws_security_group.cache_sg.id
}