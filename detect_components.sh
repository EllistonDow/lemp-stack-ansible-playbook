#!/bin/bash
# Script to detect installed components

# Function to check if a package is installed
is_package_installed() {
  dpkg -l "$1" 2>/dev/null | grep -q "^ii"
  return $?
}

# Function to check if a service is running
is_service_running() {
  systemctl is-active --quiet "$1"
  return $?
}

# Check Nginx
if is_package_installed "nginx" && is_service_running "nginx"; then
  echo "nginx=installed"
else
  echo "nginx=not_installed"
fi

# Check ModSecurity
if [ -f "/usr/lib/nginx/modules/ngx_http_modsecurity_module.so" ]; then
  echo "modsecurity=installed"
else
  echo "modsecurity=not_installed"
fi

# Check PHP
if is_package_installed "php8.3-fpm" && is_service_running "php8.3-fpm"; then
  echo "php=installed"
else
  echo "php=not_installed"
fi

# Check Percona/MySQL
if is_package_installed "percona-server-server" && is_service_running "mysql"; then
  echo "percona=installed"
else
  echo "percona=not_installed"
fi

# Check Redis
if is_package_installed "redis-server" && is_service_running "redis-server"; then
  echo "redis=installed"
else
  echo "redis=not_installed"
fi

# Check RabbitMQ
if is_package_installed "rabbitmq-server" && is_service_running "rabbitmq-server"; then
  echo "rabbitmq=installed"
else
  echo "rabbitmq=not_installed"
fi

# Check Varnish
if is_package_installed "varnish" && is_service_running "varnish"; then
  echo "varnish=installed"
else
  echo "varnish=not_installed"
fi

# Check OpenSearch
if dpkg -l | grep -q opensearch; then
  echo "opensearch=installed"
else
  echo "opensearch=not_installed"
fi

# Check Composer
if command -v composer >/dev/null 2>&1; then
  echo "composer=installed"
else
  echo "composer=not_installed"
fi

# Check fail2ban
if is_package_installed "fail2ban" && is_service_running "fail2ban"; then
  echo "fail2ban=installed"
else
  echo "fail2ban=not_installed"
fi

# Check certbot
if command -v certbot >/dev/null 2>&1; then
  echo "certbot=installed"
else
  echo "certbot=not_installed"
fi

# Check phpMyAdmin
if [ -d "/usr/share/phpmyadmin" ]; then
  echo "phpmyadmin=installed"
else
  echo "phpmyadmin=not_installed"
fi

# Check Webmin
if is_package_installed "webmin" && is_service_running "webmin"; then
  echo "webmin=installed"
else
  echo "webmin=not_installed"
fi 