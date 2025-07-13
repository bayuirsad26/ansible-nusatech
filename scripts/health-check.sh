#!/bin/bash
# Nusatech DevOps Stack Health Check Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVER_IP="167.86.108.4"
SSH_USER="admin"
SSH_KEY="~/.ssh/summitethic-admin"

echo -e "${GREEN}🏥 Nusatech DevOps Stack Health Check${NC}"
echo "========================================"

# Function to check service health
check_service() {
    local service_name=$1
    local service_url=$2
    local expected_status=${3:-200}
    
    echo -n "Checking $service_name... "
    
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$service_url" | grep -q "$expected_status"; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Function to check SSH connectivity
check_ssh() {
    echo -n "Testing SSH connection... "
    if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$SSH_USER@$SERVER_IP" "echo 'SSH OK'" &>/dev/null; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Function to check Docker containers
check_containers() {
    echo "Checking Docker containers..."
    ssh -i "$SSH_KEY" "$SSH_USER@$SERVER_IP" "
        if [ -d /opt/nusatech-devops ]; then
            cd /opt/nusatech-devops
            echo 'Container Status:'
            docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || echo 'No containers running'
        else
            echo 'Stack not deployed yet'
        fi
    " || {
        echo -e "${RED}✗ Failed to check containers${NC}"
        return 1
    }
}

# Function to check system resources
check_resources() {
    echo "Checking system resources..."
    ssh -i "$SSH_KEY" "$SSH_USER@$SERVER_IP" "
        echo 'Disk Usage:'
        df -h | head -5
        echo ''
        echo 'Memory Usage:'
        free -h
        echo ''
        echo 'System Load:'
        uptime
    " || {
        echo -e "${RED}✗ Failed to check resources${NC}"
        return 1
    }
}

# Main health checks
main() {
    local failed_checks=0
    
    echo "Testing connectivity..."
    check_ssh || ((failed_checks++))
    
    echo -e "\nChecking system resources..."
    check_resources || ((failed_checks++))
    
    echo -e "\nChecking Docker containers..."
    check_containers || ((failed_checks++))
    
    echo -e "\nChecking service endpoints..."
    check_service "Traefik Dashboard" "https://traefik.nusatech.id" "200" || ((failed_checks++))
    check_service "Grafana" "https://monitoring.nusatech.id" "200" || ((failed_checks++))
    check_service "Prometheus" "https://metrics.nusatech.id" "200" || ((failed_checks++))
    check_service "AlertManager" "https://alerts.nusatech.id" "200" || ((failed_checks++))
    check_service "Jenkins" "https://ci.nusatech.id" "200" || ((failed_checks++))
    check_service "Mattermost" "https://chat.nusatech.id" "200" || ((failed_checks++))
    
    echo -e "\n========================================"
    if [ $failed_checks -eq 0 ]; then
        echo -e "${GREEN}🎉 All checks passed! Stack is healthy.${NC}"
        exit 0
    else
        echo -e "${RED}⚠️  $failed_checks check(s) failed. Please investigate.${NC}"
        exit 1
    fi
}

# Make script executable and run
chmod +x "$0" 2>/dev/null || true
main "$@"
