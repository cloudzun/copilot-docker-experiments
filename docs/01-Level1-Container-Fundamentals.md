# 01-Level1-Container-Fundamentals.md

# 📚 Level 1: 容器基础与Docker实践

> **学习目标**: 掌握Docker容器化基础技术，能够独立构建和管理多容器应用  
> **实战项目**: 个人博客系统 (前端+后端+数据库+缓存)  
> **前置要求**: Linux基础操作，基本的Web开发知识  
> **预计时长**: 2-3周 (可根据个人进度调整)

## 🎯 Level 1 学习路径概览

```
Module 1: Docker基础与概念 → Module 2: 镜像构建与管理 → Module 3: 容器网络与数据
      ↓                           ↓                         ↓
Module 4: 多容器编排 → Module 5: 微服务架构 → Module 6: 项目整合与优化
```

---

## 📖 Module 1: Docker基础与概念

### 🎯 学习目标
- 理解容器化技术的核心概念和价值
- 掌握Docker基本架构和核心组件
- 能够执行基本的容器生命周期管理操作

### 📚 理论学习 (2小时)

#### 1.1 容器 vs 虚拟机
```
┌─────────────────┬─────────────────┐
│   传统虚拟机     │    Docker容器    │
├─────────────────┼─────────────────┤
│ 完整的操作系统   │ 共享宿主机内核   │
│ 资源开销大      │ 轻量级，启动快   │
│ 隔离性强        │ 进程级隔离      │
│ 适合异构环境    │ 适合微服务     │
└─────────────────┴─────────────────┘
```

#### 1.2 Docker核心架构
- **Docker Engine**: 容器运行时引擎
- **Docker Images**: 只读的应用程序模板
- **Docker Containers**: 镜像的运行实例
- **Docker Registry**: 镜像仓库 (如Docker Hub)

#### 1.3 Linux容器技术基础
- **Namespaces**: 资源隔离 (PID, Network, Mount等)
- **Cgroups**: 资源限制和监控
- **Union File System**: 分层文件系统

### 🛠️ 实践操作 (4小时)

#### 1.4 环境验证与基本命令
```bash
# 验证Docker安装
docker --version
docker info

# 基本命令练习
docker pull nginx:latest        # 拉取镜像
docker images                   # 查看本地镜像
docker run -d -p 8080:80 nginx  # 运行容器
docker ps                       # 查看运行容器
docker logs <container_id>      # 查看日志
docker exec -it <container_id> /bin/bash  # 进入容器
docker stop <container_id>      # 停止容器
docker rm <container_id>        # 删除容器
```

#### 1.5 容器生命周期管理
```bash
# 容器状态转换
docker create nginx:latest      # 创建容器 (未启动)
docker start <container_id>     # 启动容器
docker pause <container_id>     # 暂停容器
docker unpause <container_id>   # 恢复容器
docker restart <container_id>   # 重启容器
docker kill <container_id>      # 强制停止容器
```

### 🎪 动手项目: 运行第一个Web应用

**项目目标**: 部署一个自定义的静态网站

```bash
# 1. 创建项目目录
mkdir my-first-website && cd my-first-website

# 2. 创建简单的HTML页面
cat > index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>我的第一个Docker网站</title>
</head>
<body>
    <h1>欢迎来到Docker世界！</h1>
    <p>这是我用Docker部署的第一个网站。</p>
</body>
</html>
EOF

# 3. 使用数据卷挂载运行
docker run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx:latest

# 4. 访问测试
curl http://localhost:8080
```

**🤖 AI辅助提示**: 使用GitHub Copilot生成Docker命令脚本和HTML模板

---

## 📖 Module 2: 镜像构建与Dockerfile

### 🎯 学习目标
- 掌握Dockerfile语法和最佳实践
- 理解镜像分层机制和缓存优化
- 能够构建自定义应用镜像

### 📚 理论学习 (2小时)

