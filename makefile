.PHONY: help build start stop restart logs status clean test shell bash migrate makemigrations format lint check deploy

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

##@ General

help: ## Display this help message
	@echo "$(BLUE)ChiefOnboarding - Docker Compose Makefile$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(CYAN)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Compose

build: ## Build or rebuild services
	@echo "$(GREEN)Building Docker containers...$(NC)"
	docker compose build

build-no-cache: ## Build without using cache
	@echo "$(GREEN)Building Docker containers (no cache)...$(NC)"
	docker compose build --no-cache

start: ## Start services in detached mode
	@echo "$(GREEN)Starting services...$(NC)"
	docker compose up -d
	@echo "$(GREEN)✓ Services started. Access at http://localhost:9000$(NC)"

up: start ## Alias for start

local: ## Start services in foreground (with logs)
	@echo "$(GREEN)Starting services in foreground...$(NC)"
	docker compose up

stop: ## Stop services
	@echo "$(YELLOW)Stopping services...$(NC)"
	docker compose stop
	@echo "$(GREEN)✓ Services stopped$(NC)"

down: ## Stop and remove containers, networks
	@echo "$(YELLOW)Stopping and removing containers...$(NC)"
	docker compose down
	@echo "$(GREEN)✓ Containers removed$(NC)"

down-volumes: ## Stop and remove containers, networks, and volumes (DESTRUCTIVE)
	@echo "$(RED)⚠ WARNING: This will delete all database data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		echo "$(GREEN)✓ Containers and volumes removed$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

restart: ## Restart services
	@echo "$(YELLOW)Restarting services...$(NC)"
	docker compose restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

restart-web: ## Restart only web service
	@echo "$(YELLOW)Restarting web service...$(NC)"
	docker compose restart web
	@echo "$(GREEN)✓ Web service restarted$(NC)"

ps: status ## Alias for status

status: ## Show status of services
	@echo "$(BLUE)Container Status:$(NC)"
	@docker compose ps

logs: ## Show logs from all services
	docker compose logs -f

logs-web: ## Show logs from web service only
	docker compose logs -f web

logs-db: ## Show logs from database service only
	docker compose logs -f db

##@ Database

migrate: ## Run database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	docker compose exec web python manage.py migrate
	@echo "$(GREEN)✓ Migrations complete$(NC)"

makemigrations: ## Create new database migrations
	@echo "$(GREEN)Creating migrations...$(NC)"
	docker compose exec web python manage.py makemigrations
	@echo "$(GREEN)✓ Migrations created$(NC)"

dbshell: ## Open database shell
	docker compose exec web python manage.py dbshell

db-backup: ## Backup database to file
	@echo "$(GREEN)Creating database backup...$(NC)"
	@mkdir -p backups
	docker compose exec db pg_dump -U postgres postgres > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Backup created in backups/$(NC)"

db-restore: ## Restore database from latest backup (DESTRUCTIVE)
	@echo "$(RED)⚠ WARNING: This will replace current database!$(NC)"
	@read -p "Enter backup file path: " filepath; \
	if [ -f "$$filepath" ]; then \
		docker compose exec -T db psql -U postgres postgres < "$$filepath"; \
		echo "$(GREEN)✓ Database restored$(NC)"; \
	else \
		echo "$(RED)✗ File not found$(NC)"; \
	fi

##@ Development

shell: ## Open Django shell
	docker compose exec web python manage.py shell

bash: ## Open bash shell in web container
	docker compose exec web bash

createsuperuser: ## Create Django superuser
	docker compose exec web python manage.py createsuperuser

collectstatic: ## Collect static files
	docker compose exec web python manage.py collectstatic --noinput

##@ Testing & Quality

test: ## Run pytest tests
	@echo "$(GREEN)Running tests...$(NC)"
	docker compose exec web pytest
	@echo "$(GREEN)✓ Tests complete$(NC)"

test-verbose: ## Run tests with verbose output
	docker compose exec web pytest -v

test-coverage: ## Run tests with coverage report
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	docker compose exec web pytest --cov=. --cov-report=html
	@echo "$(GREEN)✓ Coverage report generated in htmlcov/$(NC)"

lint: ## Run ruff linter
	@echo "$(GREEN)Running linter...$(NC)"
	docker compose exec web ruff check .

format: ## Format code with ruff
	@echo "$(GREEN)Formatting code...$(NC)"
	docker compose exec web ruff format .
	docker compose exec web ruff check . --fix
	@echo "$(GREEN)✓ Code formatted$(NC)"

check: lint test ## Run linter and tests

##@ Dependency Management

lock: ## Lock dependencies with pipenv
	docker compose exec web pipenv lock

install: ## Install dependencies
	docker compose exec web pipenv install

install-dev: ## Install dev dependencies
	docker compose exec web pipenv install --dev

update-deps: ## Update dependencies
	docker compose exec web pipenv update

##@ Utilities

clean: ## Remove Python cache files and artifacts
	@echo "$(YELLOW)Cleaning cache files...$(NC)"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓ Cache cleaned$(NC)"

clean-all: clean down-volumes ## Clean everything including Docker volumes (DESTRUCTIVE)
	@echo "$(GREEN)✓ Everything cleaned$(NC)"

setup: ## Initial setup - build and start services
	@echo "$(GREEN)Setting up ChiefOnboarding...$(NC)"
	@$(MAKE) build
	@$(MAKE) start
	@sleep 5
	@$(MAKE) migrate
	@echo "$(GREEN)✓ Setup complete! Access at http://localhost:9000$(NC)"

reset: ## Reset everything and start fresh (DESTRUCTIVE)
	@echo "$(RED)⚠ WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) down-volumes; \
		$(MAKE) clean; \
		$(MAKE) setup; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

urls: ## Show service URLs
	@echo "$(BLUE)Service URLs:$(NC)"
	@echo "  Web:      http://localhost:9000"
	@echo "  Admin:    http://localhost:9000/admin"
	@echo "  Database: localhost:5432"

health: ## Check service health
	@echo "$(BLUE)Service Health Check:$(NC)"
	@docker compose ps | grep -q "Up" && echo "$(GREEN)✓ Services are running$(NC)" || echo "$(RED)✗ Services are not running$(NC)"
	@curl -s -o /dev/null -w "  Web: %{http_code}\n" http://localhost:9000 || echo "  Web: $(RED)DOWN$(NC)"

info: ## Show system information
	@echo "$(BLUE)System Information:$(NC)"
	@echo "  Docker version: $$(docker --version)"
	@echo "  Docker Compose version: $$(docker compose version)"
	@echo "  Running containers: $$(docker compose ps --quiet | wc -l)"
	@echo "  Database size: $$(docker compose exec -T db psql -U postgres -c "SELECT pg_size_pretty(pg_database_size('postgres'));" -t 2>/dev/null | xargs || echo 'N/A')"

##@ Quick Actions

quick-restart: restart-web ## Quick restart (web service only)

deploy: ## Deploy (stop, pull, build, start, migrate)
	@echo "$(GREEN)Deploying updates...$(NC)"
	@$(MAKE) stop
	@git pull
	@$(MAKE) build
	@$(MAKE) start
	@sleep 3
	@$(MAKE) migrate
	@$(MAKE) collectstatic
	@echo "$(GREEN)✓ Deployment complete$(NC)"
