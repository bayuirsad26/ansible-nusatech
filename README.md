# Nusatech DevOps Stack

A comprehensive Ansible project for deploying a modern DevOps stack with monitoring, CI/CD, and collaboration tools, designed with ethical practices and resource efficiency in mind. Features Traefik reverse proxy for professional SSL termination and subdomain routing.

## 🚀 Stack Components

- **Traefik**: Modern reverse proxy with automatic SSL via Let's Encrypt
- **Mattermost**: Team collaboration and communication
- **Jenkins**: CI/CD automation and build pipelines  
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation and analysis
- **AlertManager**: Alert routing and management

## 📋 Prerequisites

- Ubuntu 24.04.2 LTS server with 4 vCPU, 6GB RAM, 600GB storage
- Ansible 2.9+ on your local machine
- SSH access to your server
- Domain name with DNS control (required for SSL certificates)
- Subdomains pointing to your server IP:
  - `chat.your-domain.com` → Mattermost
  - `ci.your-domain.com` → Jenkins
  - `monitoring.your-domain.com` → Grafana
  - `metrics.your-domain.com` → Prometheus
  - `alerts.your-domain.com` → AlertManager
  - `traefik.your-domain.com` → Traefik Dashboard

## 🛠 Quick Start

1. **Clone and Setup**
   ```bash
   git clone <your-repo>
   cd nusatech-devops-ansible
   make install
   ```

2. **Configure Inventory**
   ```bash
   # Edit inventory/hosts.yml
   # Update YOUR_VPS_IP with your server IP
   # Configure SSH key path
   ```

3. **Customize Variables**
   ```bash
   # Edit group_vars/all.yml
   # Update domain, ssl_email, passwords, and resource limits
   # Configure subdomain structure
   ```

4. **Deploy Stack**
   ```bash
   make check    # Verify configuration
   make deploy   # Deploy services
   ```

## 🔧 Configuration

### Resource Allocation
Optimized for 6GB RAM with smart resource limits:
- Traefik: 128MB RAM, 0.2 CPU
- Jenkins: 1.5GB RAM, 1.5 CPU
- Mattermost: 1GB RAM, 1.0 CPU  
- Prometheus: 512MB RAM, 0.5 CPU
- Grafana: 512MB RAM, 0.5 CPU
- Loki: 256MB RAM, 0.3 CPU
- AlertManager: 128MB RAM, 0.2 CPU

### Security Features
- Traefik reverse proxy with automatic SSL via Let's Encrypt
- UFW firewall with only ports 80, 443, and 22 exposed
- Fail2ban for SSH protection
- Automatic security updates
- Resource-limited containers
- Security headers via Traefik middleware

### Backup Strategy
- Automated daily backups at 2 AM
- 7-day retention policy
- Complete data and configuration backup
- Docker image backup for quick restoration

## 📊 Service Access

After deployment, access services at:
- **Mattermost**: `https://chat.your-domain.com`
- **Jenkins**: `https://ci.your-domain.com`
- **Grafana**: `https://monitoring.your-domain.com` (admin/Nusatech-2025)
- **Prometheus**: `https://metrics.your-domain.com`
- **AlertManager**: `https://alerts.your-domain.com`
- **Traefik Dashboard**: `https://traefik.your-domain.com` (admin/Nusatech-2025)

## 🔄 Management Commands

```bash
make logs      # View service logs
make backup    # Manual backup
make restore   # List and restore backups
```

## 🛡 Security Considerations

This configuration follows DevOps best practices:
- Automatic SSL certificate management via Let's Encrypt
- Principle of least privilege with reverse proxy
- Automated security updates
- Resource isolation via containers
- Regular automated backups
- Comprehensive monitoring and alerting
- Security headers and HTTPS enforcement

## 📈 Monitoring Setup

1. **Grafana Dashboards**: Import community dashboards for Jenkins, system metrics
2. **Prometheus Targets**: Pre-configured for all services
3. **Alerting**: Configure webhook to Mattermost for notifications
4. **Log Aggregation**: Loki ready for application log collection
5. **Traefik Metrics**: Built-in Prometheus metrics for reverse proxy monitoring

## 🔄 CI/CD Integration

Jenkins comes pre-configured with:
- Docker integration for containerized builds
- Prometheus metrics endpoint
- Ready for GitLab/GitHub webhooks
- Plugin ecosystem for your workflow
- SSL-secured access via Traefik

## 🆘 Troubleshooting

**Service won't start?**
```bash
docker logs <container_name>
docker compose -f /opt/nusatech-devops/traefik-compose.yml logs
docker compose -f /opt/nusatech-devops/monitoring-compose.yml logs
```

**SSL certificate issues?**
```bash
docker logs traefik
# Check Traefik dashboard for certificate status
# Verify DNS records point to your server
```

**Resource issues?**
```bash
docker stats
htop
df -h
```

**Network connectivity?**
```bash
docker network ls
docker network inspect nusatech_devops_network
```

## 🌐 DNS Configuration

Ensure the following DNS records point to your server IP:
```
A    chat.your-domain.com       → YOUR_SERVER_IP
A    ci.your-domain.com         → YOUR_SERVER_IP
A    monitoring.your-domain.com → YOUR_SERVER_IP
A    metrics.your-domain.com    → YOUR_SERVER_IP
A    alerts.your-domain.com     → YOUR_SERVER_IP
A    traefik.your-domain.com    → YOUR_SERVER_IP
```

## 🤝 Contributing

This project embodies Nusatech's commitment to ethical development:
- Transparent configuration
- Security-first approach with automatic SSL
- Resource-conscious design
- Documentation-driven development
- Professional reverse proxy setup

## 📄 License

Developed with ethical principles in mind for the Nusatech software house.

---

*Built with ❤️ and ethical practices by the Nusatech team*
