# LEMP Stack Ansible Playbook (扩展版)

这个Ansible项目用于在Ubuntu 24.04系统上自动化安装和配置扩展版LEMP栈，包含以下组件：

- **Nginx**: 1.24.* (带 ModSecurity)
- **PHP**: 8.3.*
- **Percona Server**: 8.0.* (MySQL替代品)
- **Composer**: 2.7.*
- **Redis**: 7.2.*
- **RabbitMQ**: 3.13.*
- **Varnish**: 7.5.*
- **OpenSearch**: 2.12.*
- **fail2ban**: latest
- **certbot**: latest (用于Let's Encrypt SSL证书)
- **phpMyAdmin**: latest
- **Webmin**: latest

## 目录结构

```
.
├── inventory.yml                  # 主机清单文件
├── lemp_playbook.yml              # 主playbook文件
├── lemp_stack_complete_playbook.yml # 完整LEMP栈playbook文件
├── smart_install.yml              # 智能安装playbook文件
├── uninstall.yml                  # 卸载playbook文件
├── detect_components.sh           # 组件检测脚本
├── nginx_playbook.yml             # Nginx单独安装playbook
├── php_playbook.yml               # PHP单独安装playbook
├── composer_playbook.yml          # Composer单独安装playbook
├── percona_playbook.yml           # Percona单独安装playbook
├── redis_playbook.yml             # Redis单独安装playbook
├── rabbitmq_playbook.yml          # RabbitMQ单独安装playbook
├── varnish_playbook.yml           # Varnish单独安装playbook
├── opensearch_playbook.yml        # OpenSearch单独安装playbook
├── fail2ban_playbook.yml          # fail2ban单独安装playbook
├── certbot_playbook.yml           # certbot单独安装playbook
├── phpmyadmin_playbook.yml        # phpMyAdmin单独安装playbook
├── webmin_playbook.yml            # Webmin单独安装playbook
├── roles/                         # 角色目录
│   ├── common/                    # 通用设置角色
│   ├── nginx/                     # Nginx角色
│   ├── php/                       # PHP角色
│   ├── composer/                  # Composer角色
│   ├── percona/                   # Percona Server角色
│   ├── redis/                     # Redis角色
│   ├── rabbitmq/                  # RabbitMQ角色
│   ├── varnish/                   # Varnish角色
│   ├── opensearch/                # OpenSearch角色
│   ├── fail2ban/                  # fail2ban角色
│   ├── certbot/                   # certbot角色
│   ├── phpmyadmin/                # phpMyAdmin角色
│   └── webmin/                    # Webmin角色
└── README.md                      # 本文档
```

## 安装方法

### 1. 完整安装

安装所有组件（Nginx、PHP、Percona、Redis、RabbitMQ、Varnish、OpenSearch、Composer、fail2ban、certbot、phpMyAdmin和Webmin）：

```bash
sudo ansible-playbook -i inventory.yml lemp_stack_complete_playbook.yml
```

### 2. 智能安装

智能安装会先检测系统中已安装的组件，然后只安装缺失的组件：

```bash
sudo ansible-playbook -i inventory.yml smart_install.yml
```

### 3. 单独安装各组件

您可以选择单独安装特定组件：

```bash
# 安装 Nginx
sudo ansible-playbook -i inventory.yml nginx_playbook.yml

# 安装 PHP
sudo ansible-playbook -i inventory.yml php_playbook.yml

# 安装 Percona Server (MySQL)
sudo ansible-playbook -i inventory.yml percona_playbook.yml

# 安装 Composer
sudo ansible-playbook -i inventory.yml composer_playbook.yml

# 安装 Redis
sudo ansible-playbook -i inventory.yml redis_playbook.yml

# 安装 RabbitMQ
sudo ansible-playbook -i inventory.yml rabbitmq_playbook.yml

# 安装 Varnish
sudo ansible-playbook -i inventory.yml varnish_playbook.yml

# 安装 OpenSearch
sudo ansible-playbook -i inventory.yml opensearch_playbook.yml

# 安装 fail2ban
sudo ansible-playbook -i inventory.yml fail2ban_playbook.yml

# 安装 certbot
sudo ansible-playbook -i inventory.yml certbot_playbook.yml

# 安装 phpMyAdmin
sudo ansible-playbook -i inventory.yml phpmyadmin_playbook.yml

# 安装 Webmin
sudo ansible-playbook -i inventory.yml webmin_playbook.yml
```

## 卸载方法

卸载所有组件（Nginx、PHP、Percona、Redis、RabbitMQ、Varnish、OpenSearch、Composer、fail2ban、certbot、phpMyAdmin和Webmin）：

```bash
sudo ansible-playbook -i inventory.yml uninstall.yml
```

## 组件检测

您可以使用检测脚本来查看系统中已安装的组件：

```bash
sudo ./detect_components.sh
```

输出示例：
```
nginx=installed
modsecurity=installed
php=installed
percona=installed
redis=installed
rabbitmq=installed
varnish=installed
opensearch=installed
composer=installed
fail2ban=installed
certbot=installed
phpmyadmin=installed
webmin=installed
```

## 自定义配置

您可以通过编辑各个角色目录下的`defaults/main.yml`文件来自定义配置。

### 主要配置文件位置

- **Nginx**: `/etc/nginx/nginx.conf`
- **PHP**: `/etc/php/8.3/fpm/php.ini`
- **PHP-FPM**: `/etc/php/8.3/fpm/pool.d/www.conf`
- **PHP Opcache**: `/etc/php/8.3/mods-available/opcache.ini`
- **Percona/MySQL**: `/etc/mysql/my.cnf`
- **Redis**: `/etc/redis/redis.conf`
- **RabbitMQ**: `/etc/rabbitmq/rabbitmq.conf`
- **Varnish**: `/etc/varnish/default.vcl`
- **OpenSearch**: `/etc/opensearch/opensearch.yml`
- **fail2ban**: `/etc/fail2ban/jail.local`
- **phpMyAdmin**: `/etc/phpmyadmin/config.inc.php`
- **Webmin**: `/etc/webmin/config`

### 服务管理

```bash
# 启动服务
sudo systemctl start nginx
sudo systemctl start php8.3-fpm
sudo systemctl start mysql
sudo systemctl start redis-server
sudo systemctl start rabbitmq-server
sudo systemctl start varnish
sudo systemctl start opensearch
sudo systemctl start fail2ban
sudo systemctl start webmin

# 停止服务
sudo systemctl stop nginx
sudo systemctl stop php8.3-fpm
sudo systemctl stop mysql
sudo systemctl stop redis-server
sudo systemctl stop rabbitmq-server
sudo systemctl stop varnish
sudo systemctl stop opensearch
sudo systemctl stop fail2ban
sudo systemctl stop webmin

# 重启服务
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
sudo systemctl restart mysql
sudo systemctl restart redis-server
sudo systemctl restart rabbitmq-server
sudo systemctl restart varnish
sudo systemctl restart opensearch
sudo systemctl restart fail2ban
sudo systemctl restart webmin

# 查看服务状态
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
sudo systemctl status mysql
sudo systemctl status redis-server
sudo systemctl status rabbitmq-server
sudo systemctl status varnish
sudo systemctl status opensearch
sudo systemctl status fail2ban
sudo systemctl status webmin
```

## 访问管理界面

- **phpMyAdmin**: http://your-server-ip/phpmyadmin
- **Webmin**: https://your-server-ip:10000
- **RabbitMQ管理界面**: http://your-server-ip:15672

## 支持的操作系统

- Ubuntu 24.04 LTS 