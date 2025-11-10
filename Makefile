.PHONY: help prereqs dev down logs clean status aws-bootstrap aws-plan aws-deploy aws-destroy aws-outputs

# Default target - show help
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo ""
	@echo "Zero-to-Running Developer Environment"
	@echo "====================================="
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

prereqs: ## Validate prerequisites are installed
	@./scripts/validate-prereqs.sh

dev: ## Start local development environment
	@./scripts/dev.sh

down: ## Stop all services
	@./scripts/down.sh

logs: ## View logs from all services
	@docker compose logs -f

clean: ## Remove all containers, volumes, and images
	@echo "⚠️  This will remove all containers, volumes, and cached data."
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || (echo "Cancelled." && exit 1)
	@echo "Cleaning up..."
	@docker compose down -v
	@docker system prune -f
	@echo "✓ Cleanup complete"

status: ## Show status of all services
	@./scripts/status.sh

# AWS deployment commands
aws-bootstrap: ## Bootstrap AWS infrastructure (one-time setup)
	@echo "🚀 Bootstrapping AWS Terraform backend..."
	@./infra/scripts/bootstrap-terraform.sh

aws-plan: ## Show planned infrastructure changes
	@echo "📋 Planning infrastructure changes..."
	@cd infra/terraform && terraform init && terraform plan

aws-deploy: ## Deploy application to AWS
	@echo "🚀 Deploying to AWS..."
	@./infra/scripts/deploy.sh

aws-destroy: ## Destroy all AWS infrastructure
	@echo "⚠️  WARNING: This will destroy all AWS resources!"
	@read -p "Are you sure? Type 'destroy' to confirm: " confirm && [ "$$confirm" = "destroy" ] || (echo "Cancelled." && exit 1)
	@echo "💥 Destroying AWS infrastructure..."
	@cd infra/terraform && terraform destroy

aws-outputs: ## Show Terraform outputs (ALB URL, ECR repos, etc.)
	@echo "📤 Terraform Outputs:"
	@cd infra/terraform && terraform output

