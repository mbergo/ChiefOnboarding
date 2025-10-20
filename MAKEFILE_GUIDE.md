# Makefile Guide - ChiefOnboarding

## Overview

This Makefile provides convenient shortcuts for common Docker Compose operations, development tasks, and deployment workflows for ChiefOnboarding.

## Quick Start

```bash
# Show all available commands
make help

# Initial setup (first time)
make setup

# Start services
make start

# Stop services
make stop

# Restart services
make restart
```

## Categories

### 📦 Docker Compose Operations

#### Building

```bash
make build              # Build or rebuild Docker images
make build-no-cache     # Build without using cache (clean build)
```

#### Starting & Stopping

```bash
make start              # Start services in background (detached mode)
make up                 # Alias for 'start'
make local              # Start in foreground (shows logs)
make stop               # Stop all services
make down               # Stop and remove containers/networks
make down-volumes       # ⚠️ DESTRUCTIVE: Stop and remove volumes (deletes data!)
```

#### Monitoring

```bash
make status             # Show container status
make ps                 # Alias for 'status'
make logs               # Follow logs from all services
make logs-web           # Follow logs from web service only
make logs-db            # Follow logs from database only
```

#### Restarting

```bash
make restart            # Restart all services
make restart-web        # Restart only web service (faster)
make quick-restart      # Alias for restart-web
```

### 🗄️ Database Operations

```bash
make migrate            # Run database migrations
make makemigrations     # Create new migrations
make dbshell            # Open PostgreSQL shell
make db-backup          # Create database backup (saved to backups/)
make db-restore         # Restore database from backup file
```

**Database Backup Example:**
```bash
# Create backup
make db-backup
# Creates: backups/backup_20251020_150000.sql

# Restore from backup
make db-restore
# Enter backup file path: backups/backup_20251020_150000.sql
```

### 👨‍💻 Development

```bash
make shell              # Open Django Python shell
make bash               # Open bash shell in web container
make createsuperuser    # Create Django admin user
make collectstatic      # Collect static files for production
```

**Example Workflows:**

```bash
# Create a superuser
make createsuperuser
# Follow prompts to create admin account

# Open Django shell for testing
make shell
>>> from admin.to_do.models import ToDo
>>> ToDo.objects.count()
```

### 🧪 Testing & Quality

```bash
make test               # Run pytest tests
make test-verbose       # Run tests with verbose output
make test-coverage      # Run tests with HTML coverage report
make lint               # Run ruff linter
make format             # Auto-format code with ruff
make check              # Run both linter and tests
```

**Testing Workflow:**
```bash
# Before committing changes
make format             # Format code
make check              # Lint and test
```

### 📦 Dependency Management

```bash
make lock               # Lock dependencies (update Pipfile.lock)
make install            # Install dependencies
make install-dev        # Install dev dependencies
make update-deps        # Update all dependencies
```

**Adding New Packages:**
```bash
# Add package to Pipfile manually, then:
make lock
make install
make restart
```

### 🛠️ Utilities

```bash
make clean              # Remove Python cache files
make clean-all          # ⚠️ Clean everything (including volumes)
make setup              # Initial setup (build + start + migrate)
make reset              # ⚠️ DESTRUCTIVE: Reset everything and start fresh
make urls               # Show service URLs
make health             # Check service health
make info               # Show system information
```

### 🚀 Deployment

```bash
make deploy             # Full deployment workflow:
                        # 1. Stop services
                        # 2. Pull latest git changes
                        # 3. Build containers
                        # 4. Start services
                        # 5. Run migrations
                        # 6. Collect static files
```

## Common Workflows

### First Time Setup

```bash
# Clone repository
git clone <repo-url>
cd ChiefOnboarding

# Initial setup
make setup

# Create admin user
make createsuperuser

# Access application
open http://localhost:8600
```

### Daily Development

```bash
# Morning: Start services
make start

# Make code changes...

# Test changes
make test

# Check code quality
make format
make lint

# Restart if needed
make restart-web

# Evening: Stop services
make stop
```

### Database Migration Workflow

```bash
# 1. Make model changes in Python code

# 2. Create migrations
make makemigrations

# 3. Review migration files
# (check back/*/migrations/)

# 4. Apply migrations
make migrate

# 5. Test in shell
make shell
```

