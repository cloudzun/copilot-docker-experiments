#!/bin/bash

# GitHub仓库推送脚本
# 检查远程仓库是否可用，然后推送代码

REPO_URL="https://github.com/cloudzun/copilot-docker-experiments.git"
PROJECT_DIR="/root/copilot-docker-experiments"

echo "🔍 检查GitHub仓库状态..."

# 检查仓库是否存在
if git ls-remote $REPO_URL &> /dev/null; then
    echo "✅ 仓库已存在，开始推送..."
    cd $PROJECT_DIR
    git push -u origin main
    if [ $? -eq 0 ]; then
        echo "🎉 推送成功！"
        echo "📋 仓库地址: $REPO_URL"
        echo "🌐 Web界面: https://github.com/cloudzun/copilot-docker-experiments"
    else
        echo "❌ 推送失败，请检查网络连接和权限"
    fi
else
    echo "⏳ 仓库尚未创建或不可访问"
    echo "📋 请在GitHub上创建仓库："
    echo "   - 仓库名: copilot-docker-experiments" 
    echo "   - 描述: 🐳 Docker Lab Infrastructure with AI-powered container management, monitoring, and TradingAgents platform"
    echo "   - 设置为Public"
    echo "   - 不要初始化README/gitignore/LICENSE"
    echo ""
    echo "🔄 创建完成后再次运行此脚本"
fi