#!/bin/bash

# Magento 2 环境优化脚本
# 此脚本将优化您的环境以运行 Magento 2

echo "开始 Magento 2 环境优化..."

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本"
  exit 1
fi

# 1. 安装 PHP-FPM 和必要的 PHP 扩展
echo "安装 PHP-FPM 和必要的 PHP 扩展..."
apt-get update
apt-get install -y php8.4-fpm php8.4-bcmath php8.4-gd php8.4-intl php8.4-curl php8.4-mysql php8.4-mbstring php8.4-soap php8.4-xml php8.4-zip php8.4-xsl

# 2. 优化 PHP 配置
echo "优化 PHP 配置..."
PHP_INI_CLI="/etc/php/8.4/cli/php.ini"
PHP_INI_FPM="/etc/php/8.4/fpm/php.ini"

# 备份原始配置
cp $PHP_INI_CLI ${PHP_INI_CLI}.bak
cp $PHP_INI_FPM ${PHP_INI_FPM}.bak

# 更新 PHP CLI 配置
sed -i 's/memory_limit = -1/memory_limit = 2G/' $PHP_INI_CLI
sed -i 's/max_execution_time = 0/max_execution_time = 300/' $PHP_INI_CLI
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' $PHP_INI_CLI
sed -i 's/post_max_size = 8M/post_max_size = 64M/' $PHP_INI_CLI
sed -i 's/;realpath_cache_size = 4096k/realpath_cache_size = 10M/' $PHP_INI_CLI
sed -i 's/;realpath_cache_ttl = 120/realpath_cache_ttl = 7200/' $PHP_INI_CLI

# 更新 PHP-FPM 配置
sed -i 's/memory_limit = -1/memory_limit = 2G/' $PHP_INI_FPM
sed -i 's/max_execution_time = 0/max_execution_time = 300/' $PHP_INI_FPM
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' $PHP_INI_FPM
sed -i 's/post_max_size = 8M/post_max_size = 64M/' $PHP_INI_FPM
sed -i 's/;realpath_cache_size = 4096k/realpath_cache_size = 10M/' $PHP_INI_FPM
sed -i 's/;realpath_cache_ttl = 120/realpath_cache_ttl = 7200/' $PHP_INI_FPM

# 3. 优化 PHP-FPM 配置
echo "优化 PHP-FPM 配置..."
PHP_FPM_CONF="/etc/php/8.4/fpm/pool.d/www.conf"
cp $PHP_FPM_CONF ${PHP_FPM_CONF}.bak

# 更新 PHP-FPM 进程管理器配置
sed -i 's/pm = dynamic/pm = ondemand/' $PHP_FPM_CONF
sed -i 's/pm.max_children = 5/pm.max_children = 50/' $PHP_FPM_CONF
sed -i 's/pm.start_servers = 2/pm.start_servers = 5/' $PHP_FPM_CONF
sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 5/' $PHP_FPM_CONF
sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 35/' $PHP_FPM_CONF
sed -i 's/;pm.max_requests = 500/pm.max_requests = 500/' $PHP_FPM_CONF

# 4. 优化 OPcache 配置
echo "优化 OPcache 配置..."
OPCACHE_CONF="/etc/php/8.4/fpm/conf.d/10-opcache.ini"
cp $OPCACHE_CONF ${OPCACHE_CONF}.bak

cat > $OPCACHE_CONF << 'EOL'
; 配置 OPcache
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=512
opcache.interned_strings_buffer=64
opcache.max_accelerated_files=60000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=0
opcache.save_comments=1
opcache.enable_file_override=0
opcache.blacklist_filename=/etc/php/8.4/fpm/conf.d/opcache-blacklist.txt
EOL

# 创建 OPcache 黑名单文件
touch /etc/php/8.4/fpm/conf.d/opcache-blacklist.txt

# 5. 优化 MySQL 配置
echo "优化 MySQL 配置..."
MYSQL_CONF="/etc/mysql/my.cnf"
cp $MYSQL_CONF ${MYSQL_CONF}.bak

# 获取系统内存大小（以 MB 为单位）
TOTAL_MEM_MB=$(free -m | grep "Mem:" | awk '{print $2}')
# 计算 InnoDB 缓冲池大小（系统内存的 50%）
INNODB_BUFFER_POOL_SIZE=$(($TOTAL_MEM_MB / 2))

