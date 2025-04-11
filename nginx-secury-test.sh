#!/bin/bash
# 安全测试脚本 - 自动测试多种类型的安全防护机制

echo "=== LEMP栈安全测试脚本 ==="
echo "测试开始时间: $(date)"
echo

# 创建测试日志文件
LOG_FILE="security_test_results_$(date +%Y%m%d_%H%M%S).log"
echo "测试结果将保存到: $LOG_FILE"
echo "========================================" > $LOG_FILE
echo "安全测试结果 - $(date)" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# 检查ModSecurity状态
echo -e "\n\n=== ModSecurity状态检查 ===" | tee -a $LOG_FILE
if grep -q "modsecurity on" /etc/nginx/nginx.conf; then
  echo "✅ ModSecurity已启用" | tee -a $LOG_FILE
else
  echo "❌ ModSecurity未启用" | tee -a $LOG_FILE
fi

# 测试常见Web攻击向量
echo -e "\n\n=== 测试Web应用安全防护 ===" | tee -a $LOG_FILE

# 1. SQL注入测试
echo -e "\n-- SQL注入测试 --" | tee -a $LOG_FILE
SQL_RESULT=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/?id=1%27%20OR%20%271%27=%271")
if [[ "$SQL_RESULT" == "403" || "$SQL_RESULT" == "400" ]]; then
  echo "✅ SQL注入防护正常 (返回代码: $SQL_RESULT)" | tee -a $LOG_FILE
else
  echo "❌ SQL注入可能未被阻止 (返回代码: $SQL_RESULT)" | tee -a $LOG_FILE
fi

# 2. XSS攻击测试
echo -e "\n-- XSS攻击测试 --" | tee -a $LOG_FILE
XSS_RESULT=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/?xss=<script>alert(1)</script>")
if [[ "$XSS_RESULT" == "403" || "$XSS_RESULT" == "400" ]]; then
  echo "✅ XSS防护正常 (返回代码: $XSS_RESULT)" | tee -a $LOG_FILE
else
  echo "❌ XSS可能未被阻止 (返回代码: $XSS_RESULT)" | tee -a $LOG_FILE
fi

# 3. 路径遍历测试
echo -e "\n-- 路径遍历测试 --" | tee -a $LOG_FILE
PATH_RESULT=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/?file=../../../etc/passwd")
if [[ "$PATH_RESULT" == "403" || "$PATH_RESULT" == "400" ]]; then
  echo "✅ 路径遍历防护正常 (返回代码: $PATH_RESULT)" | tee -a $LOG_FILE
else
  echo "❌ 路径遍历可能未被阻止 (返回代码: $PATH_RESULT)" | tee -a $LOG_FILE
fi

# 4. 命令注入测试
echo -e "\n-- 命令注入测试 --" | tee -a $LOG_FILE
CMD_RESULT=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/?cmd=cat%20/etc/passwd")
if [[ "$CMD_RESULT" == "403" || "$CMD_RESULT" == "400" ]]; then
  echo "✅ 命令注入防护正常 (返回代码: $CMD_RESULT)" | tee -a $LOG_FILE
else
  echo "❌ 命令注入可能未被阻止 (返回代码: $CMD_RESULT)" | tee -a $LOG_FILE
fi

# 5. 查看ModSecurity日志
echo -e "\n-- ModSecurity日志分析 --" | tee -a $LOG_FILE
if [ -f /var/log/nginx/modsec_audit.log ]; then
  AUDIT_LINES=$(sudo tail -n 20 /var/log/nginx/modsec_audit.log | wc -l)
  echo "ModSecurity审计日志存在，最近有 $AUDIT_LINES 条记录" | tee -a $LOG_FILE
  echo "最近的拦截记录:" | tee -a $LOG_FILE
  sudo grep -m 5 "Access denied" /var/log/nginx/modsec_audit.log | tee -a $LOG_FILE
else
  echo "未找到ModSecurity审计日志" | tee -a $LOG_FILE
fi

# 检查TLS配置
echo -e "\n\n=== TLS/SSL安全测试 ===" | tee -a $LOG_FILE
if command -v openssl >/dev/null 2>&1; then
  echo -e "\n-- 支持的TLS协议版本 --" | tee -a $LOG_FILE
  for v in ssl2 ssl3 tls1 tls1_1 tls1_2 tls1_3; do
    result=$(openssl s_client -connect localhost:443 -$v 2>&1)
    if echo "$result" | grep -q "CONNECTED"; then
      if [[ "$v" == "ssl2" || "$v" == "ssl3" || "$v" == "tls1" || "$v" == "tls1_1" ]]; then
        echo "❌ 不安全协议 $v 已启用" | tee -a $LOG_FILE
      else
        echo "✅ 安全协议 $v 已启用" | tee -a $LOG_FILE
      fi
    else
      if [[ "$v" == "ssl2" || "$v" == "ssl3" || "$v" == "tls1" || "$v" == "tls1_1" ]]; then
        echo "✅ 不安全协议 $v 已禁用" | tee -a $LOG_FILE
      else
        echo "❓ 安全协议 $v 未启用" | tee -a $LOG_FILE
      fi
    fi
  done
else
  echo "未安装OpenSSL，无法测试TLS配置" | tee -a $LOG_FILE
fi

# 检查HTTP安全头
echo -e "\n\n=== HTTP安全头测试 ===" | tee -a $LOG_FILE
HEADERS=$(curl -s -I http://localhost)

# 检查常见安全头
for header in "X-Content-Type-Options" "X-Frame-Options" "X-XSS-Protection" "Content-Security-Policy" "Referrer-Policy"; do
  if echo "$HEADERS" | grep -q "$header"; then
    echo "✅ 存在安全头: $header" | tee -a $LOG_FILE
    echo "    $(echo "$HEADERS" | grep "$header")" | tee -a $LOG_FILE
  else
    echo "❌ 缺少安全头: $header" | tee -a $LOG_FILE
  fi
done

# 检查防火墙状态
echo -e "\n\n=== 防火墙状态检查 ===" | tee -a $LOG_FILE
if command -v ufw >/dev/null 2>&1; then
  echo -e "\n-- UFW防火墙状态 --" | tee -a $LOG_FILE
  sudo ufw status | tee -a $LOG_FILE
else
  echo "未安装UFW防火墙" | tee -a $LOG_FILE
fi

# 总结
echo -e "\n\n=== 测试总结 ===" | tee -a $LOG_FILE
echo "测试完成时间: $(date)" | tee -a $LOG_FILE
echo "详细测试结果已保存至: $LOG_FILE" | tee -a $LOG_FILE
echo
echo "请检查测试结果并根据需要调整安全配置。"
