#!/bin/bash
# Script to restore ModSecurity configuration after LEMP stack installation

# Stop Nginx
systemctl stop nginx

# Restore ModSecurity module
if [ -f "/root/nginx-modsec-backup/ngx_http_modsecurity_module.so" ]; then
  mkdir -p /usr/lib/nginx/modules/
  cp /root/nginx-modsec-backup/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/
  chmod 755 /usr/lib/nginx/modules/ngx_http_modsecurity_module.so
  echo "ModSecurity module restored."
else
  echo "ModSecurity module backup not found."
fi

# Restore Nginx configuration
if [ -d "/root/nginx-modsec-backup/nginx" ]; then
  # Backup current config first
  mv /etc/nginx /etc/nginx.new
  cp -r /root/nginx-modsec-backup/nginx /etc/
  echo "Nginx configuration restored."
else
  echo "Nginx configuration backup not found."
fi

# Restore ModSecurity logs
if [ -f "/root/nginx-modsec-backup/modsec_audit.log" ]; then
  cp /root/nginx-modsec-backup/modsec_* /var/log/nginx/
  chmod 666 /var/log/nginx/modsec_*
  echo "ModSecurity logs restored."
else
  echo "ModSecurity logs backup not found."
fi

# Update Nginx configuration to load ModSecurity
if ! grep -q "load_module.*ngx_http_modsecurity_module.so" /etc/nginx/nginx.conf; then
  sed -i '1i\load_module /usr/lib/nginx/modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
  echo "ModSecurity module loading added to nginx.conf."
fi

# Ensure ModSecurity is enabled in http block
if ! grep -q "modsecurity on" /etc/nginx/nginx.conf; then
  sed -i '/http {/a \    # ModSecurity\n    modsecurity on;\n    modsecurity_rules_file /etc/nginx/modsecurity/main.conf;' /etc/nginx/nginx.conf
  echo "ModSecurity enabled in http block."
fi

# Start Nginx
systemctl start nginx

echo "ModSecurity restoration completed. Check Nginx status with 'systemctl status nginx'." 