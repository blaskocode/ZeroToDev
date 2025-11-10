variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "api_image" {
  description = "Docker image for API service"
  type        = string
}

variable "frontend_image" {
  description = "Docker image for frontend service"
  type        = string
}

variable "api_cpu" {
  description = "CPU units for API task"
  type        = number
  default     = 256
}

variable "api_memory" {
  description = "Memory (MiB) for API task"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU units for frontend task"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory (MiB) for frontend task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 3
}

variable "alb_target_group_api_arn" {
  description = "ARN of the ALB target group for API"
  type        = string
}

variable "alb_target_group_frontend_arn" {
  description = "ARN of the ALB target group for frontend"
  type        = string
}

variable "db_host" {
  description = "Database host endpoint"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "redis_host" {
  description = "Redis host endpoint"
  type        = string
  sensitive   = true
}

variable "redis_port" {
  description = "Redis port"
  type        = number
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

