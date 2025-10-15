#!/bin/bash

# 博客系统快速验证脚本
# 用于验证系统是否可以正常启动和运行

echo "🔍 博客系统启动验证"
echo "===================="

# 检查当前目录
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ 错误: 请在 blog-compose-system 目录中运行此脚本"
    exit 1
fi

# 停止可能存在的容器
echo "🧹 清理旧容器..."
docker-compose down --remove-orphans 2>/dev/null

# 启动服务
echo "🚀 启动博客系统..."
docker-compose up -d

# 等待启动
echo "⏳ 等待服务启动 (30秒)..."
sleep 30

# 检查容器状态
echo "📊 检查容器状态..."
docker-compose ps

# 健康检查
echo ""
echo "🔍 执行健康检查..."

# 检查前端
if curl -s -f http://localhost > /dev/null; then
    echo "✅ 前端服务: 正常"
else
    echo "❌ 前端服务: 异常"
fi

# 检查健康端点
if curl -s -f http://localhost/health > /dev/null; then
    echo "✅ 健康检查: 正常"
else
    echo "❌ 健康检查: 异常"
fi

# 检查API
if curl -s -f http://localhost/posts > /dev/null; then
    echo "✅ API服务: 正常"
else
    echo "❌ API服务: 异常"
fi

echo ""
echo "🎯 验证完成！"
echo "访问地址:"
echo "- 主页: http://localhost"
echo "- 管理: http://localhost:8080"
echo ""
echo "停止服务: docker-compose down"