#### 2.1 Dockerfile核心指令
```dockerfile
FROM ubuntu:20.04           # 基础镜像
MAINTAINER author@email.com # 维护者信息
RUN apt-get update          # 执行命令
COPY src/ /app/            # 复制文件
ADD archive.tar.gz /opt/   # 添加文件(支持解压)
WORKDIR /app               # 设置工作目录
ENV NODE_ENV=production    # 设置环境变量
EXPOSE 3000                # 暴露端口
CMD ["npm", "start"]       # 默认启动命令
ENTRYPOINT ["./entrypoint.sh"]  # 入口点
```

#### 2.2 镜像分层与缓存机制
```
┌─────────────────┐ ← 应用层 (可写)
├─────────────────┤ ← Layer 4: CMD
├─────────────────┤ ← Layer 3: COPY
├─────────────────┤ ← Layer 2: RUN
├─────────────────┤ ← Layer 1: FROM
└─────────────────┘ ← 基础镜像 (只读)
```

#### 2.3 多阶段构建优化
```dockerfile
# 构建阶段
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 运行阶段
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 🛠️ 实践操作 (5小时)

#### 2.4 构建第一个自定义镜像
```dockerfile
# Dockerfile
FROM nginx:alpine

# 添加自定义配置
COPY nginx.conf /etc/nginx/nginx.conf

# 复制网站文件
COPY html/ /usr/share/nginx/html/

# 设置权限
RUN chmod -R 755 /usr/share/nginx/html

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80
```

#### 2.5 镜像构建与标记
```bash
# 构建镜像
docker build -t my-website:v1.0 .

# 查看构建历史
docker history my-website:v1.0

# 镜像标记
docker tag my-website:v1.0 my-website:latest

# 镜像大小分析
docker images my-website
```

### 🎪 动手项目: 构建个人静态博客

**项目目标**: 使用Hugo构建静态博客并容器化

```dockerfile
# 多阶段构建Dockerfile
FROM hugomods/hugo:latest AS builder

WORKDIR /src
COPY . .
RUN hugo --minify --gc

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=3s CMD \
  wget --quiet --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**🤖 AI辅助提示**: 让Copilot帮助优化Dockerfile并生成nginx配置

---

## 📖 Module 3: 容器网络与数据管理

### 🎯 学习目标
- 理解Docker网络模式和自定义网络
- 掌握数据持久化方案和最佳实践
- 能够实现容器间安全通信

### 📚 理论学习 (2小时)

#### 3.1 Docker网络模式
```bash
# 网络模式对比
bridge    # 默认模式，容器间可通过内网通信
host      # 直接使用宿主机网络
none      # 无网络连接
container # 共享其他容器的网络
```

#### 3.2 自定义网络创建
```bash
# 创建自定义桥接网络
docker network create --driver bridge my-network

# 查看网络详情
docker network inspect my-network

# 容器连接到指定网络
docker run -d --name app1 --network my-network nginx
```

#### 3.3 数据持久化方案
```
┌─────────────────┬─────────────────┬─────────────────┐
│   Data Volumes  │  Bind Mounts    │   tmpfs mounts  │
├─────────────────┼─────────────────┼─────────────────┤
│ Docker管理      │ 宿主机路径      │ 内存存储        │
│ 数据持久化      │ 完全控制        │ 临时数据        │
│ 容器间共享      │ 开发环境        │ 敏感数据        │
└─────────────────┴─────────────────┴─────────────────┘
```

### 🛠️ 实践操作 (6小时)

#### 3.4 网络配置实践
```bash
# 创建应用网络
docker network create blog-network

# 运行数据库容器
docker run -d \
  --name blog-db \
  --network blog-network \
  -e MYSQL_ROOT_PASSWORD=secret123 \
  -e MYSQL_DATABASE=blog \
  mysql:8.0

# 运行应用容器
docker run -d \
  --name blog-app \
  --network blog-network \
  -p 3000:3000 \
  -e DB_HOST=blog-db \
  my-blog-app:latest
```

#### 3.5 数据卷管理
```bash
# 创建命名卷
docker volume create blog-data

# 使用数据卷
docker run -d \
  --name database \
  -v blog-data:/var/lib/mysql \
  mysql:8.0

# 数据备份
docker run --rm \
  -v blog-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .
```

