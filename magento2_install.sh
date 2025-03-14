#!/bin/bash

# Magento 2 安装脚本
# 此脚本将安装 Magento 2

echo "开始 Magento 2 安装..."

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本"
  exit 1
fi

# 1. 设置变量
MAGENTO_ROOT="/var/www/magento2"
MAGENTO_VERSION="2.4.7"
DB_HOST="localhost"
DB_NAME="magento"
DB_USER="magento"
DB_PASSWORD="magento123"
ADMIN_FIRSTNAME="Admin"
ADMIN_LASTNAME="User"
ADMIN_EMAIL="admin@example.com"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin123"
BASE_URL="http://example.com/"
BACKEND_FRONTNAME="admin"
CURRENCY="USD"
LANGUAGE="en_US"
TIMEZONE="Asia/Shanghai"

# 2. 创建数据库和用户
echo "创建数据库和用户..."
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# 3. 安装 Composer
echo "安装 Composer..."
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# 4. 创建 Magento 目录
echo "创建 Magento 目录..."
mkdir -p $MAGENTO_ROOT
chown -R www-data:www-data $MAGENTO_ROOT

# 5. 切换到 Magento 目录
cd $MAGENTO_ROOT

# 6. 下载 Magento
echo "下载 Magento..."
sudo -u www-data composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$MAGENTO_VERSION .

# 7. 安装 Magento
echo "安装 Magento..."
sudo -u www-data php bin/magento setup:install \
  --base-url=$BASE_URL \
  --db-host=$DB_HOST \
  --db-name=$DB_NAME \
  --db-user=$DB_USER \
  --db-password=$DB_PASSWORD \
  --admin-firstname=$ADMIN_FIRSTNAME \
  --admin-lastname=$ADMIN_LASTNAME \
  --admin-email=$ADMIN_EMAIL \
  --admin-user=$ADMIN_USERNAME \
  --admin-password=$ADMIN_PASSWORD \
  --language=$LANGUAGE \
  --currency=$CURRENCY \
  --timezone=$TIMEZONE \
  --use-rewrites=1 \
  --backend-frontname=$BACKEND_FRONTNAME \
  --search-engine=opensearch \
  --opensearch-host=localhost \
  --opensearch-port=9200 \
  --opensearch-index-prefix=magento2 \
  --opensearch-timeout=15 \
  --opensearch-enable-auth=0 \
  --cache-backend=redis \
  --cache-backend-redis-server=127.0.0.1 \
  --cache-backend-redis-db=0 \
  --page-cache=redis \
  --page-cache-redis-server=127.0.0.1 \
  --page-cache-redis-db=1 \
  --session-save=redis \
  --session-save-redis-host=127.0.0.1 \
  --session-save-redis-log-level=4 \
  --session-save-redis-db=2 \
  --amqp-host=127.0.0.1 \
  --amqp-port=5672 \
  --amqp-user=guest \
  --amqp-password=guest \
  --amqp-virtualhost=/

# 8. 配置 Magento
echo "配置 Magento..."
sudo -u www-data php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=127.0.0.1 --cache-backend-redis-db=0
sudo -u www-data php bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=127.0.0.1 --page-cache-redis-db=1
sudo -u www-data php bin/magento setup:config:set --session-save=redis --session-save-redis-host=127.0.0.1 --session-save-redis-log-level=4 --session-save-redis-db=2
sudo -u www-data php bin/magento setup:config:set --amqp-host=127.0.0.1 --amqp-port=5672 --amqp-user=guest --amqp-password=guest --amqp-virtualhost=/

# 9. 设置部署模式为生产模式
echo "设置部署模式为生产模式..."
sudo -u www-data php bin/magento deploy:mode:set production

# 10. 编译代码
echo "编译代码..."
sudo -u www-data php bin/magento setup:di:compile

# 11. 部署静态内容
echo "部署静态内容..."
sudo -u www-data php bin/magento setup:static-content:deploy -f

# 12. 索引数据
echo "索引数据..."
sudo -u www-data php bin/magento indexer:reindex

# 13. 设置权限
echo "设置权限..."
find $MAGENTO_ROOT -type f -exec chmod 644 {} \;
find $MAGENTO_ROOT -type d -exec chmod 755 {} \;
find $MAGENTO_ROOT/var -type d -exec chmod 777 {} \;
find $MAGENTO_ROOT/pub/media -type d -exec chmod 777 {} \;
find $MAGENTO_ROOT/pub/static -type d -exec chmod 777 {} \;
chmod 777 $MAGENTO_ROOT/app/etc
chmod 644 $MAGENTO_ROOT/app/etc/*.xml

# 14. 从 Magento 复制 Nginx 配置示例
echo "复制 Nginx 配置示例..."
cp $MAGENTO_ROOT/nginx.conf.sample /etc/nginx/sites-available/magento2.conf
ln -sf /etc/nginx/sites-available/magento2.conf /etc/nginx/sites-enabled/

# 14.5 确保 Varnish secret 文件存在
echo "检查 Varnish secret 文件..."
if [ ! -f /etc/varnish/secret ]; then
    echo "创建 Varnish secret 文件..."
    dd if=/dev/random of=/etc/varnish/secret count=1 bs=512
    chmod 600 /etc/varnish/secret
fi

# 15. 重启服务
echo "重启服务..."
systemctl restart php8.4-fpm
systemctl restart nginx
systemctl restart varnish

echo "Magento 2 安装完成！"
echo "管理员 URL: ${BASE_URL}${BACKEND_FRONTNAME}"
echo "管理员用户名: ${ADMIN_USERNAME}"
echo "管理员密码: ${ADMIN_PASSWORD}"
echo "请确保更新您的 DNS 记录，将域名指向此服务器。"
echo "如果您使用的是本地环境，请更新您的 hosts 文件。" 