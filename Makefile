.PHONY: install deploy check logs backup restore help

# Default target
help:
	@echo "Nusatech DevOps Stack - Available commands:"
	@echo "  install    - Install Ansible dependencies"
	@echo "  deploy     - Deploy the complete stack"
	@echo "  check      - Run syntax check and dry-run"
	@echo "  logs       - Show service logs"
	@echo "  backup     - Run manual backup"
	@echo "  restore    - Restore from backup"
	@echo "  help       - Show this help message"

install:
	@echo "Installing Ansible dependencies..."
	ansible-galaxy collection install -r requirements.yml

deploy:
	@echo "Deploying Nusatech DevOps Stack..."
	ansible-playbook -i inventory/hosts.yml site.yml

check:
	@echo "Running Ansible syntax check..."
	ansible-playbook -i inventory/hosts.yml site.yml --syntax-check
	@echo "Running dry-run..."
	ansible-playbook -i inventory/hosts.yml site.yml --check

logs:
	@echo "Showing service logs..."
	ssh -t root@YOUR_VPS_IP "cd /opt/nusatech-devops && docker-compose -f monitoring-compose.yml logs -f --tail=50"

backup:
	@echo "Running manual backup..."
	ssh -t root@YOUR_VPS_IP "/opt/backups/backup.sh"

restore:
	@echo "Available backups:"
	ssh root@YOUR_VPS_IP "ls -la /opt/backups/nusatech_devops_backup_*.tar.gz"
	@echo "To restore, specify backup file:"
	@echo "ssh root@YOUR_VPS_IP 'cd /opt/nusatech-devops && tar -xzf /opt/backups/BACKUP_FILE.tar.gz'"
