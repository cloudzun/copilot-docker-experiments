#!/bin/bash

# Blog Production System - 一键启动脚本
# Module 6: 生产级微服务博客系统

set -e

echo "🚀 启动 Blog Production System (Module 6)..."

# 检查环境
echo "📋 检查运行环境..."

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装！请先安装 Docker"
    exit 1
fi

# 检查Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装！请先安装 Docker Compose"
    exit 1
fi

# 检查内存
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_MEM" -lt 8 ]; then
    echo "⚠️  警告: 系统内存少于 8GB (当前: ${TOTAL_MEM}GB)，可能影响性能"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查磁盘空间
AVAILABLE_SPACE=$(df -h . | awk 'NR==2{print $4}' | sed 's/G//')
if [ "${AVAILABLE_SPACE%.*}" -lt 20 ]; then
    echo "⚠️  警告: 可用磁盘空间少于 20GB (当前: ${AVAILABLE_SPACE}GB)"
fi

# 检查环境配置文件
if [ ! -f ".env" ]; then
    if [ -f ".env.production" ]; then
        echo "📝 复制生产环境配置..."
        cp .env.production .env
    else
        echo "❌ 未找到环境配置文件！请创建 .env 文件"
        exit 1
    fi
fi

# 创建必要的目录
echo "📁 创建数据目录..."
mkdir -p data/{mysql-master,mysql-slave,redis,prometheus,grafana,elasticsearch}
mkdir -p logs/{nginx,application}

# 检查端口占用
echo "🔍 检查端口占用情况..."
PORTS=(80 443 3000 3306 5601 6379 8080 9090 9100 9200)
OCCUPIED_PORTS=()

for port in "${PORTS[@]}"; do
    if netstat -tuln | grep ":$port " > /dev/null 2>&1; then
        OCCUPIED_PORTS+=($port)
    fi
done

if [ ${#OCCUPIED_PORTS[@]} -gt 0 ]; then
    echo "⚠️  以下端口已被占用: ${OCCUPIED_PORTS[*]}"
    echo "   这可能导致服务启动失败"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 构建自定义镜像 (如果需要)
echo "🔨 检查并构建自定义镜像..."
if [ -d "services" ]; then
    echo "   构建微服务镜像..."
    docker-compose -f docker-compose.production.yml build --parallel
fi

# 拉取基础镜像
echo "📥 拉取基础镜像..."
docker-compose -f docker-compose.production.yml pull

# 启动基础设施服务
echo "🏗️  启动基础设施服务..."
docker-compose -f docker-compose.production.yml up -d \
    mysql-master mysql-slave redis-cluster elasticsearch elasticsearch-logs

# 等待数据库启动
echo "⏳ 等待数据库启动..."
sleep 30

# 检查数据库连接
echo "🔍 检查数据库连接..."
for i in {1..30}; do
    if docker-compose -f docker-compose.production.yml exec -T mysql-master mysqladmin ping -h localhost --silent; then
        echo "✅ MySQL 主库已就绪"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ MySQL 主库启动超时"
        exit 1
    fi
    echo "   等待 MySQL 主库启动... ($i/30)"
    sleep 2
done

# 启动应用服务
echo "🚀 启动应用服务..."
docker-compose -f docker-compose.production.yml up -d \
    user-service post-service comment-service api-gateway

# 等待应用服务启动
echo "⏳ 等待应用服务启动..."
sleep 20

# 启动监控服务
echo "📊 启动监控服务..."
docker-compose -f docker-compose.production.yml up -d \
    prometheus grafana node-exporter cadvisor

# 启动日志服务
echo "📝 启动日志服务..."
docker-compose -f docker-compose.production.yml up -d \
    logstash kibana

echo ""
echo "🎉 Blog Production System 启动完成！"
echo ""
echo "📱 服务访问地址:"
echo "   博客前端:     http://localhost"
echo "   Grafana监控:  http://localhost:3000 (admin/admin123!)"
echo "   Prometheus:   http://localhost:9090"
echo "   Kibana日志:   http://localhost:5601"
echo ""
echo "🔍 检查服务状态:"
echo "   docker-compose -f docker-compose.production.yml ps"
echo ""
echo "📊 查看实时日志:"
echo "   docker-compose -f docker-compose.production.yml logs -f service-name"
echo ""
echo "🛑 停止所有服务:"
echo "   docker-compose -f docker-compose.production.yml down"

# 执行健康检查
echo ""
echo "🏥 执行健康检查..."
sleep 10
if [ -f "./scripts/deployment/health-check.sh" ]; then
    ./scripts/deployment/health-check.sh
else
    echo "⚠️  健康检查脚本不存在，请手动验证服务状态"
fi

echo ""
echo "✅ 部署完成！享受您的生产级微服务系统吧！"