### 🎪 动手项目: 带数据库的动态博客

**项目目标**: 构建包含前端、后端、数据库的完整应用

```bash
# 网络和数据卷准备
docker network create blog-network
docker volume create mysql-data
docker volume create redis-data

# 数据库层
docker run -d \
  --name blog-mysql \
  --network blog-network \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=blog \
  -e MYSQL_USER=bloguser \
  -e MYSQL_PASSWORD=blogpass \
  mysql:8.0

# 缓存层
docker run -d \
  --name blog-redis \
  --network blog-network \
  -v redis-data:/data \
  redis:7-alpine

# 应用验证
docker exec blog-mysql mysql -u root -prootpass -e "SHOW DATABASES;"
```

**🤖 AI辅助提示**: 使用Copilot生成数据库初始化脚本和连接测试代码

---

## 📖 Module 4: Docker Compose多容器编排

### 🎯 学习目标
- 掌握YAML语法和Docker Compose配置
- 能够定义和管理多服务应用
- 理解服务依赖和启动顺序

### 📚 理论学习 (2小时)

#### 4.1 Docker Compose核心概念
```yaml
# docker-compose.yml 基本结构
version: '3.8'

services:          # 服务定义
  web:
    build: ./web
    ports:
      - "8080:80"
    depends_on:
      - database
  
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secret

networks:          # 网络定义
  default:
    driver: bridge

volumes:           # 数据卷定义
  db_data:
```

#### 4.2 环境配置管理
```bash
# .env 文件示例
DB_PASSWORD=secret123
APP_PORT=8080
NODE_ENV=production

# 在compose文件中使用
environment:
  - DB_PASSWORD=${DB_PASSWORD}
  - NODE_ENV=${NODE_ENV}
```

### 🛠️ 实践操作 (5小时)

#### 4.3 编写第一个Compose文件
```yaml
# docker-compose.yml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "8080:80"
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    build: ./backend
    environment:
      - DB_HOST=database
      - REDIS_HOST=cache
    depends_on:
      - database
      - cache
    networks:
      - app-network

  database:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_PASSWORD}
      - MYSQL_DATABASE=blog
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - app-network

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network

volumes:
  mysql_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

#### 4.4 Compose命令操作
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f backend

# 重启特定服务
docker-compose restart frontend

# 清理环境
docker-compose down -v
```

### 🎪 动手项目: 个人博客系统 v1.0

**项目目标**: 使用Compose编排完整的博客系统

```yaml
# docker-compose.yml
version: '3.8'

services:
  # 前端服务
  web:
    build: 
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - api
    restart: unless-stopped

  # 后端API服务
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - DB_HOST=database
      - DB_NAME=blog
      - DB_USER=bloguser
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=cache
    depends_on:
      - database
      - cache
    restart: unless-stopped

  # 数据库服务
  database:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=blog
      - MYSQL_USER=bloguser
      - MYSQL_PASSWORD=${DB_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init-scripts:/docker-entrypoint-initdb.d
    restart: unless-stopped

  # 缓存服务
  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  mysql_data:
  redis_data:
```

**🤖 AI辅助提示**: 让Copilot生成.env模板和服务健康检查配置

---

## 📖 Module 5: 微服务架构设计

### 🎯 学习目标
- 理解微服务架构设计原则
- 掌握服务拆分和API设计
- 实现服务间通信和数据一致性

### 📚 理论学习 (2小时)

#### 5.1 微服务架构原则
```
┌─────────────────────────────────────────────────┐
│               微服务设计原则                     │
├─────────────────────────────────────────────────┤
│ • 单一职责: 每个服务专注一个业务领域            │
│ • 自治性: 独立开发、部署、扩展                  │
│ • 去中心化: 避免单点故障                       │
│ • 故障隔离: 局部失败不影响整体                  │
│ • 技术多样性: 选择最适合的技术栈                │
└─────────────────────────────────────────────────┘
```

#### 5.2 服务拆分策略
- **业务领域驱动**: 按业务功能拆分
- **数据一致性**: 每个服务拥有独立数据库
- **API契约**: 定义清晰的服务接口
- **服务发现**: 动态发现和调用服务

