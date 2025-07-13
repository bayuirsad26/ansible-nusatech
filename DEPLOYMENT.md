# Deployment Guide

## Prerequisites Setup

1. **Install dependencies:**
   ```bash
   make install
   ```

2. **Create vault password file:**
   ```bash
   cp .vault_password_file.example .vault_password_file
   # Edit .vault_password_file and add your secure password
   chmod 600 .vault_password_file
   ```

3. **Create and configure vault:**
   ```bash
   make vault-create
   # Add all sensitive configuration
   ```

4. **Update inventory:**
   Edit `inventory/hosts.yml` with your server details.

## Deployment Steps

1. **Test configuration:**
   ```bash
   make check
   ```

2. **Deploy stack:**
   ```bash
   make deploy
   ```

3. **Verify deployment:**
   ```bash
   make health
   ```

## Security Notes

- Never commit `.vault_password_file`
- Always use strong passwords in vault
- Regularly rotate passwords
- Monitor access logs

## Troubleshooting

- Use `make logs` to check service logs
- Use `make health` for system health
- Check DNS configuration for SSL issues

## 🔐 **Security Improvements**

1. **All sensitive data moved to encrypted vault**
2. **Proper password hashing for basic auth**
3. **SSH key paths not hardcoded**
4. **Comprehensive .gitignore**
5. **Health monitoring scripts**

## 🚀 **Next Steps**

After implementing these changes:

1. **Create the vault:**
   ```bash
   cp .vault_password_file.example .vault_password_file
   # Add your secure password to .vault_password_file
   make vault-create
   ```

2. **Test the improved setup:**
   ```bash
   make check
   ```

3. **Deploy with vault:**
   ```bash
   make deploy
   ```

This enhanced setup provides enterprise-grade security, comprehensive monitoring, and professional DevOps practices!