# 更新 MySQL 配置
sed -i "s/innodb_buffer_pool_size = 256M/innodb_buffer_pool_size = ${INNODB_BUFFER_POOL_SIZE}M/" $MYSQL_CONF
sed -i "s/innodb_log_file_size = 64M/innodb_log_file_size = 256M/" $MYSQL_CONF
sed -i "s/max_connections = 151/max_connections = 300/" $MYSQL_CONF
sed -i "s/max_allowed_packet = 16M/max_allowed_packet = 64M/" $MYSQL_CONF
sed -i "s/thread_cache_size = 8/thread_cache_size = 16/" $MYSQL_CONF
sed -i "s/query_cache_size = 16M/query_cache_size = 0/" $MYSQL_CONF
sed -i "s/query_cache_limit = 1M/#query_cache_limit = 1M/" $MYSQL_CONF
sed -i "/\[mysqld\]/a query_cache_type = 0" $MYSQL_CONF
sed -i "/\[mysqld\]/a innodb_flush_method = O_DIRECT" $MYSQL_CONF
sed -i "/\[mysqld\]/a innodb_file_per_table = 1" $MYSQL_CONF
sed -i "/\[mysqld\]/a innodb_flush_log_at_trx_commit = 2" $MYSQL_CONF
sed -i "/\[mysqld\]/a innodb_io_capacity = 4000" $MYSQL_CONF
sed -i "/\[mysqld\]/a innodb_read_io_threads = 8" $MYSQL_CONF
sed -i "/\[mysqld\]/a innodb_write_io_threads = 8" $MYSQL_CONF

# 6. 优化 Nginx 配置
echo "优化 Nginx 配置..."
NGINX_CONF="/etc/nginx/nginx.conf"
cp $NGINX_CONF ${NGINX_CONF}.bak

# 更新 Nginx 配置
sed -i "s/worker_processes auto;/worker_processes auto;\nworker_rlimit_nofile 65535;/" $NGINX_CONF
sed -i "s/worker_connections 1024;/worker_connections 4096;/" $NGINX_CONF
sed -i "s/keepalive_timeout 65;/keepalive_timeout 300;/" $NGINX_CONF
sed -i "s/gzip_comp_level 6;/gzip_comp_level 4;/" $NGINX_CONF

# 7. 创建 Magento 2 的 Nginx 配置
echo "创建 Magento 2 的 Nginx 配置..."
MAGENTO_NGINX_CONF="/etc/nginx/sites-available/magento2"

cat > $MAGENTO_NGINX_CONF << 'EOL'
upstream fastcgi_backend {
    server unix:/var/run/php/php8.4-fpm.sock;
}

server {
    listen 80;
    listen [::]:80;
    
    server_name example.com www.example.com;
    
    set $MAGE_ROOT /var/www/magento2;
    set $MAGE_MODE production;
    
    access_log /var/log/nginx/magento2-access.log;
    error_log /var/log/nginx/magento2-error.log;
    
    include /var/www/magento2/nginx.conf.sample;
}
EOL

# 创建符号链接以启用站点
ln -sf /etc/nginx/sites-available/magento2 /etc/nginx/sites-enabled/

# 8. 优化 Varnish 配置
echo "优化 Varnish 配置..."
VARNISH_CONF="/etc/varnish/default.vcl"
cp $VARNISH_CONF ${VARNISH_CONF}.bak

# 确保 Varnish secret 文件存在
if [ ! -f /etc/varnish/secret ]; then
    echo "创建 Varnish secret 文件..."
    dd if=/dev/random of=/etc/varnish/secret count=1 bs=512
    chmod 600 /etc/varnish/secret
fi

# 更新 Varnish 配置
sed -i "s/.port = \"8080\";/.port = \"8080\";\n    .first_byte_timeout = 600s;\n    .between_bytes_timeout = 600s;/" $VARNISH_CONF

# 9. 优化系统限制
echo "优化系统限制..."
LIMITS_CONF="/etc/security/limits.conf"
cp $LIMITS_CONF ${LIMITS_CONF}.bak

cat >> $LIMITS_CONF << 'EOL'
# 为 Magento 2 增加限制
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOL

# 10. 优化内核参数
echo "优化内核参数..."
SYSCTL_CONF="/etc/sysctl.conf"
cp $SYSCTL_CONF ${SYSCTL_CONF}.bak

cat >> $SYSCTL_CONF << 'EOL'
# 为 Magento 2 优化内核参数
net.ipv4.tcp_fin_timeout = 15
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
EOL

# 应用内核参数
sysctl -p

# 11. 重启服务
echo "重启服务..."
systemctl restart php8.4-fpm
systemctl restart mysql
systemctl restart nginx
systemctl restart varnish
systemctl restart redis-server
systemctl restart opensearch

echo "Magento 2 环境优化完成！"
echo "请确保在 Magento 2 安装目录中创建 nginx.conf.sample 文件，或者从 Magento 2 源代码中复制该文件。"
echo "您可能需要根据您的具体需求调整配置。" 