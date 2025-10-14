#!/bin/bash

echo "=== 实验环境防火墙管理脚本 ==="
echo ""

case "$1" in
    "enable")
        echo "启用防火墙（生产环境模式）..."
        ufw --force enable
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 8080/tcp
        ufw allow 3000/tcp
        ufw allow 5000/tcp
        echo "✅ 防火墙已启用，只开放常用端口"
        ;;
    "disable")
        echo "关闭防火墙（实验环境模式）..."
        ufw --force disable
        echo "✅ 防火墙已关闭，所有端口开放"
        ;;
    "status")
        echo "当前防火墙状态："
        ufw status verbose
        ;;
    *)
        echo "用法: $0 {enable|disable|status}"
        echo ""
        echo "  enable  - 启用防火墙（生产环境模式）"
        echo "  disable - 关闭防火墙（实验环境模式）"
        echo "  status  - 查看防火墙状态"
        echo ""
        echo "当前状态："
        ufw status
        ;;
esac