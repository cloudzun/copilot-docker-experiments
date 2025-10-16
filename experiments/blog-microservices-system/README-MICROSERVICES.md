# Module 5 - 微服务博客系统

## 项目概述

基于Module 4的博客系统，本项目演示了如何将单体应用拆分为微服务架构。通过Docker Compose编排多个独立的服务，展示微服务设计模式的实际应用。

## 系统架构

```
                    ┌─────────────────┐
                    │   Frontend      │
                    │   (Static)      │
                    └─────────┬───────┘
                              │
                    ┌─────────▼───────┐
                    │   API Gateway   │
                    │   (Nginx)       │
                    └─────────┬───────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼────┐         ┌─────▼─────┐       ┌─────▼─────┐
    │  User   │         │   Post    │       │ Comment   │
    │ Service │         │  Service  │       │ Service   │
    │ (3001)  │         │  (3002)   │       │ (3003)    │
    └────┬────┘         └─────┬─────┘       └─────┬─────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                    ┌─────────▼───────┐
                    │     MySQL       │
                    │   Database      │
                    └─────────────────┘
```

## 快速开始

### 1. 一键部署
```bash
cd /root/copilot-docker-experiments/experiments/blog-microservices-system
chmod +x deploy-microservices.sh
./deploy-microservices.sh deploy
```

### 2. 访问系统
- **前端界面**: http://localhost:8086 或 http://192.168.14.201:8086
- **API网关**: http://localhost:8086/api
- **管理界面**: http://localhost:8087
- **数据库管理**: http://localhost:8088

### 3. 测试账户
- 用户名: `testuser`
- 密码: `123456`

## 微服务组件

### 🚪 API网关 (端口: 8086/8087)
- 请求路由和负载均衡
- 静态文件服务
- CORS处理
- 健康检查聚合

### 👤 用户服务 (端口: 3001)
- 用户注册和登录
- JWT令牌认证
- 密码加密存储
- 用户信息管理

### 📝 文章服务 (端口: 3002)
- 文章CRUD操作
- Redis缓存优化
- 搜索和分页
- 浏览量统计

### 💬 评论服务 (端口: 3003)
- 评论管理
- 多级回复
- 审核机制
- 评论统计

### 🗄️ 数据库 (端口: 3308)
- MySQL 8.0
- 数据持久化
- 事务支持

### ⚡ 缓存 (端口: 6382)
- Redis 7
- 性能优化
- 会话存储

## 系统管理

```bash
# 查看状态
./deploy-microservices.sh status

# 停止系统
./deploy-microservices.sh stop

# 重启系统
./deploy-microservices.sh restart

# 查看日志
./deploy-microservices.sh logs

# 完全清理
./deploy-microservices.sh clean
```

## 技术特性

- ✅ 微服务架构设计
- ✅ Docker Compose编排
- ✅ JWT认证系统
- ✅ Redis缓存策略
- ✅ API网关模式
- ✅ 健康检查机制
- ✅ 服务监控
- ✅ 一键部署脚本

## API端点示例

```bash
# 用户注册
POST /api/users/register
{
  "username": "testuser",
  "email": "test@example.com", 
  "password": "123456"
}

# 文章列表
GET /api/posts?page=1&limit=10

# 创建评论
POST /api/comments
{
  "post_id": 1,
  "content": "这是一条评论"
}
```

## 与Module 4对比

| 特性 | Module 4 (单体) | Module 5 (微服务) |
|------|----------------|------------------|
| 架构 | 单一服务 | 多个独立服务 |
| 认证 | 集成模块 | 独立用户服务 |
| 部署 | 简单 | 编排复杂 |
| 扩展 | 垂直扩展 | 水平扩展 |
| 隔离 | 模块隔离 | 服务隔离 |

## 故障排除

1. **端口冲突**: 检查8086、8087、8088、3308、6382端口
2. **服务启动失败**: 查看日志 `./deploy-microservices.sh logs`
3. **数据库连接**: 检查MySQL服务状态
4. **API调用失败**: 验证JWT令牌和API端点

## 学习目标

完成本模块，您将掌握：
- 微服务架构设计
- Docker多服务编排
- API网关实现
- 服务间通信
- 分布式系统部署
- 微服务监控运维

---

**注意**: 本项目用于教学演示，生产环境需要额外的安全加固和性能优化。