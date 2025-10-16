# Blog Production System - Module 6

## 🎯 项目概述

这是基于 **Module 5 微服务架构** 的生产级博客系统，添加了完整的监控运维体系和生产环境优化。该项目展示了如何将开发环境的微服务系统升级为企业级的生产部署。

### 🏗️ 架构演进

```
Module 4 (单体容器)  →  Module 5 (微服务化)  →  Module 6 (生产级优化)
     博客应用              JWT + 微服务           监控 + 运维 + 优化
```

### 📊 技术栈

**核心微服务** (继承自Module 5):
- **用户服务**: JWT认证、用户管理
- **文章服务**: 内容管理、搜索功能  
- **评论服务**: 评论系统、互动功能
- **API网关**: Nginx负载均衡、限流

**生产级增强** (Module 6新增):
- **监控系统**: Prometheus + Grafana
- **日志管理**: ELK Stack (Elasticsearch + Logstash + Kibana)
- **数据存储**: MySQL主从 + Redis集群
- **搜索引擎**: Elasticsearch
- **系统监控**: Node Exporter + cAdvisor

## 🚀 快速启动

### 前置要求

- Docker >= 20.10
- Docker Compose >= 2.0
- 至少 8GB 内存 (推荐 16GB)
- 至少 20GB 磁盘空间

### 一键启动

```bash
# 1. 克隆项目
git clone https://github.com/cloudzun/copilot-docker-experiments.git
cd copilot-docker-experiments/experiments/blog-production-system

# 2. 复制环境配置
cp .env.production .env

# 3. 启动生产环境 (完整版本)
./scripts/deployment/start-production.sh

# 或者分步启动
docker-compose -f docker-compose.production.yml up -d
```

### 快速验证

```bash
# 检查所有服务状态
./scripts/deployment/health-check.sh

# 查看服务日志
docker-compose -f docker-compose.production.yml logs -f user-service
```

## 📱 服务访问地址

### 应用服务
- **博客前端**: http://localhost
- **API网关**: http://localhost/api/

### 监控运维
- **Grafana仪表板**: http://localhost:3000 (admin/admin123!)
- **Prometheus指标**: http://localhost:9090
- **Kibana日志**: http://localhost:5601
- **Elasticsearch**: http://localhost:9200

### 数据存储
- **MySQL主库**: localhost:3306
- **Redis**: localhost:6379

## 🏗️ 系统架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Monitoring    │    │   Logging       │
│   (Nginx)       │    │   (Grafana)     │    │   (Kibana)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────│   Prometheus    │──────────────┘
                        │   (Metrics)     │
                        └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  User Service   │    │  Post Service   │    │Comment Service  │
│  (JWT Auth)     │    │  (Content)      │    │  (Interaction)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  MySQL Master   │    │  Redis Cluster  │    │ Elasticsearch   │
│  (Primary DB)   │    │  (Cache/Session)│    │  (Search)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
┌─────────────────┐
│  MySQL Slave    │
│  (Read Replica) │
└─────────────────┘
```

## 🔧 配置说明

### 环境变量 (.env.production)

```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=productionRoot123!
DB_PASSWORD=blogUserProd456!

# JWT配置
JWT_SECRET=your-super-secret-jwt-key-for-production

# 监控配置
GRAFANA_PASSWORD=admin123!

# 性能配置
MAX_MEMORY_MYSQL=2g
MAX_MEMORY_REDIS=512m
MAX_MEMORY_ELASTICSEARCH=1g
```

### 资源配置

| 服务 | CPU限制 | 内存限制 | 副本数 |
|------|---------|----------|--------|
| 用户服务 | 1.0 CPU | 1GB | 2 |
| 文章服务 | 1.0 CPU | 1GB | 2 |  
| 评论服务 | 1.0 CPU | 1GB | 2 |
| MySQL主库 | 2.0 CPU | 2GB | 1 |
| Redis | 0.5 CPU | 512MB | 1 |
| Grafana | 0.5 CPU | 512MB | 1 |

## 📊 监控指标

### 应用监控
- **服务可用性**: 健康检查、响应时间
- **业务指标**: 用户注册、文章发布、评论数量
- **错误率**: HTTP 4xx/5xx 错误统计
- **性能指标**: API响应时间、吞吐量

### 基础设施监控
- **系统资源**: CPU、内存、磁盘、网络
- **容器指标**: 容器资源使用、重启次数
- **数据库监控**: 连接数、慢查询、复制延迟
- **缓存监控**: Redis内存使用、命中率

### 告警规则
- 服务下线 > 1分钟 → 关键告警
- HTTP错误率 > 10% → 警告告警  
- 内存使用率 > 80% → 警告告警
- 磁盘空间 < 20% → 警告告警

## 🛠️ 运维操作

### 日常维护

```bash
# 查看系统状态
./scripts/maintenance/system-status.sh

