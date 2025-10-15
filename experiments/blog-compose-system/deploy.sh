#!/bin/bash

# Docker Compose 博客系统 - 一键部署脚本
# 作者: Copilot Docker Experiments
# 用途: 快速启动多容器博客演示系统

set -e

echo "🐳 Docker Compose 博客系统 - 一键部署"
echo "======================================"

# 检查 Docker 和 Docker Compose
echo "📋 检查环境依赖..."

if ! command -v docker &> /dev/null; then
    echo "❌ 错误: Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误: Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

echo "✅ Docker 环境检查通过"

# 检查端口占用
echo "📋 检查端口占用..."

PORTS=(80 3000 3306 6379 8080)
OCCUPIED_PORTS=()

for port in "${PORTS[@]}"; do
    if ss -tlnp | grep -q ":$port "; then
        OCCUPIED_PORTS+=($port)
    fi
done

if [ ${#OCCUPIED_PORTS[@]} -gt 0 ]; then
    echo "⚠️  警告: 以下端口已被占用: ${OCCUPIED_PORTS[*]}"
    echo "   请停止占用这些端口的服务或修改 docker-compose.yml 中的端口映射"
    read -p "是否继续部署? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "部署已取消"
        exit 1
    fi
fi

# 停止可能存在的旧容器
echo "🧹 清理旧的容器..."
docker-compose down --remove-orphans 2>/dev/null || true

# 构建并启动服务
echo "🚀 启动博客系统..."
docker-compose up -d --build

# 等待服务启动
echo "⏳ 等待服务启动完成..."
sleep 10

# 检查服务状态
echo "📊 检查服务状态..."
docker-compose ps

# 健康检查
echo "🔍 执行健康检查..."

MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s -f http://localhost/health > /dev/null 2>&1; then
        echo "✅ 服务健康检查通过!"
        break
    fi
    
    echo "⏳ 等待服务启动... ($((RETRY_COUNT+1))/$MAX_RETRIES)"
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT+1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ 服务启动超时，请检查日志："
    echo "   docker-compose logs"
    exit 1
fi

# 显示访问信息
echo ""
echo "🎉 博客系统部署成功!"
echo "======================================"
echo "📱 前端监控面板: http://localhost"
echo "🛠️  数据库管理:   http://localhost:8080"
echo "   - 用户名: root"
echo "   - 密码: rootpassword"
echo "   - 数据库: blog_system"
echo ""
echo "🔧 常用命令:"
echo "   查看日志: docker-compose logs -f"
echo "   查看状态: docker-compose ps"
echo "   停止服务: docker-compose down"
echo ""
echo "📚 更多信息请查看 README.md"

# 可选：打开浏览器
if command -v xdg-open &> /dev/null; then
    read -p "是否打开浏览器访问系统? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        xdg-open http://localhost
    fi
elif command -v open &> /dev/null; then
    read -p "是否打开浏览器访问系统? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        open http://localhost
    fi
fi

echo "✨ 部署完成，享受使用吧！"