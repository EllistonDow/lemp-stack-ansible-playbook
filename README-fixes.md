# MySQL 和 OpenSearch 修复文档

本文档记录了对 MySQL (Percona Server) 和 OpenSearch 服务的修复过程和方法。

## 问题概述

在安装和配置过程中，我们遇到了以下问题：

1. **MySQL (Percona Server) 问题**：
   - 服务单元文件配置不正确，导致服务无法正常启动
   - 缺少必要的环境文件

2. **OpenSearch 问题**：
   - JVM 堆内存配置错误，设置了 32175GB 的堆内存，远远超过了系统的实际内存
   - 服务无法启动，出现内存分配错误

## 修复方案

我们创建了以下几个 Ansible playbook 来修复这些问题：

1. **fix-mysql-opensearch.yml**：初始修复脚本，包含对 MySQL 和 OpenSearch 的基本修复
2. **fix-opensearch-jvm.yml**：专门修复 OpenSearch 的 JVM 配置问题
3. **fix-all.yml**：综合修复脚本，整合了所有修复内容

### MySQL 修复内容

- 创建默认环境文件 `/etc/default/mysql`
- 修复服务单元文件 `/usr/lib/systemd/system/mysql.service`
- 重新加载 systemd 守护进程并启动服务

### OpenSearch 修复内容

- 计算适当的堆内存大小（系统内存的一半，但最大不超过 31GB）
- 更新 JVM 配置文件 `/etc/opensearch/jvm.options`
- 创建正确的 OpenSearch 配置文件 `/etc/opensearch/opensearch.yml`
- 设置正确的目录权限
- 重启 OpenSearch 服务

## 使用方法

### 运行综合修复

要一次性应用所有修复，请运行：

```bash
sudo ansible-playbook -i inventory.yml fix-all.yml
```

### 单独修复 OpenSearch JVM 配置

如果只需要修复 OpenSearch 的 JVM 配置，请运行：

```bash
sudo ansible-playbook -i inventory.yml fix-opensearch-jvm.yml
```

## 验证修复

### 验证 MySQL 服务

```bash
sudo systemctl status mysql.service
```

### 验证 OpenSearch 服务

```bash
sudo systemctl status opensearch.service
curl -X GET "localhost:9200" -k
```

## 注意事项

- 这些修复脚本已经在当前环境中测试通过
- 如果系统内存发生变化，可能需要重新运行 OpenSearch JVM 配置修复
- 修复后的配置文件已经备份，可以在需要时恢复 