### Updating Dependencies

```bash
# Edit Pipfile manually to add/update packages

# Lock dependencies
make lock

# Install new packages
make install

# Rebuild containers
make build

# Restart
make restart
```

### Deployment Workflow

```bash
# Production deployment
git pull
make deploy

# Or step by step:
make stop
git pull
make build
make start
make migrate
make collectstatic
```

### Troubleshooting

```bash
# Check service status
make status

# View logs
make logs

# View web logs only
make logs-web

# Check health
make health

# Get system info
make info

# Restart everything
make restart

# Nuclear option - fresh start
make reset  # ⚠️ WARNING: Deletes all data!
```

### Database Backup & Restore

```bash
# Regular backup (do this often!)
make db-backup

# Restore from specific backup
make db-restore
# Enter path when prompted: backups/backup_20251020_120000.sql
```

## Environment-Specific Commands

### Development

```bash
make local              # Run in foreground with logs
make shell              # Django shell for testing
make test-coverage      # Check test coverage
```

### Production

```bash
make start              # Run in background
make deploy             # Full deployment
make db-backup          # Regular backups
make health             # Monitor health
```

## Safety Features

### Destructive Commands Require Confirmation

Commands that delete data will ask for confirmation:

```bash
make down-volumes
# Output: ⚠ WARNING: This will delete all database data!
# Are you sure? [y/N]

make reset
# Output: ⚠ WARNING: This will delete all data!
# Are you sure? [y/N]
```

### Color-Coded Output

- 🟢 **Green**: Success messages
- 🟡 **Yellow**: Warning messages
- 🔴 **Red**: Error/destructive action warnings
- 🔵 **Blue**: Informational messages

## Advanced Usage

### Custom Docker Compose

The Makefile uses `docker compose` commands. If you need to pass custom flags:

```bash
# Use Docker Compose directly
docker compose up -d --scale web=2

# Or modify Makefile targets
```

### Combining Commands

```bash
# Stop, clean, and fresh start
make stop && make clean && make start

# Deploy with backup first
make db-backup && make deploy
```

### Checking Specific Services

```bash
# Status
docker compose ps web

# Logs
docker compose logs -f web

# Restart
docker compose restart web
```

## Tips & Best Practices

1. **Use `make help`** - When in doubt, check available commands

2. **Backup before major changes** - Always run `make db-backup` before:
   - Running migrations
   - Deploying
   - Testing destructive operations

3. **Use `make quick-restart`** - Faster than full restart for code changes

4. **Check logs** - Use `make logs-web` to troubleshoot issues

5. **Format before commit** - Run `make format` before committing code

6. **Test before deploy** - Always run `make test` before deploying

7. **Monitor health** - Use `make health` to check if services are running

8. **Keep dependencies updated** - Regularly run `make update-deps`

## Troubleshooting

### Services won't start

```bash
make status             # Check what's running
make logs               # See error messages
make down               # Stop everything
make build              # Rebuild
make start              # Start again
```

### Database issues

```bash
make dbshell            # Check database directly
make migrate            # Apply missing migrations
make db-restore         # Restore from backup if needed
```

### Port already in use

```bash
# Check what's using port 8600
lsof -i :8600

# Stop conflicting service or change port in docker-compose.yml
```

### Docker daemon not running

```bash
# Start Docker Desktop or Docker service
# Then retry commands
```

## Quick Reference

| Task | Command |
|------|---------|
| Show help | `make help` |
| Start | `make start` |
| Stop | `make stop` |
| Restart | `make restart` |
| View logs | `make logs` |
| Run migrations | `make migrate` |
| Open shell | `make shell` |
| Run tests | `make test` |
| Format code | `make format` |
| Deploy | `make deploy` |
| Backup DB | `make db-backup` |
| Show URLs | `make urls` |
| Health check | `make health` |

## Getting Help

```bash
# Show all commands with descriptions
make help

# Check service status
make status

# View system information
make info

# Check logs for errors
make logs
```

---

**Last Updated:** October 20, 2025  
**Version:** 1.0  
**Project:** ChiefOnboarding - WorkForce Services
