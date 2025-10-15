#!/bin/bash

# =============================================================================
# Docker实验环境系统巡检脚本
# 文件名: system_health_check.sh
# 作者: CloudZun (GitHub Copilot 辅助)
# 版本: v1.0
# 创建时间: 2025-10-15
# 描述: 用于定期检查Docker实验环境的系统健康状况
# =============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 日志文件设置
LOG_DATE=$(date +"%Y%m%d")
LOG_TIME=$(date +"%Y-%m-%d %H:%M:%S")
LOG_DIR="/root/copilot-docker-experiments/temp"
LOG_FILE="${LOG_DIR}/health_check_${LOG_DATE}.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志记录函数
log_message() {
    echo "[$LOG_TIME] $1" >> "$LOG_FILE"
    echo -e "$1"
}

# 检查结果记录
HEALTH_RESULTS=()

# 标题输出函数
print_header() {
    echo -e "${CYAN}============================================${NC}"
    echo -e "${WHITE}🔍 Docker实验环境系统巡检${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo -e "${YELLOW}📅 检查时间: $(date '+%Y年%m月%d日 %H:%M:%S')${NC}"
    echo -e "${YELLOW}📝 日志文件: $LOG_FILE${NC}"
    echo ""
}

# 1. 系统基础信息检查
check_system_info() {
    echo -e "${BLUE}🖥️ [1/7] 系统基础信息检查${NC}"
    echo "===================="
    
    local status="✅ 正常"
    
    echo -e "${CYAN}📅 当前时间:${NC} $(date)"
    echo -e "${CYAN}⏱️ 系统运行时间:${NC}"
    uptime
    echo ""
    echo -e "${CYAN}🐧 操作系统信息:${NC}"
    cat /etc/os-release | grep -E "(NAME|VERSION)" 
    echo ""
    echo -e "${CYAN}🔧 内核版本:${NC} $(uname -r)"
    echo -e "${CYAN}💻 主机名:${NC} $(hostname)"
    
    HEALTH_RESULTS+=("系统基础信息: $status")
    log_message "系统基础信息检查完成: $status"
    echo ""
}

# 2. CPU性能巡检
check_cpu_performance() {
    echo -e "${BLUE}🔥 [2/7] CPU性能巡检${NC}"
    echo "==============="
    
    local status="✅ 正常"
    
    echo -e "${CYAN}💿 CPU基本信息:${NC}"
    lscpu | grep -E "(CPU\(s\)|Model name|CPU MHz|Architecture)"
    echo ""
    echo -e "${CYAN}📊 CPU使用率 (实时1秒采样):${NC}"
    local cpu_info=$(top -bn1 | grep "Cpu(s)" | awk '{print "用户态: " $2 ", 系统态: " $4 ", 空闲: " $8}')
    echo "$cpu_info"
    echo ""
    echo -e "${CYAN}⚡ 系统负载:${NC}"
    local load_info=$(cat /proc/loadavg | awk '{print "1分钟: " $1 ", 5分钟: " $2 ", 15分钟: " $3}')
    echo "$load_info"
    echo ""
    echo -e "${CYAN}🔧 CPU频率信息:${NC}"
    cat /proc/cpuinfo | grep "cpu MHz" | head -4
    
    HEALTH_RESULTS+=("CPU性能: $status")
    log_message "CPU性能检查完成: $status - $cpu_info"
    echo ""
}

# 3. 内存状态分析
check_memory_status() {
    echo -e "${BLUE}🧠 [3/7] 内存状态分析${NC}"
    echo "================"
    
    local status="✅ 正常"
    
    echo -e "${CYAN}📈 内存使用概览:${NC}"
    free -h
    echo ""
    echo -e "${CYAN}🔍 详细内存信息:${NC}"
    cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)" | column -t
    echo ""
    echo -e "${CYAN}📊 内存使用率:${NC}"
    local mem_usage=$(free | awk 'NR==2{printf "内存使用率: %.2f%%", $3*100/$2}')
    local swap_usage=$(free | awk 'NR==3{if($2>0) printf "Swap使用率: %.2f%%", $3*100/$2; else print "Swap使用率: 0.00%"}')
    echo "$mem_usage"
    echo "$swap_usage"
    
    HEALTH_RESULTS+=("内存状态: $status")
    log_message "内存状态检查完成: $status - $mem_usage, $swap_usage"
    echo ""
}

