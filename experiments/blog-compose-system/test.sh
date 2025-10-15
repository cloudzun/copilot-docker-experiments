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
if curl -s -f http://localhost:8085 > /dev/null; then
    echo "✅ 前端服务: 正常"
else
    echo "❌ 前端服务: 异常"
fi

# 检查API健康
HEALTH_RESPONSE=$(curl -s http://localhost:8085/api/health 2>/dev/null)
if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✅ API健康检查: 正常"
else
    echo "❌ API健康检查: 异常"
fi

# 检查文章API
POSTS_RESPONSE=$(curl -s http://localhost:8085/api/posts 2>/dev/null)
if echo "$POSTS_RESPONSE" | grep -q "\[\]"; then
    echo "✅ 文章API: 正常 (空白数据库)"
elif echo "$POSTS_RESPONSE" | grep -q "\["; then
    echo "✅ 文章API: 正常 (包含数据)"
else
    echo "❌ 文章API: 异常"
fi

# 测试发布文章
echo ""
echo "🧪 测试发布文章..."
POST_RESPONSE=$(curl -s -X POST http://localhost:8085/api/posts \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"title":"测试文章","content":"这是一篇测试文章，验证系统功能正常。🎉"}' 2>/dev/null)

if echo "$POST_RESPONSE" | grep -q "Post created successfully"; then
    echo "✅ 文章发布: 正常"
    
    # 验证文章显示
    sleep 2
    POSTS_CHECK=$(curl -s http://localhost:8085/api/posts 2>/dev/null)
    if echo "$POSTS_CHECK" | grep -q "测试文章"; then
        echo "✅ 文章显示: 正常"
    else
        echo "❌ 文章显示: 异常"
    fi
else
    echo "❌ 文章发布: 异常"
fi

echo ""
echo "🎯 验证完成！"
echo "访问地址:"
echo "- 主页: http://localhost:8085"
echo "- 管理: http://localhost:8082"
echo ""
echo "停止服务: docker-compose down"