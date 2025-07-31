# 🎯 Pinecone Trading Alerts - Development Makefile

.PHONY: help setup-dev docker-up docker-down run-local test test-integration lint format logs clean deploy-prod

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

## Display this help message
help:
	@echo "$(BLUE)🎯 Pinecone Trading Alerts - Development Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Setup & Development:$(NC)"
	@echo "  $(YELLOW)make setup-dev$(NC)     - Setup development environment"
	@echo "  $(YELLOW)make docker-up$(NC)     - Start all services with Docker"
	@echo "  $(YELLOW)make docker-down$(NC)   - Stop all Docker services"
	@echo "  $(YELLOW)make run-local$(NC)     - Run services locally (no Docker)"
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@echo "  $(YELLOW)make test$(NC)          - Run unit tests"
	@echo "  $(YELLOW)make test-integration$(NC) - Run integration tests"
	@echo "  $(YELLOW)make test-e2e$(NC)       - Run end-to-end tests"
	@echo ""
	@echo "$(GREEN)Code Quality:$(NC)"
	@echo "  $(YELLOW)make lint$(NC)          - Run linting checks"
	@echo "  $(YELLOW)make format$(NC)        - Format code with black/isort"
	@echo "  $(YELLOW)make type-check$(NC)   - Run type checking with mypy"
	@echo ""
	@echo "$(GREEN)Operations:$(NC)"
	@echo "  $(YELLOW)make logs$(NC)          - View logs from all services"
	@echo "  $(YELLOW)make clean$(NC)        - Clean up containers and volumes"
	@echo "  $(YELLOW)make deploy-prod$(NC)   - Deploy to production"
	@echo ""

## Setup development environment
setup-dev:
	@echo "$(BLUE)🔧 Setting up development environment...$(NC)"
	@python3 -m venv venv
	@./venv/bin/pip install --upgrade pip
	@./venv/bin/pip install -r requirements.txt
	@./venv/bin/pip install -r requirements-dev.txt
	@echo "$(GREEN)✅ Development environment ready!$(NC)"
	@echo "$(YELLOW)Run: source venv/bin/activate$(NC)"

## Start all services with Docker
docker-up:
	@echo "$(BLUE)🐳 Starting Docker services...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)✅ Services started!$(NC)"
	@echo "$(YELLOW)View logs: make logs$(NC)"

## Stop all Docker services
docker-down:
	@echo "$(BLUE)🛑 Stopping Docker services...$(NC)"
	@docker-compose down
	@echo "$(GREEN)✅ Services stopped!$(NC)"

## Run services locally (no Docker)
run-local:
	@echo "$(BLUE)🏃 Running services locally...$(NC)"
	@source venv/bin/activate && python -m alert_engine.main

## Run unit tests
test:
	@echo "$(BLUE)🧪 Running unit tests...$(NC)"
	@source venv/bin/activate && pytest tests/unit -v

## Run integration tests
test-integration:
	@echo "$(BLUE)🔗 Running integration tests...$(NC)"
	@source venv/bin/activate && pytest tests/integration -v

## Run end-to-end tests
test-e2e:
	@echo "$(BLUE)🎯 Running end-to-end tests...$(NC)"
	@source venv/bin/activate && pytest tests/e2e -v

## Run all tests
test-all: test test-integration test-e2e

## Run linting checks
lint:
	@echo "$(BLUE)🔍 Running linting checks...$(NC)"
	@source venv/bin/activate && flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	@source venv/bin/activate && flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

## Format code with black and isort
format:
	@echo "$(BLUE)🎨 Formatting code...$(NC)"
	@source venv/bin/activate && black . --line-length=88
	@source venv/bin/activate && isort . --profile black

## Run type checking with mypy
type-check:
	@echo "$(BLUE)🔍 Running type checks...$(NC)"
	@source venv/bin/activate && mypy alert_engine/ bot_services/

## View logs from all services
logs:
	@echo "$(BLUE)📋 Viewing logs...$(NC)"
	@docker-compose logs -f --tail=100

## Clean up containers and volumes
clean:
	@echo "$(BLUE)🧹 Cleaning up...$(NC)"
	@docker-compose down -v
	@docker system prune -f
	@echo "$(GREEN)✅ Cleanup complete!$(NC)"

## Deploy to production
deploy-prod:
	@echo "$(BLUE)🚀 Deploying to production...$(NC)"
	@./scripts/deploy.sh

## Development shortcuts
dev-setup: setup-dev
quick-test: test lint
full-check: lint type-check test

## Database operations
db-init:
	@echo "$(BLUE)🗄️ Initializing database...$(NC)"
	@source venv/bin/activate && python -m alert_engine.database init

db-migrate:
	@echo "$(BLUE)🔄 Running database migrations...$(NC)"
	@source venv/bin/activate && python -m alert_engine.database migrate

db-reset:
	@echo "$(BLUE)🔄 Resetting database...$(NC)"
	@source venv/bin/activate && python -m alert_engine.database reset

## Redis operations
redis-cli:
	@docker-compose exec redis redis-cli

## Health checks
health-check:
	@echo "$(BLUE)🏥 Checking service health...$(NC)"
	@curl -f http://localhost:5000/health || echo "$(RED)❌ API Gateway not healthy$(NC)"
	@curl -f http://localhost:5001/health || echo "$(RED)❌ Discord Bot not healthy$(NC)"
	@curl -f http://localhost:5002/health || echo "$(RED)❌ Telegram Bot not healthy$(NC)"

## Security scan
security-scan:
	@echo "$(BLUE)🔐 Running security scan...$(NC)"
	@source venv/bin/activate && bandit -r alert_engine/ bot_services/
	@source venv/bin/activate && safety check

## Performance test
perf-test:
	@echo "$(BLUE)⚡ Running performance tests...$(NC)"
	@source venv/bin/activate && locust -f tests/performance/locustfile.py --host=http://localhost:5000