# 4. 硬盘空间检查
check_disk_space() {
    echo -e "${BLUE}💾 [4/7] 硬盘空间检查${NC}"
    echo "================"
    
    local status="✅ 正常"
    
    echo -e "${CYAN}📊 磁盘使用情况:${NC}"
    df -h | grep -E "(Filesystem|/dev/)" | head -5
    echo ""
    echo -e "${CYAN}🗃️ 分区详情:${NC}"
    lsblk
    echo ""
    echo -e "${CYAN}⚡ 磁盘I/O统计:${NC}"
    iostat -d 1 1 2>/dev/null || echo "iostat 不可用，跳过I/O检查"
    echo ""
    
    # 检查磁盘使用率是否超过80%
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 80 ]; then
        status="⚠️ 警告 (使用率${disk_usage}%)"
    fi
    
    HEALTH_RESULTS+=("硬盘空间: $status")
    log_message "硬盘空间检查完成: $status - 使用率${disk_usage}%"
    echo ""
}

# 5. 网络连接测试
check_network_connectivity() {
    echo -e "${BLUE}🌐 [5/7] 网络连接测试${NC}"
    echo "================"
    
    local status="✅ 正常"
    
    echo -e "${CYAN}🔌 网络接口状态:${NC}"
    ip a | grep -E "(eth|enp|wlan)" | head -5
    echo ""
    echo -e "${CYAN}🎯 DNS解析测试:${NC}"
    if nslookup google.com > /dev/null 2>&1; then
        echo "✅ DNS解析正常"
    else
        echo "❌ DNS解析失败"
        status="❌ 异常"
    fi
    echo ""
    echo -e "${CYAN}🚀 外网连通性测试:${NC}"
    if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
        echo "✅ 外网连接正常"
    else
        echo "❌ 外网连接失败"
        status="❌ 异常"
    fi
    echo ""
    echo -e "${CYAN}🔗 网络端口监听:${NC}"
    netstat -tlnp | grep LISTEN | head -10
    
    HEALTH_RESULTS+=("网络连接: $status")
    log_message "网络连接检查完成: $status"
    echo ""
}

# 6. Docker运行时检查
check_docker_runtime() {
    echo -e "${BLUE}🐳 [6/7] Docker运行时检查${NC}"
    echo "==================="
    
    local status="✅ 正常"
    
    echo -e "${CYAN}🔧 Docker服务状态:${NC}"
    if systemctl is-active --quiet docker; then
        echo "✅ Docker服务运行正常"
    else
        echo "❌ Docker服务异常"
        status="❌ 异常"
    fi
    echo ""
    echo -e "${CYAN}📦 Docker版本信息:${NC}"
    docker --version
    docker-compose --version 2>/dev/null || echo "Docker Compose: 未安装或不可用"
    echo ""
    echo -e "${CYAN}📊 Docker资源使用:${NC}"
    docker system df
    echo ""
    echo -e "${CYAN}🏃 运行中的容器:${NC}"
    local container_count=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | wc -l)
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -15
    echo ""
    echo -e "${CYAN}📈 容器统计:${NC} 当前运行 $((container_count-1)) 个容器"
    
    HEALTH_RESULTS+=("Docker运行时: $status")
    log_message "Docker运行时检查完成: $status - 运行容器数: $((container_count-1))"
    echo ""
}

