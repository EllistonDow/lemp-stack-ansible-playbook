# 更新日志

## [0.2.2] - 2025-04-09

### 修复
- 修复OpenSearch安装脚本中的索引级别设置问题
- 优化OpenSearch JVM配置，自动根据系统内存计算合理的堆大小
- 修复OpenSearch服务单元文件配置
- 新增目录权限设置，确保/var/run/opensearch目录存在并有正确权限
- 增强安装过程的错误处理

### 改进
- 增加API测试验证步骤，确保服务实际可用
- 延长服务启动等待时间，提高安装成功率
- 添加更详细的状态报告

## [0.2.0] - 2025-03-14

### 新增
- 添加了 OpenSearch 和 Percona MySQL 的修复脚本
- 添加了 PHP 卸载脚本
- 添加了 Percona 卸载脚本
- 添加了综合修复脚本 `fix-all.yml`

### 修复
- 修复了 MySQL 服务单元文件配置问题
- 修复了 OpenSearch JVM 堆内存配置问题
- 修复了 PHP 安装脚本，确保只安装 PHP 8.3
- 修复了 `smart_install.yml` 中的语法错误

### 改进
- 改进了错误处理和恢复机制
- 添加了详细的修复文档
- 优化了 OpenSearch 内存使用

## [0.1.0] - 2025-03-13

### 初始版本
- LEMP Stack Ansible Playbook 项目初始提交
- 包含智能安装和卸载功能
- 支持 Nginx, PHP, MySQL, Redis, RabbitMQ, Varnish, OpenSearch 等组件 