#!/bin/bash

echo "===== 开始修复组件安装 ====="

# 清理 Percona MySQL
echo "正在清理 Percona MySQL..."
sudo systemctl stop mysql || true
sudo apt-get remove --purge percona-server* -y || true
sudo rm -rf /etc/mysql /var/lib/mysql || true
sudo apt-get autoremove -y
sudo apt-get autoclean

# 清理 OpenSearch
echo "正在清理 OpenSearch..."
sudo systemctl stop opensearch || true
sudo apt-get remove --purge opensearch -y || true
sudo rm -rf /etc/opensearch /var/lib/opensearch /var/log/opensearch/install_demo_configuration.log || true
sudo apt-get autoremove -y
sudo apt-get autoclean

# 重新安装组件
echo "正在重新安装组件..."
cd ~/magento-ansible-yaml

echo "安装 Percona MySQL..."
sudo ansible-playbook -i inventory.yml percona_playbook.yml

echo "安装 OpenSearch..."
sudo ansible-playbook -i inventory.yml opensearch_playbook.yml

echo "===== 组件修复完成 =====" 