# 7. 关键服务健康检查
check_key_services() {
    echo -e "${BLUE}🩺 [7/7] 关键服务健康检查${NC}"
    echo "===================="
    
    local status="✅ 正常"
    local failed_services=()
    
    echo -e "${CYAN}🎯 Web服务响应检查:${NC}"
    
    # 检查TradingAgents
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 | grep -q "200\|302"; then
        echo "✅ TradingAgents (8501): 服务正常"
    else
        echo "❌ TradingAgents (8501): 服务异常"
        failed_services+=("TradingAgents")
    fi
    
    # 检查Portainer
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 | grep -q "200\|302"; then
        echo "✅ Portainer (9000): 服务正常"
    else
        echo "❌ Portainer (9000): 服务异常"
        failed_services+=("Portainer")
    fi
    
    # 检查Beszel
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8090 | grep -q "200\|302"; then
        echo "✅ Beszel (8090): 服务正常"
    else
        echo "❌ Beszel (8090): 服务异常"
        failed_services+=("Beszel")
    fi
    
    # 检查NPM
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:81 | grep -q "200\|302"; then
        echo "✅ NPM (81): 服务正常"
    else
        echo "❌ NPM (81): 服务异常"
        failed_services+=("NPM")
    fi
    
    echo ""
    echo -e "${CYAN}🗄️ 数据库服务检查:${NC}"
    
    # 检查MongoDB
    if nc -z localhost 27018 2>/dev/null; then
        echo "✅ MongoDB (27018): 连接正常"
    else
        echo "❌ MongoDB (27018): 连接失败"
        failed_services+=("MongoDB")
    fi
    
    # 检查Redis
    if nc -z localhost 6380 2>/dev/null; then
        echo "✅ Redis (6380): 连接正常"
    else
        echo "❌ Redis (6380): 连接失败"
        failed_services+=("Redis")
    fi
    
    # 更新状态
    if [ ${#failed_services[@]} -gt 0 ]; then
        status="❌ 异常 (${failed_services[*]})"
    fi
    
    echo ""
    echo -e "${CYAN}📈 容器健康状态:${NC}"
    docker ps --format "{{.Names}}: {{.Status}}" | grep -E "(healthy|unhealthy)" | head -10
    
    HEALTH_RESULTS+=("关键服务: $status")
    log_message "关键服务检查完成: $status"
    echo ""
}

# 生成巡检报告
generate_report() {
    echo -e "${CYAN}============================================${NC}"
    echo -e "${WHITE}📋 系统巡检报告总结${NC}"
    echo -e "${CYAN}============================================${NC}"
    
    local all_normal=true
    
    for result in "${HEALTH_RESULTS[@]}"; do
        if [[ $result == *"✅ 正常"* ]]; then
            echo -e "${GREEN}$result${NC}"
        elif [[ $result == *"⚠️ 警告"* ]]; then
            echo -e "${YELLOW}$result${NC}"
            all_normal=false
        else
            echo -e "${RED}$result${NC}"
            all_normal=false
        fi
    done
    
    echo ""
    if $all_normal; then
        echo -e "${GREEN}🎉 系统整体状态: 健康运行${NC}"
        log_message "巡检完成: 系统整体状态健康"
    else
        echo -e "${YELLOW}⚠️ 系统整体状态: 发现问题，需要关注${NC}"
        log_message "巡检完成: 系统发现问题，需要关注"
    fi
    
    echo -e "${CYAN}📝 详细日志: $LOG_FILE${NC}"
    echo -e "${CYAN}📅 下次建议巡检时间: $(date -d '+1 day' '+%Y年%m月%d日')${NC}"
    echo ""
}

# 主函数
main() {
    # 清屏
    clear
    
    # 打印标题
    print_header
    
    # 执行各项检查
    check_system_info
    check_cpu_performance
    check_memory_status
    check_disk_space
    check_network_connectivity
    check_docker_runtime
    check_key_services
    
    # 生成报告
    generate_report
    
    # 记录完成时间
    log_message "系统巡检脚本执行完成"
}

# 脚本使用说明
show_usage() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -v, --version  显示版本信息"
    echo "  -q, --quiet    静默模式（仅输出错误）"
    echo ""
    echo "示例:"
    echo "  $0              # 执行完整的系统巡检"
    echo "  $0 -q           # 静默模式执行"
    echo ""
}

# 处理命令行参数
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -v|--version)
        echo "Docker实验环境系统巡检脚本 v1.0"
        echo "作者: CloudZun (GitHub Copilot 辅助)"
        exit 0
        ;;
    -q|--quiet)
        # 静默模式：重定向输出到日志文件
        main > "$LOG_FILE" 2>&1
        echo "巡检完成，详细日志请查看: $LOG_FILE"
        ;;
    "")
        # 正常模式
        main
        ;;
    *)
        echo "错误: 未知参数 '$1'"
        show_usage
        exit 1
        ;;
esac