#### 5.3 通信模式
```
同步通信: HTTP/REST API, gRPC
异步通信: 消息队列, 事件总线
数据同步: Event Sourcing, CQRS
```

### 🛠️ 实践操作 (5小时)

#### 5.4 微服务架构设计
```
个人博客系统微服务拆分:
├── user-service (用户管理)
│   ├── 用户注册/登录
│   ├── 个人资料管理
│   └── 权限控制
├── post-service (文章管理)
│   ├── 文章发布/编辑
│   ├── 文章分类/标签
│   └── 文章搜索
├── comment-service (评论系统)
│   ├── 评论发布/回复
│   ├── 评论审核
│   └── 评论统计
└── notification-service (通知服务)
    ├── 邮件通知
    ├── 站内消息
    └── 推送通知
```

#### 5.5 服务间通信实现
```yaml
# API Gateway 配置示例
services:
  api-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - post-service
      - comment-service

  user-service:
    build: ./services/user
    environment:
      - DB_HOST=user-db
      - SERVICE_PORT=3001

  post-service:
    build: ./services/post
    environment:
      - DB_HOST=post-db
      - USER_SERVICE_URL=http://user-service:3001
      - SERVICE_PORT=3002
```

### 🎪 动手项目: 微服务化博客系统

**项目目标**: 将单体应用拆分为微服务架构

```yaml
# docker-compose.microservices.yml
version: '3.8'

services:
  # API网关
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - post-service
      - comment-service

  # 用户服务
  user-service:
    build: ./services/user
    environment:
      - DB_HOST=user-db
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - user-db

  user-db:
    image: postgres:15
    environment:
      - POSTGRES_DB=users
      - POSTGRES_USER=userservice
      - POSTGRES_PASSWORD=${USER_DB_PASSWORD}
    volumes:
      - user_data:/var/lib/postgresql/data

  # 文章服务
  post-service:
    build: ./services/post
    environment:
      - DB_HOST=post-db
      - USER_SERVICE_URL=http://user-service:3001
    depends_on:
      - post-db

  post-db:
    image: postgres:15
    environment:
      - POSTGRES_DB=posts
      - POSTGRES_USER=postservice
      - POSTGRES_PASSWORD=${POST_DB_PASSWORD}
    volumes:
      - post_data:/var/lib/postgresql/data

volumes:
  user_data:
  post_data:
```

**🤖 AI辅助提示**: 使用Copilot设计RESTful API接口和数据模型

---

## 📖 Module 6: 项目整合与生产优化

### 🎯 学习目标
- 完成个人博客系统的所有功能模块
- 掌握生产环境部署和优化技巧
- 实现监控、日志和性能调优

### 📚 理论学习 (2小时)

#### 6.1 生产环境考虑因素
```
┌─────────────────────────────────────────────────┐
│               生产环境检查清单                   │
├─────────────────────────────────────────────────┤
│ ✅ 健康检查和存活探针                           │
│ ✅ 资源限制和请求配置                           │
│ ✅ 数据备份和恢复策略                           │
│ ✅ 日志收集和监控告警                           │
│ ✅ 安全配置和权限管理                           │
│ ✅ 高可用和故障转移                             │
└─────────────────────────────────────────────────┘
```

#### 6.2 容器优化最佳实践
- **镜像优化**: 使用Alpine、多阶段构建
- **安全强化**: 非root用户、最小权限原则
- **性能调优**: 资源限制、JVM参数优化
- **监控指标**: CPU、内存、网络、应用指标

### 🛠️ 实践操作 (8小时)

#### 6.3 生产级配置优化
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
```

#### 6.4 监控和日志配置
```yaml
# 添加监控服务
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped
```

### 🎪 最终项目: 生产就绪的个人博客系统

**项目目标**: 完成具有以下特性的完整博客系统

#### 功能特性清单:
```
✅ 用户管理
  - 用户注册/登录/注销
  - 个人资料管理
  - 头像上传

