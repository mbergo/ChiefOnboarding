# Makefile Quick Reference Card

## Most Common Commands

```bash
make help              # Show all commands
make start             # Start services
make stop              # Stop services  
make restart           # Restart services
make logs              # View logs
make status            # Check status
```

## Daily Development

```bash
# Morning routine
make start

# After code changes
make restart-web       # Fast restart (web only)

# Before committing
make format            # Format code
make test              # Run tests

# Evening
make stop
```

## Database

```bash
make migrate           # Run migrations
make makemigrations    # Create migrations
make db-backup         # Backup database
make shell             # Django shell
```

## Testing

```bash
make test              # Run tests
make test-coverage     # With coverage
make lint              # Check code quality
make check             # Lint + test
```

## Troubleshooting

```bash
make logs-web          # Web logs only
make health            # Health check
make info              # System info
make restart           # Restart all
```

## Deployment

```bash
make deploy            # Full deployment
```

## Emergency

```bash
make down              # Stop & remove containers
make reset             # ⚠️ Fresh start (deletes data!)
```

## Quick Tips

- 🟢 Green = Success
- 🟡 Yellow = Warning  
- 🔴 Red = Destructive
- Type `make help` anytime
- Tab completion works!

## Essential Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias ms='make start'
alias mt='make stop'
alias mr='make restart'
alias ml='make logs'
alias mh='make help'
```

---
For detailed help: `make help` or see `MAKEFILE_GUIDE.md`
