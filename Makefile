.PHONY: install deploy check logs backup restore health vault-edit vault-create vault-encrypt vault-decrypt help

# Configuration
SERVER_IP := 167.86.108.4
SSH_USER := admin
SSH_KEY := ~/.ssh/summitethic-admin

# Default target
help:
	@echo "Nusatech DevOps Stack - Available commands:"
	@echo "  install       - Install Ansible dependencies"
	@echo "  vault-create  - Create new vault file"
	@echo "  vault-edit    - Edit vault file"
	@echo "  vault-encrypt - Encrypt vault file"
	@echo "  vault-decrypt - Decrypt vault file"
	@echo "  check         - Run syntax check and dry-run"
	@echo "  deploy        - Deploy the complete stack"
	@echo "  logs          - Show service logs"
	@echo "  logs-traefik  - Show Traefik logs"
	@echo "  logs-monitor  - Show monitoring logs"
	@echo "  logs-cicd     - Show CI/CD logs"
	@echo "  status        - Show services status"
	@echo "  backup        - Run manual backup"
	@echo "  restore       - Restore from backup"
	@echo "  health        - Run health check"
	@echo "  help          - Show this help message"

install:
	@echo "Installing Ansible dependencies..."
	ansible-galaxy collection install -r requirements.yml
	@echo "Installing Python requirements..."
	pip3 install ansible-core jmespath passlib bcrypt

vault-create:
	@echo "Creating new vault file..."
	ansible-vault create group_vars/vault.yml

vault-edit:
	@echo "Editing vault file..."
	ansible-vault edit group_vars/vault.yml

vault-encrypt:
	@echo "Encrypting vault file..."
	ansible-vault encrypt group_vars/vault.yml

vault-decrypt:
	@echo "Decrypting vault file..."
	ansible-vault decrypt group_vars/vault.yml

check:
	@echo "Running Ansible syntax check..."
	ansible-playbook -i inventory/hosts.yml site.yml --syntax-check
	@echo "Running dry-run..."
	ansible-playbook -i inventory/hosts.yml site.yml --check

deploy:
	@echo "Deploying Nusatech DevOps Stack..."
	ansible-playbook -i inventory/hosts.yml site.yml

status:
	@echo "Checking services status..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "cd /opt/nusatech-devops 2>/dev/null && docker compose ps || echo 'Services not deployed yet'"

logs:
	@echo "Showing all service logs..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) '\
		cd /opt/nusatech-devops 2>/dev/null || { echo "Stack not deployed yet. Run make deploy first."; exit 1; }; \
		echo "=== Traefik Logs ==="; \
		docker compose -f traefik-compose.yml logs --tail=20 2>/dev/null || echo "Traefik not running"; \
		echo -e "\n=== Monitoring Logs ==="; \
		docker compose -f monitoring-compose.yml logs --tail=20 2>/dev/null || echo "Monitoring not running"; \
		echo -e "\n=== CI/CD Logs ==="; \
		docker compose -f cicd-compose.yml logs --tail=20 2>/dev/null || echo "CI/CD not running"'

logs-traefik:
	@echo "Showing Traefik logs..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "cd /opt/nusatech-devops && docker compose -f traefik-compose.yml logs --tail=50 -f"

logs-monitor:
	@echo "Showing monitoring logs..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "cd /opt/nusatech-devops && docker compose -f monitoring-compose.yml logs --tail=50 -f"

logs-cicd:
	@echo "Showing CI/CD logs..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "cd /opt/nusatech-devops && docker compose -f cicd-compose.yml logs --tail=50 -f"

backup:
	@echo "Running manual backup..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "/opt/backups/backup.sh 2>/dev/null || echo 'Backup script not found. Deploy first.'"

restore:
	@echo "Available backups:"
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "ls -la /opt/backups/nusatech_devops_backup_*.tar.gz 2>/dev/null || echo 'No backups found'"
	@echo ""
	@echo "To restore a specific backup:"
	@echo "  ssh $(SSH_USER)@$(SERVER_IP) 'cd /opt/nusatech-devops && tar -xzf /opt/backups/BACKUP_FILE.tar.gz'"

health:
	@echo "Running health check..."
	@./scripts/health-check.sh 2>/dev/null || { echo "Health check script not found. Creating basic check..."; $(MAKE) basic-health; }

basic-health:
	@echo "Running basic health check..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) '\
		echo "=== System Info ==="; \
		uptime; \
		echo -e "\n=== Disk Usage ==="; \
		df -h | head -5; \
		echo -e "\n=== Memory Usage ==="; \
		free -h; \
		echo -e "\n=== Docker Status ==="; \
		docker --version 2>/dev/null || echo "Docker not installed"; \
		echo -e "\n=== Running Containers ==="; \
		docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"'

# Development helpers
connect:
	@echo "Connecting to server..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP)

ps:
	@echo "Showing running containers..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) "docker ps"

restart-all:
	@echo "Restarting all services..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) '\
		cd /opt/nusatech-devops && \
		docker compose -f traefik-compose.yml restart && \
		docker compose -f monitoring-compose.yml restart && \
		docker compose -f cicd-compose.yml restart'

stop-all:
	@echo "Stopping all services..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) '\
		cd /opt/nusatech-devops && \
		docker compose -f traefik-compose.yml stop && \
		docker compose -f monitoring-compose.yml stop && \
		docker compose -f cicd-compose.yml stop'

start-all:
	@echo "Starting all services..."
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(SERVER_IP) '\
		cd /opt/nusatech-devops && \
		docker compose -f traefik-compose.yml up -d && \
		docker compose -f monitoring-compose.yml up -d && \
		docker compose -f cicd-compose.yml up -d'
