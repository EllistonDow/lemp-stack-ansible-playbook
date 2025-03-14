#!/bin/bash

# 创建一个空的 my.cnf 替代项
sudo mkdir -p /etc/mysql
sudo touch /etc/mysql/my.cnf

# 尝试添加 my.cnf 到替代项系统
sudo update-alternatives --install /etc/my.cnf my.cnf /etc/mysql/my.cnf 100 || true

# 强制移除包
sudo dpkg --purge --force-all percona-server-common

# 清理
sudo rm -f /etc/mysql/my.cnf
sudo rm -rf /etc/mysql

# 清理其他 MySQL 相关包
sudo apt-get autoremove -y

echo "清理完成" 