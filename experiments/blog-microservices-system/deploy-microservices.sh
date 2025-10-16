#!/bin/bash

# Module 5 微服务博客系统部署脚本
# Author: GitHub Copilot
# Version: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/root/copilot-docker-experiments/experiments/blog-microservices-system"
LOG_FILE="$PROJECT_ROOT/deployment.log"

# 日志函数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}" | tee -a "$LOG_FILE"
}

# 检查依赖
check_dependencies() {
    log "检查系统依赖..."
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装或未在PATH中"
        exit 1
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose 未安装或未在PATH中"
        exit 1
    fi
    
    # 检查 Docker 服务状态
    if ! docker info &> /dev/null; then
        error "Docker 服务未运行"
        exit 1
    fi
    
    log "所有依赖检查通过"
}

# 清理旧容器和镜像
cleanup() {
    log "清理旧的容器和镜像..."
    
    cd "$PROJECT_ROOT"
    
    # 停止并删除容器
    docker-compose -f docker-compose.microservices.yml down --remove-orphans
    
    # 删除相关镜像 (可选)
    if [ "$1" == "--clean-images" ]; then
        log "删除相关镜像..."
        docker images | grep "blog-microservices" | awk '{print $3}' | xargs -r docker rmi -f
    fi
    
    # 清理未使用的资源
    docker system prune -f
    
    log "清理完成"
}

# 构建服务
build_services() {
    log "构建微服务镜像..."
    
    cd "$PROJECT_ROOT"
    
    # 构建所有服务
    docker-compose -f docker-compose.microservices.yml build --no-cache
    
    if [ $? -eq 0 ]; then
        log "微服务镜像构建成功"
    else
        error "微服务镜像构建失败"
        exit 1
    fi
}

# 启动服务
start_services() {
    log "启动微服务系统..."
    
    cd "$PROJECT_ROOT"
    
    # 启动所有服务
    docker-compose -f docker-compose.microservices.yml up -d
    
    if [ $? -eq 0 ]; then
        log "微服务系统启动成功"
    else
        error "微服务系统启动失败"
        exit 1
    fi
}

# 等待服务就绪
wait_for_services() {
    log "等待服务启动完成..."
    
    local max_attempts=60
    local attempt=0
    
    # 定义服务检查端点
    local services=(
        "http://localhost:8086/api/simple-status:API网关"
        "http://localhost:8086/api/users/health:用户服务"
        "http://localhost:8086/api/posts/health:文章服务" 
        "http://localhost:8086/api/comments/health:评论服务"
    )
    
    for service in "${services[@]}"; do
        local url=$(echo $service | cut -d: -f1-2)
        local name=$(echo $service | cut -d: -f3)
        local ready=false
        
        info "等待 $name 启动..."
        
        for ((i=1; i<=max_attempts; i++)); do
            if curl -s -f "$url" >/dev/null 2>&1; then
                log "$name 已就绪"
                ready=true
                break
            fi
            
            if [ $((i % 10)) -eq 0 ]; then
                warn "$name 仍在启动中... ($i/$max_attempts)"
            fi
            
            sleep 2
        done
        
        if [ "$ready" == false ]; then
            error "$name 启动超时"
            return 1
        fi
    done
    
    log "所有服务已就绪"
}

# 运行健康检查
health_check() {
    log "执行系统健康检查..."
    
    local all_healthy=true
    
    # 检查容器状态
    info "检查容器状态..."
    local containers=$(docker-compose -f "$PROJECT_ROOT/docker-compose.microservices.yml" ps -q)
    
    for container in $containers; do
        local status=$(docker inspect -f '{{.State.Status}}' $container)
        local name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
        
        if [ "$status" == "running" ]; then
            log "✓ $name: 运行中"
        else
            error "✗ $name: $status"
            all_healthy=false
        fi
    done
    
    # 检查API端点
    info "检查API端点..."
    local endpoints=(
        "http://localhost:8086/api/simple-status:API网关状态"
        "http://localhost:8086/api/users/health:用户服务健康检查"
        "http://localhost:8086/api/posts/health:文章服务健康检查"
        "http://localhost:8086/api/comments/health:评论服务健康检查"
    )
    
    for endpoint in "${endpoints[@]}"; do
        local url=$(echo $endpoint | cut -d: -f1-2)
        local desc=$(echo $endpoint | cut -d: -f3)
        
        if curl -s -f "$url" >/dev/null 2>&1; then
            log "✓ $desc"
        else
            error "✗ $desc"
            all_healthy=false
        fi
    done
    
    if [ "$all_healthy" == true ]; then
        log "系统健康检查通过"
        return 0
    else
        error "系统健康检查失败"
        return 1
    fi
}

