# LEMP Stack Ansible Playbook (扩展版)

这个Ansible项目用于在Ubuntu 24.04系统上自动化安装和配置扩展版LEMP栈，包含以下组件：

- **Nginx**: 1.27.* (带 ModSecurity)
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

# Magento 2 安装和优化脚本

这个仓库包含了用于安装和优化 Magento 2 的脚本。

## 环境要求

- Ubuntu 24.04 LTS
- PHP 8.4
- MySQL 8.0 (Percona Server)
- Nginx 1.24
- Redis
- Varnish
- OpenSearch
- RabbitMQ

## 已安装的组件

根据检测脚本的输出，以下组件已经安装：

- Nginx + ModSecurity
- OpenSearch
- Redis
- Varnish

## 使用方法

### 1. 优化环境

在安装 Magento 2 之前，建议先优化环境。运行以下命令：

```bash
sudo ./magento2_optimize.sh
```

这个脚本会执行以下操作：

- 安装 PHP-FPM 和必要的 PHP 扩展
- 优化 PHP 配置
- 优化 PHP-FPM 配置
- 优化 OPcache 配置
- 优化 MySQL 配置
- 优化 Nginx 配置
- 创建 Magento 2 的 Nginx 配置
- 优化 Varnish 配置
- 优化系统限制
- 优化内核参数
- 重启所有服务

### 2. 安装 Magento 2

优化环境后，可以安装 Magento 2。运行以下命令：

```bash
sudo ./magento2_install.sh
```

这个脚本会执行以下操作：

- 创建数据库和用户
- 安装 Composer（如果尚未安装）
- 创建 Magento 目录
- 下载 Magento
- 安装 Magento
- 配置 Magento 使用 Redis 缓存、会话存储和 OpenSearch
- 设置部署模式为生产模式
- 编译代码
- 部署静态内容
- 索引数据
- 设置权限
- 复制 Nginx 配置示例
- 重启服务

## 配置说明

### 默认配置

- Magento 安装目录：`/var/www/magento2`
- Magento 版本：2.4.7
- 数据库名称：`magento`
- 数据库用户：`magento`
- 数据库密码：`magento123`
- 管理员用户名：`admin`
- 管理员密码：`admin123`
- 基础 URL：`http://example.com/`
- 后台路径：`admin`

### 自定义配置

如果需要自定义配置，请编辑 `magento2_install.sh` 文件中的变量部分。

## 注意事项

1. 在运行脚本之前，请确保已经备份了重要数据。
2. 这些脚本会修改系统配置，请在测试环境中测试后再在生产环境中使用。
3. 安装完成后，请立即更改管理员密码。
4. 如果使用的是生产环境，请确保启用 HTTPS。
5. 对于生产环境，建议进一步加强安全措施，如启用 ModSecurity 规则、配置防火墙等。

## 故障排除

如果在安装过程中遇到问题，请检查以下日志文件：

- PHP-FPM 日志：`/var/log/php8.4-fpm.log`
- Nginx 日志：`/var/log/nginx/error.log`
- MySQL 日志：`/var/log/mysql/error.log`
- Magento 日志：`/var/www/magento2/var/log/`

## 性能优化建议

1. 定期清理 Magento 缓存
2. 使用 CDN 分发静态内容
3. 启用 HTTP/2
4. 定期优化数据库
5. 监控系统资源使用情况
6. 根据流量情况调整 PHP-FPM 和 MySQL 配置

## 安全建议

1. 定期更新 Magento 和所有组件
2. 使用强密码
3. 启用双因素认证
4. 限制管理员 IP 访问
5. 定期备份数据
6. 启用 ModSecurity 规则
7. 配置防火墙
8. 使用 HTTPS 

## 版本信息

当前版本: 0.2.0

查看 [CHANGELOG.md](CHANGELOG.md) 获取详细的版本更新信息。 