✅ 文章管理
  - 富文本编辑器
  - 文章发布/编辑/删除
  - 标签和分类管理
  - 文章搜索功能

✅ 评论系统
  - 多级评论回复
  - 评论审核机制
  - 垃圾评论过滤

✅ 系统特性
  - 响应式设计
  - SEO优化
  - 缓存策略
  - 图片压缩和CDN
```

#### 技术架构:
```
Frontend (React/Vue) → API Gateway (Nginx) → Microservices
                                              ├── User Service
                                              ├── Post Service
                                              ├── Comment Service
                                              └── Media Service
                     ↓
Data Layer: PostgreSQL + Redis + File Storage
Monitoring: Prometheus + Grafana
Logging: ELK Stack (可选)
```

**🤖 AI辅助提示**: 使用Copilot生成完整的前后端代码、API文档和部署脚本

---

## 🎯 Level 1 学习成果验收

### ✅ 技能掌握检查清单

#### 基础技能
- [ ] 理解Docker核心概念和架构
- [ ] 熟练使用Docker基本命令
- [ ] 能够编写优化的Dockerfile
- [ ] 掌握容器网络和数据管理

#### 进阶技能
- [ ] 使用Docker Compose编排多容器应用
- [ ] 设计和实现微服务架构
- [ ] 配置生产环境优化参数
- [ ] 实现基础监控和日志收集

#### 专家技能
- [ ] 能够排查常见容器问题
- [ ] 优化镜像大小和构建时间
- [ ] 设计高可用的容器化架构
- [ ] 指导他人进行容器化改造

### 🏆 项目交付成果

#### 必须交付:
1. **完整的个人博客系统**
   - 源代码 (前端 + 后端 + 数据库)
   - Docker镜像和Compose配置
   - 部署文档和操作手册

2. **技术文档**
   - 架构设计文档
   - API接口文档
   - 故障排除指南

3. **学习总结**
   - Docker最佳实践总结
   - 问题解决案例集
   - 技术博客文章

#### 加分项:
- 实现CI/CD自动部署
- 添加性能监控面板
- 编写自动化测试
- 发布到Docker Hub

### 📊 能力评估标准

| 等级 | 描述 | 评估标准 |
|------|------|----------|
| **入门** | 能运行基本容器 | 完成前3个模块 |
| **熟练** | 能设计多容器应用 | 完成所有6个模块 |
| **专家** | 能优化和排错 | 项目质量优秀 + 创新功能 |

---

## 🚀 进阶学习建议

### 📚 推荐阅读
- Docker官方文档和最佳实践
- 《容器即服务：Docker与Kubernetes》
- 《微服务架构设计模式》

### 🔧 工具推荐
- **开发**: VS Code + Docker扩展
- **监控**: Portainer, Grafana
- **测试**: Postman, K6
- **CI/CD**: GitHub Actions, Jenkins

### 🎯 下一步学习路径
完成Level 1后，建议继续学习：
- **Level 2**: 容器进阶与安全
- **Level 3**: Kubernetes编排
- **Level 4**: 云原生架构设计

---

## 🆘 常见问题与解决方案

### Q1: 容器无法启动怎么办？
```bash
# 检查容器日志
docker logs <container_name>

# 检查镜像是否存在
docker images

# 检查端口冲突
netstat -tlnp | grep :8080
```

### Q2: 如何优化镜像大小？
```dockerfile
# 使用Alpine基础镜像
FROM node:16-alpine

# 多阶段构建
FROM node:16 AS builder
# ... 构建步骤
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html

# 清理缓存
RUN apk add --no-cache curl && \
    rm -rf /var/cache/apk/*
```

### Q3: 容器间无法通信？
```bash
# 检查网络配置
docker network ls
docker network inspect <network_name>

# 使用服务名而非IP地址
# 正确: http://api-service:3000
# 错误: http://172.18.0.3:3000
```

**🤖 AI助手提示**: 遇到问题时，可以向GitHub Copilot描述具体的错误信息，获得针对性的解决方案。

---

**🎉 恭喜完成Level 1！您已经掌握了Docker容器化的核心技能，可以开始Level 2的学习之旅了！**