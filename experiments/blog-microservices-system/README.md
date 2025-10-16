# Docker Compose 博客系统

这是一个完整的多容器博客系统演示项目，展示了 Docker Compose 在现代 Web 应用中的最佳实践。

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Compose 博客系统                   │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Nginx)     │  Backend (Node.js)  │  Admin (Adminer) │
│  端口: 8085           │  端口: 3000         │  端口: 8082       │
│  静态文件服务          │  RESTful API       │  数据库管理       │
│  反向代理             │  业务逻辑          │  SQL 查询工具      │
├─────────────────────────────────────────────────────────────┤
│           Database (MySQL)    │     Cache (Redis)            │
│           端口: 3307          │     端口: 6381              │
│           数据持久化          │     缓存优化                │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 快速开始

### 环境要求

- Docker Engine 20.10+
- Docker Compose 2.0+
- 可用端口：8085, 3000, 3307, 6381, 8082

### 一键启动

```bash
# 克隆或进入项目目录
cd blog-compose-system

# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 验证部署

1. **前端界面**: http://localhost:8085
   - 实时服务状态监控
   - 文章管理功能
   - 响应式设计

2. **数据库管理**: http://localhost:8082
   - 服务器：`database`
   - 用户名：`bloguser`
   - 密码：`secret123`
   - 数据库：`blog_system`

3. **健康检查**:
   ```bash
   curl http://localhost:8085/api/health
   curl http://localhost:8085/api/posts
   curl http://localhost:8085/api/stats
   ```

## 📁 项目结构

```
blog-compose-system/
├── docker-compose.yml          # 服务编排配置
├── nginx.conf                  # Nginx 反向代理配置
├── mysql.cnf                   # MySQL 字符集配置
├── README.md                   # 项目说明文档
├── deploy.sh                   # 一键部署脚本
├── test.sh                     # 系统测试脚本
├── backend/                    # 后端服务
│   ├── app.js                  # Node.js 应用主文件
│   ├── package.json            # 依赖配置
│   └── Dockerfile              # 后端镜像构建
├── frontend/                   # 前端服务
│   └── index.html              # 主页面（监控面板）
└── init-db/                    # 数据库初始化
    └── init.sql                # 建表脚本（无示例数据）
```

## 🎯 核心功能

### 1. 实时服务监控
- **服务状态检查**: 自动检测所有 5 个服务的健康状态
- **可视化面板**: 直观的状态指示器（绿色✅ / 红色❌）
- **自动刷新**: 每 30 秒自动更新状态
- **详细信息**: 显示服务描述和健康检查详情

### 2. 博客管理系统
- **文章发布**: 实时添加博客文章
- **文章列表**: 展示所有已发布的文章
- **UTF-8支持**: 完全支持中文、表情符号和特殊字符
- **数据持久化**: MySQL 数据库存储
- **缓存优化**: Redis 缓存提升性能

### 3. 容器编排特性
- **服务发现**: 容器间通过服务名通信
- **网络隔离**: 自定义网络确保安全
- **数据持久化**: 数据卷保证数据不丢失
- **一键部署**: 单命令启动整个系统
- **端口隔离**: 避免与现有服务冲突

### 4. 字符编码优化
- **数据库**: 使用 utf8mb4 字符集和 utf8mb4_unicode_ci 排序规则
- **API接口**: 明确指定 UTF-8 编码响应头
- **前端显示**: 正确处理多语言字符显示
- **缓存存储**: Redis 正确处理 Unicode 字符

## 🔧 技术栈

| 组件 | 技术 | 版本 | 说明 |
|------|------|------|------|
| **前端** | Nginx | 1.25-alpine | 静态文件服务 + 反向代理 |
| **后端** | Node.js + Express | 18-alpine | RESTful API 服务 |
| **数据库** | MySQL | 8.0 | 关系型数据库 |
| **缓存** | Redis | 7-alpine | 内存缓存数据库 |
| **管理** | Adminer | latest | Web 数据库管理工具 |

## 📊 API 接口

### 健康检查
```bash
GET /health              # 总体健康状态
GET /api/health          # API 健康检查
```

### 博客文章
```bash
GET /api/posts           # 获取文章列表
POST /api/posts          # 创建新文章
  Body: {"title": "标题", "content": "内容"}

