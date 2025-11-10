# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.dns_name
}

output "alb_url" {
  description = "Full URL of the Application Load Balancer"
  value       = "http://${module.alb.dns_name}"
}

output "api_url" {
  description = "API endpoint URL"
  value       = "http://${module.alb.dns_name}/api"
}

# ECR Outputs
output "ecr_api_repository_url" {
  description = "URL of the API ECR repository"
  value       = module.ecr.api_repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.ecr.frontend_repository_url
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.rds.database_name
}

# Cache Outputs
output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.elasticache.endpoint
  sensitive   = true
}

output "redis_port" {
  description = "ElastiCache Redis port"
  value       = module.elasticache.port
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_api_service_name" {
  description = "Name of the API ECS service"
  value       = module.ecs.api_service_name
}

output "ecs_frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = module.ecs.frontend_service_name
}

