#!/bin/bash

# Blog Production System - 系统状态监控脚本
# Module 6: 生产级微服务博客系统

set -e

echo "📊 Blog Production System - 系统状态报告"
echo "=========================================="

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取当前时间
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo -e "${BLUE}报告时间: $TIMESTAMP${NC}"
echo ""

# 1. 容器状态概览
echo "🐳 容器状态概览"
echo "--------------"
docker-compose -f docker-compose.production.yml ps
echo ""

# 2. 资源使用情况
echo "💻 系统资源使用"
echo "-------------"

# CPU和内存概览
echo "系统整体资源:"
echo "$(free -h | head -2 | tail -1 | awk '{print "  内存: "$3" / "$2" (使用率: "int($3/$2*100)"%)"}')"
echo "$(uptime | awk '{print "  负载: "$10" "$11" "$12}')"
echo ""

# 容器资源使用详情
echo "容器资源使用详情:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}" | head -15
echo ""

# 3. 服务健康状态
echo "🏥 服务健康状态"
echo "-------------"

# 检查关键服务端口
check_port() {
    local service=$1
    local port=$2
    local url=$3
    
    if netstat -tuln | grep ":$port " > /dev/null 2>&1; then
        if [ ! -z "$url" ] && curl -s -f --max-time 5 "$url" > /dev/null 2>&1; then
            echo -e "  $service (端口 $port): ${GREEN}✅ 运行正常${NC}"
        else
            echo -e "  $service (端口 $port): ${YELLOW}⚠️ 端口开放，服务响应异常${NC}"
        fi
    else
        echo -e "  $service (端口 $port): ${RED}❌ 服务未运行${NC}"
    fi
}

check_port "Nginx API网关" "80" "http://localhost/health"
check_port "MySQL数据库" "3306"
check_port "Redis缓存" "6379"
check_port "Grafana监控" "3000" "http://localhost:3000/api/health"
check_port "Prometheus" "9090" "http://localhost:9090/-/healthy"
check_port "Elasticsearch" "9200" "http://localhost:9200/_cluster/health"
check_port "Kibana" "5601" "http://localhost:5601/api/status"

echo ""

# 4. 微服务状态
echo "🔌 微服务状态"
echo "------------"

# 检查微服务健康状态
check_microservice() {
    local service=$1
    local url=$2
    
    if curl -s -f --max-time 5 "$url" > /dev/null 2>&1; then
        # 获取响应时间
        response_time=$(curl -o /dev/null -s -w "%{time_total}" --max-time 5 "$url")
        echo -e "  $service: ${GREEN}✅ 正常${NC} (响应时间: ${response_time}s)"
    else
        echo -e "  $service: ${RED}❌ 异常${NC}"
    fi
}

check_microservice "用户服务" "http://localhost/api/users/health"
check_microservice "文章服务" "http://localhost/api/posts/health" 
check_microservice "评论服务" "http://localhost/api/comments/health"

echo ""

# 5. 数据库状态
echo "🗄️ 数据库状态"
echo "------------"

# MySQL状态
echo "MySQL主库状态:"
if docker-compose -f docker-compose.production.yml exec -T mysql-master mysqladmin ping -h localhost --silent 2>/dev/null; then
    # 获取连接数
    connections=$(docker-compose -f docker-compose.production.yml exec -T mysql-master mysql -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | tail -1 | awk '{print $2}')
    # 获取查询数
    queries=$(docker-compose -f docker-compose.production.yml exec -T mysql-master mysql -e "SHOW STATUS LIKE 'Queries';" 2>/dev/null | tail -1 | awk '{print $2}')
    echo -e "  ${GREEN}✅ 运行正常${NC}"
    echo "  当前连接数: $connections"
    echo "  累计查询数: $queries"
else
    echo -e "  ${RED}❌ 连接失败${NC}"
fi

echo ""

# Redis状态
echo "Redis缓存状态:"
if docker-compose -f docker-compose.production.yml exec -T redis-cluster redis-cli ping | grep -q PONG 2>/dev/null; then
    # 获取内存使用
    memory_usage=$(docker-compose -f docker-compose.production.yml exec -T redis-cluster redis-cli info memory 2>/dev/null | grep "used_memory_human" | cut -d: -f2 | tr -d '\r')
    # 获取键数量
    keys_count=$(docker-compose -f docker-compose.production.yml exec -T redis-cluster redis-cli dbsize 2>/dev/null | tr -d '\r')
    echo -e "  ${GREEN}✅ 运行正常${NC}"
    echo "  内存使用: $memory_usage"
    echo "  键数量: $keys_count"
else
    echo -e "  ${RED}❌ 连接失败${NC}"
fi

echo ""

# 6. 网络状态
echo "🌐 网络状态"
echo "----------"
docker network ls | grep blog-production-system
echo ""

# 7. 存储状态
echo "💾 存储状态"
echo "----------"
echo "Docker卷使用情况:"
docker volume ls | grep blog-production-system
echo ""

echo "磁盘使用情况:"
df -h | grep -E "(Filesystem|/dev/|tmpfs)" | grep -v tmpfs | head -5
echo ""

# 8. 日志统计
echo "📝 最近日志统计"
echo "-------------"

# 检查错误日志
echo "最近1小时的错误日志 (前10条):"
if [ -d "logs" ]; then
    find logs -name "*.log" -mmin -60 2>/dev/null | xargs grep -i "error" 2>/dev/null | head -10 || echo "  未发现错误日志"
else
    echo "  日志目录不存在"
fi
echo ""

# 9. 性能指标摘要
echo "⚡ 性能指标摘要"
echo "-------------"

# 检查系统负载
load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
echo "系统负载 (1分钟): $load_avg"

# 检查内存使用率
mem_usage=$(free | awk 'FNR==2{printf "%.1f", $3/($3+$4)*100}')
echo "内存使用率: ${mem_usage}%"

# 检查磁盘使用率
disk_usage=$(df -h . | awk 'NR==2{print $(NF-1)}')
echo "磁盘使用率: $disk_usage"

echo ""

# 10. 监控建议
echo "💡 监控建议"
echo "----------"

# 根据指标给出建议
if (( $(echo "$load_avg > 2" | bc -l) )); then
    echo -e "${YELLOW}⚠️ 系统负载较高，建议检查CPU密集型进程${NC}"
fi

if (( $(echo "$mem_usage > 80" | bc -l) )); then
    echo -e "${YELLOW}⚠️ 内存使用率较高，建议检查内存泄漏${NC}"
fi

disk_usage_num=$(echo "$disk_usage" | sed 's/%//')
if [ "$disk_usage_num" -gt 85 ]; then
    echo -e "${YELLOW}⚠️ 磁盘空间不足，建议清理旧日志和数据${NC}"
fi

echo ""
echo "🔗 快速链接:"
echo "  - Grafana仪表板: http://localhost:3000"
echo "  - Prometheus指标: http://localhost:9090" 
echo "  - Kibana日志: http://localhost:5601"
echo "  - 应用前端: http://localhost"
echo ""
echo "📊 查看实时监控: ./scripts/deployment/health-check.sh"
echo "🔧 维护操作: ./scripts/maintenance/"