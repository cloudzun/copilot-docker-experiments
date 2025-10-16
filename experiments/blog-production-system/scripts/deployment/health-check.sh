#!/bin/bash

# Blog Production System - 健康检查脚本
# Module 6: 生产级微服务博客系统

set -e

echo "🏥 Blog Production System - 健康检查"
echo "======================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查结果统计
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# 检查函数
check_service() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    local timeout=${4:-10}
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo -n "检查 $service_name ... "
    
    if curl -s -f --max-time $timeout "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 正常${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ 异常${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# 检查容器状态
check_container() {
    local container_name=$1
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo -n "检查容器 $container_name ... "
    
    if docker-compose -f docker-compose.production.yml ps $container_name | grep -q "Up"; then
        echo -e "${GREEN}✅ 运行中${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ 未运行${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# 开始检查
echo "🔍 开始健康检查..."
echo ""

# 1. 检查容器状态
echo "📦 检查容器状态"
echo "----------------"

check_container "api-gateway"
check_container "user-service"
check_container "post-service" 
check_container "comment-service"
check_container "mysql-master"
check_container "redis-cluster"
check_container "prometheus"
check_container "grafana"

echo ""

# 2. 检查服务健康状态
echo "🌐 检查服务健康状态"
echo "------------------"

check_service "API网关" "http://localhost/health"
check_service "前端应用" "http://localhost/"
check_service "Prometheus" "http://localhost:9090/-/healthy"
check_service "Grafana" "http://localhost:3000/api/health"

echo ""

# 3. 检查数据库连接
echo "🗄️  检查数据库连接"
echo "-----------------"

echo -n "检查 MySQL 主库连接 ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if docker-compose -f docker-compose.production.yml exec -T mysql-master mysqladmin ping -h localhost --silent 2>/dev/null; then
    echo -e "${GREEN}✅ 连接正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ 连接失败${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

echo -n "检查 Redis 连接 ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if docker-compose -f docker-compose.production.yml exec -T redis-cluster redis-cli ping | grep -q PONG 2>/dev/null; then
    echo -e "${GREEN}✅ 连接正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ 连接失败${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

echo ""

# 4. 检查微服务API
echo "🔌 检查微服务API"
echo "---------------"

# 用户服务健康检查
echo -n "检查用户服务API ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
USER_SERVICE_IP=$(docker-compose -f docker-compose.production.yml exec -T user-service hostname -i 2>/dev/null | tr -d '\r')
if [ ! -z "$USER_SERVICE_IP" ] && curl -s -f "http://localhost/api/users/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ API异常${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# 文章服务健康检查  
echo -n "检查文章服务API ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s -f "http://localhost/api/posts/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ API异常${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# 评论服务健康检查
echo -n "检查评论服务API ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s -f "http://localhost/api/comments/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ API异常${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

echo ""

# 5. 检查监控指标
echo "📊 检查监控指标"
echo "-------------"

echo -n "检查 Prometheus 指标采集 ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s "http://localhost:9090/api/v1/targets" | grep -q '"health":"up"' 2>/dev/null; then
    echo -e "${GREEN}✅ 指标采集正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ 指标采集异常${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# 如果Kibana已启动，检查日志系统
if docker-compose -f docker-compose.production.yml ps kibana | grep -q "Up" 2>/dev/null; then
    check_service "Kibana日志系统" "http://localhost:5601/api/status" 200 15
fi

echo ""

# 6. 系统资源检查
echo "💻 系统资源检查"
echo "-------------"

# 检查内存使用
echo -n "检查内存使用情况 ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
MEMORY_USAGE=$(free | awk 'FNR==2{printf "%.0f", $3/($3+$4)*100}')
if [ "$MEMORY_USAGE" -lt 90 ]; then
    echo -e "${GREEN}✅ 内存使用正常 (${MEMORY_USAGE}%)${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠️ 内存使用较高 (${MEMORY_USAGE}%)${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# 检查磁盘空间
echo -n "检查磁盘空间 ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
DISK_USAGE=$(df -h . | awk 'NR==2{print $(NF-1)}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${GREEN}✅ 磁盘空间充足 (已使用${DISK_USAGE}%)${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠️ 磁盘空间不足 (已使用${DISK_USAGE}%)${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

echo ""

# 7. 网络连通性检查
echo "🌐 网络连通性检查"
echo "---------------"

echo -n "检查容器间网络连通性 ... "
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if docker-compose -f docker-compose.production.yml exec -T user-service ping -c 1 mysql-master > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 网络连通正常${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ 网络连通异常${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

echo ""

# 生成检查报告
echo "📋 健康检查报告"
echo "============="
echo ""
echo "总检查项目: $TOTAL_CHECKS"
echo -e "通过项目: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "失败项目: ${RED}$FAILED_CHECKS${NC}"
echo ""

# 计算成功率
SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

if [ "$SUCCESS_RATE" -eq 100 ]; then
    echo -e "${GREEN}🎉 系统运行状态: 优秀 (${SUCCESS_RATE}%)${NC}"
    echo "   所有服务运行正常，系统处于健康状态！"
elif [ "$SUCCESS_RATE" -ge 80 ]; then
    echo -e "${YELLOW}⚠️  系统运行状态: 良好 (${SUCCESS_RATE}%)${NC}"
    echo "   大部分服务正常，建议检查失败的项目"
else
    echo -e "${RED}❌ 系统运行状态: 异常 (${SUCCESS_RATE}%)${NC}"
    echo "   多个服务存在问题，需要立即排查"
fi

echo ""

# 如果有失败项目，提供建议
if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo "🛠️ 故障排除建议:"
    echo "  1. 检查容器日志: docker-compose -f docker-compose.production.yml logs [service-name]"
    echo "  2. 重启问题服务: docker-compose -f docker-compose.production.yml restart [service-name]"
    echo "  3. 查看资源使用: docker stats"
    echo "  4. 检查网络状态: docker network ls"
    echo ""
fi

echo "💡 更多监控信息:"
echo "  - Grafana仪表板: http://localhost:3000"
echo "  - Prometheus指标: http://localhost:9090"
echo "  - 系统日志: docker-compose -f docker-compose.production.yml logs"

# 返回适当的退出代码
if [ "$SUCCESS_RATE" -ge 80 ]; then
    exit 0
else
    exit 1
fi