# 显示系统信息
show_system_info() {
    log "显示系统信息..."
    
    echo -e "\n${GREEN}=== Module 5 微服务博客系统 ===${NC}"
    echo -e "${BLUE}项目地址:${NC} $PROJECT_ROOT"
    echo -e "${BLUE}系统状态:${NC} 运行中"
    echo ""
    
    echo -e "${GREEN}=== 服务访问地址 ===${NC}"
    echo -e "${BLUE}前端界面:${NC} http://localhost:8086"
    echo -e "${BLUE}API网关:${NC} http://localhost:8086/api"
    echo -e "${BLUE}管理界面:${NC} http://localhost:8087"
    echo -e "${BLUE}数据库管理:${NC} http://localhost:8088"
    echo ""
    
    echo -e "${GREEN}=== 微服务端口 ===${NC}"
    echo -e "${BLUE}API网关:${NC} 8086 (主要), 8087 (管理)"
    echo -e "${BLUE}用户服务:${NC} 3001 (内部)"
    echo -e "${BLUE}文章服务:${NC} 3002 (内部)"
    echo -e "${BLUE}评论服务:${NC} 3003 (内部)"
    echo -e "${BLUE}数据库:${NC} 3308"
    echo -e "${BLUE}缓存:${NC} 6382"
    echo ""
    
    echo -e "${GREEN}=== 管理命令 ===${NC}"
    echo -e "${BLUE}查看日志:${NC} docker-compose -f docker-compose.microservices.yml logs -f"
    echo -e "${BLUE}停止系统:${NC} docker-compose -f docker-compose.microservices.yml down"
    echo -e "${BLUE}重启系统:${NC} docker-compose -f docker-compose.microservices.yml restart"
    echo ""
    
    echo -e "${GREEN}=== 测试账户 ===${NC}"
    echo -e "${BLUE}用户名:${NC} testuser"
    echo -e "${BLUE}密码:${NC} 123456"
    echo ""
}

# 创建测试数据
create_test_data() {
    log "创建测试数据..."
    
    # 等待服务完全就绪
    sleep 10
    
    # 创建测试用户
    info "创建测试用户..."
    curl -s -X POST "http://localhost:8086/api/users/register" \
        -H "Content-Type: application/json" \
        -d '{"username":"testuser","email":"test@example.com","password":"123456"}' || true
    
    # 登录获取token
    info "获取登录token..."
    local token=$(curl -s -X POST "http://localhost:8086/api/users/login" \
        -H "Content-Type: application/json" \
        -d '{"username":"testuser","password":"123456"}' | \
        grep -o '"token":"[^"]*"' | cut -d'"' -f4) || true
    
    if [ -n "$token" ]; then
        # 创建示例文章
        info "创建示例文章..."
        
        curl -s -X POST "http://localhost:8086/api/posts" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d '{"title":"欢迎使用Module 5微服务博客系统","content":"这是一个基于Docker Compose的微服务架构示例。\n\n系统特点：\n1. 用户认证服务 - JWT令牌认证\n2. 文章管理服务 - Redis缓存优化\n3. 评论系统服务 - 多级评论支持\n4. API网关 - Nginx负载均衡\n5. 数据库服务 - MySQL 8.0\n6. 缓存服务 - Redis 7\n\n感谢体验！"}' || true
        
        curl -s -X POST "http://localhost:8086/api/posts" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d '{"title":"微服务架构的优势","content":"微服务架构具有以下优势：\n\n1. 服务独立部署\n2. 技术栈多样性\n3. 团队独立开发\n4. 故障隔离\n5. 水平扩展\n\n通过本系统，您可以深入了解微服务的实际应用。"}' || true
        
        log "测试数据创建完成"
    else
        warn "无法获取登录token，跳过测试数据创建"
    fi
}

# 主函数
main() {
    local action=${1:-"deploy"}
    
    echo -e "${GREEN}Module 5 微服务博客系统部署脚本${NC}"
    echo -e "${BLUE}开始时间: $(date)${NC}"
    echo ""
    
    case $action in
        "deploy"|"start")
            check_dependencies
            cleanup
            build_services
            start_services
            wait_for_services
            
            if health_check; then
                create_test_data
                show_system_info
                log "部署完成！系统已就绪。"
            else
                error "部署失败，请检查日志文件: $LOG_FILE"
                exit 1
            fi
            ;;
            
        "stop")
            log "停止微服务系统..."
            cd "$PROJECT_ROOT"
            docker-compose -f docker-compose.microservices.yml down
            log "系统已停止"
            ;;
            
        "restart")
            log "重启微服务系统..."
            cd "$PROJECT_ROOT"
            docker-compose -f docker-compose.microservices.yml restart
            wait_for_services
            if health_check; then
                show_system_info
                log "重启完成"
            fi
            ;;
            
        "status")
            health_check
            show_system_info
            ;;
            
        "logs")
            cd "$PROJECT_ROOT"
            docker-compose -f docker-compose.microservices.yml logs -f
            ;;
            
        "clean")
            cleanup --clean-images
            ;;
            
        *)
            echo "用法: $0 {deploy|start|stop|restart|status|logs|clean}"
            echo ""
            echo "命令说明:"
            echo "  deploy/start  - 部署并启动系统"
            echo "  stop         - 停止系统"
            echo "  restart      - 重启系统"
            echo "  status       - 查看系统状态"
            echo "  logs         - 查看系统日志"
            echo "  clean        - 清理系统资源"
            exit 1
            ;;
    esac
}

# 错误处理
trap 'error "脚本执行被中断"; exit 1' INT TERM

# 执行主函数
main "$@"