# 数据库备份
./scripts/maintenance/backup-database.sh

# 清理旧日志
./scripts/maintenance/cleanup-logs.sh

# 性能报告
./scripts/maintenance/performance-report.sh
```

### 故障排查

```bash
# 检查服务健康状态
docker-compose -f docker-compose.production.yml ps

# 查看服务日志
docker-compose -f docker-compose.production.yml logs service-name

# 进入容器调试
docker-compose -f docker-compose.production.yml exec service-name /bin/bash

# 检查资源使用
docker stats

# 查看网络连接
docker network ls
docker network inspect blog-production-system_backend-network
```

### 性能优化

```bash
# MySQL慢查询分析
docker exec mysql-master mysqldumpslow /var/log/mysql/slow.log

# Redis内存分析
docker exec redis-cluster redis-cli info memory

# Nginx访问统计
docker exec api-gateway cat /var/log/nginx/access.log | tail -1000
```

## 📈 扩展指南

### 水平扩展

```bash
# 扩展用户服务实例
docker-compose -f docker-compose.production.yml up -d --scale user-service=3

# 扩展文章服务实例  
docker-compose -f docker-compose.production.yml up -d --scale post-service=3
```

### 添加新的微服务

1. 在 `services/` 目录下创建新服务
2. 更新 `docker-compose.production.yml`
3. 添加对应的监控配置
4. 更新Nginx路由规则

### 数据库读写分离

MySQL主从已配置完成，应用层需要实现读写分离:

```javascript
// 读操作使用从库
const readDB = mysql.createConnection({
  host: 'mysql-slave',
  // ...
});

// 写操作使用主库
const writeDB = mysql.createConnection({
  host: 'mysql-master',  
  // ...
});
```

## 🔒 安全配置

### 网络安全
- 服务间通信使用独立网络
- 前端网络与后端网络隔离
- 数据库不直接暴露到公网

### 应用安全
- JWT Token认证 (继承自Module 5)
- API限流防护
- SQL注入防护
- XSS防护头配置

### 运维安全
- 敏感信息环境变量化
- 容器运行非root用户
- 定期安全更新

## 🧪 测试验证

### 功能测试

```bash
# 基础功能测试
./scripts/test/api-test.sh

# 负载测试
./scripts/test/load-test.sh

# 监控测试
./scripts/test/monitoring-test.sh
```

### 性能基准

| 指标 | 目标值 | 当前值 |
|------|--------|--------|
| 用户注册响应时间 | < 500ms | ~300ms |
| 文章列表加载时间 | < 200ms | ~150ms |
| 并发用户数 | > 1000 | ~800 |
| 系统可用性 | 99.9% | 99.5% |

## 📚 相关文档

- [Module 4: 单体容器化](../blog-compose-system/README.md)
- [Module 5: 微服务架构](../blog-microservices-system/README.md)
- [运维手册](./docs/operations-guide.md)
- [监控配置指南](./docs/monitoring-setup.md)
- [故障排除指南](./docs/troubleshooting.md)

## 🤝 技术支持

如有问题，请查看:
1. [常见问题文档](./docs/faq.md)
2. [GitHub Issues](https://github.com/cloudzun/copilot-docker-experiments/issues)
3. 运行 `./scripts/diagnostics.sh` 生成诊断报告

---

**🎉 恭喜！您已经完成了从Module 4到Module 6的完整容器化学习之旅！**

这个生产级系统展示了现代微服务架构的完整实践，为进入DevOps高级学习奠定了坚实基础。