# Local variables
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags        = local.common_tags
}

# ECR Repositories Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

# RDS PostgreSQL Module
module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  allowed_cidr_blocks  = [var.vpc_cidr]
  common_tags          = local.common_tags
}

# ElastiCache Redis Module
module "elasticache" {
  source = "./modules/elasticache"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  redis_node_type       = var.redis_node_type
  redis_num_cache_nodes = var.redis_num_cache_nodes
  allowed_cidr_blocks   = [var.vpc_cidr]
  common_tags           = local.common_tags
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  allowed_cidr_blocks = ["0.0.0.0/0"]
  common_tags        = local.common_tags
}

# ECS Cluster and Services Module
module "ecs" {
  source = "./modules/ecs"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  api_image              = var.api_image != "" ? var.api_image : "${module.ecr.api_repository_url}:latest"
  frontend_image         = var.frontend_image != "" ? var.frontend_image : "${module.ecr.frontend_repository_url}:latest"
  api_cpu                = var.api_cpu
  api_memory             = var.api_memory
  frontend_cpu           = var.frontend_cpu
  frontend_memory        = var.frontend_memory
  desired_count          = var.desired_count
  min_capacity           = var.min_capacity
  max_capacity           = var.max_capacity
  alb_target_group_api_arn      = module.alb.api_target_group_arn
  alb_target_group_frontend_arn = module.alb.frontend_target_group_arn
  db_host                = module.rds.endpoint
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  redis_host             = module.elasticache.endpoint
  redis_port             = module.elasticache.port
  common_tags            = local.common_tags

  depends_on = [
    module.rds,
    module.elasticache,
    module.alb
  ]
}

