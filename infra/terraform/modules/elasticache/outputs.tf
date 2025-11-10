output "endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
  sensitive   = true
}

output "port" {
  description = "ElastiCache Redis port"
  value       = aws_elasticache_cluster.main.cache_nodes[0].port
}

output "cluster_id" {
  description = "ID of the ElastiCache cluster"
  value       = aws_elasticache_cluster.main.cluster_id
}

output "security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.redis.id
}

