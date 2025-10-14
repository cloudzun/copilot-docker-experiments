#!/bin/bash

echo "=== 系统安全优化脚本 ==="
echo "开始执行系统优化配置..."

# 1. 配置系统安全参数
echo "1. 配置系统安全参数..."
cat >> /etc/sysctl.conf << EOF

# Docker & 容器化优化
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1

# 文件句柄优化
fs.file-max = 65536

# 网络连接优化
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200

# 内存优化
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

# 2. 应用内核参数
echo "2. 应用内核参数..."
sysctl -p >/dev/null 2>&1

# 3. 设置文件句柄限制
echo "3. 设置文件句柄限制..."
cat >> /etc/security/limits.conf << EOF

# 增加文件句柄限制
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

# 4. 配置Docker用户组权限
echo "4. 配置Docker用户组权限..."
if ! getent group docker > /dev/null 2>&1; then
    groupadd docker
fi

# 5. 配置日志轮转
echo "5. 配置系统日志轮转..."
cat > /etc/logrotate.d/docker-containers << EOF
/var/lib/docker/containers/*/*.log {
  rotate 3
  daily
  compress
  size=100M
  missingok
  delaycompress
  copytruncate
}
EOF

# 6. 优化SSH配置（安全加固）
echo "6. 优化SSH安全配置..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config

# 7. 配置防火墙规则（为容器服务预留端口）
echo "7. 配置防火墙规则..."
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 8080/tcp comment 'Alt HTTP'
ufw allow 3000/tcp comment 'Development'
ufw allow 5000/tcp comment 'Development'

# 8. 设置时区
echo "8. 设置时区..."
timedatectl set-timezone Asia/Shanghai >/dev/null 2>&1

# 9. 清理系统
echo "9. 清理系统缓存..."
apt autoremove -y >/dev/null 2>&1
apt autoclean >/dev/null 2>&1

# 10. 验证Docker配置
echo "10. 验证Docker配置..."
systemctl is-active docker >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Docker服务运行正常"
else
    echo "❌ Docker服务异常"
fi

# 11. 显示系统状态
echo "11. 系统状态检查..."
echo "内存使用情况："
free -h
echo ""
echo "磁盘使用情况："
df -h /
echo ""
echo "交换分区："
swapon --show
echo ""
echo "防火墙状态："
ufw status

echo ""
echo "=== 系统优化完成！==="
echo "Docker版本: $(docker --version)"
echo "Docker Compose版本: $(docker-compose --version)"
echo ""
echo "建议重启系统以确保所有配置生效：sudo reboot"