GET /api/posts/:id       # 获取特定文章
GET /api/stats           # 获取系统统计信息
```

### 响应格式
```json
# 健康检查响应
{
  "status": "healthy",
  "timestamp": "2025-10-15T08:49:25.959Z",
  "services": {
    "database": "connected",
    "redis": "connected"
  }
}

# 文章列表响应
[
  {
    "id": 1,
    "title": "文章标题",
    "content": "文章内容...",
    "created_at": "2025-10-15T08:49:25.000Z"
  }
]
```

## 🔍 用户观测指南

### 1. 服务状态观测
访问主页面后，你可以观察到：

- **绿色指示器**: 服务运行正常
- **红色指示器**: 服务异常或连接失败
- **橙色脉动**: 正在检查服务状态

### 2. 日志监控
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### 3. 容器状态检查
```bash
# 查看容器运行状态
docker-compose ps

# 查看资源使用情况
docker stats
```

### 4. 数据库管理
- 访问 http://localhost:8082
- 使用 Adminer 可视化管理数据库
- 查看表结构、执行 SQL 查询
- 监控数据库性能指标

## 🛠️ 开发调试

### 构建和启动
```bash
# 重新构建镜像
docker-compose build

# 强制重建并启动
docker-compose up --build -d

# 查看服务状态
docker-compose ps
```

### 故障排除
```bash
# 检查网络连接
docker network ls
docker network inspect blog-compose-system_blog-network

# 进入容器调试
docker-compose exec backend sh
docker-compose exec db mysql -uroot -p

# 重启特定服务
docker-compose restart backend
```

### 性能监控
```bash
# 查看资源使用
docker stats $(docker-compose ps -q)

# 查看网络流量
docker-compose exec frontend ss -tuln
```

## 📈 生产环境注意事项

### 安全配置
- 修改默认密码（MySQL root 密码）
- 使用环境变量管理敏感信息
- 配置 HTTPS 和 SSL 证书
- 限制 Adminer 访问权限

### 性能优化
- 调整 MySQL 内存配置
- 配置 Redis 持久化策略
- 优化 Nginx 缓存设置
- 监控容器资源使用

### 数据备份
```bash
# 数据库备份
docker-compose exec db mysqldump -uroot -prootpassword blog_system > backup.sql

# 数据卷备份
docker run --rm -v blog-compose-system_db-data:/data -v $(pwd):/backup alpine tar czf /backup/db-backup.tar.gz /data
```

## 🤝 扩展功能

这个基础系统可以进一步扩展：

1. **用户认证系统**: 添加登录注册功能
2. **文件上传**: 支持图片和附件上传
3. **评论系统**: 添加文章评论功能
4. **搜索功能**: 全文搜索和标签分类
5. **API 文档**: 集成 Swagger 文档
6. **监控告警**: 集成 Prometheus + Grafana
7. **CI/CD**: 添加自动化部署流程

## 📚 学习价值

通过这个项目，你可以学习到：

- Docker Compose 多容器编排
- 微服务架构设计模式
- 前后端分离开发
- RESTful API 设计
- 数据库设计和优化
- 缓存策略应用
- 反向代理配置
- 容器网络和存储
- 健康检查和监控
- 生产环境部署考虑

## 🔗 相关链接

- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [Node.js 官方文档](https://nodejs.org/docs/)
- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [Redis 官方文档](https://redis.io/documentation)
- [Nginx 官方文档](https://nginx.org/docs/)

---

**项目说明**: 这是一个教学演示项目，展示了 Docker Compose 在真实 Web 应用中的使用方法。代码结构清晰，注释详细，适合作为学习容器化部署的参考案例。