# Docker实验环境部署记录 - 2025年10月14日

## 📋 实验概览
- **日期**: 2025年10月14日
- **项目**: Docker容器化实验环境
- **状态**: ✅ 部署完成
- **架构原则**: MVP (最小可行产品) - 简化配置，优先可用性

## 🏗️ 系统架构设计

### 网络架构 (MVP原则)
- **网络模式**: Docker默认bridge网络 (172.17.0.0/16)
- **设计理念**: 避免复杂的自定义网络配置
- **容器通信**: 通过内网IP地址直接访问

### 域名规划
```
# Windows hosts文件配置 (C:\Windows\System32\drivers\etc\hosts)
192.168.14.201  huaqloud.local
192.168.14.201  portal.huaqloud.local      # Portainer管理界面
192.168.14.201  monitor.huaqloud.local     # Beszel监控界面
192.168.14.201  npm.huaqloud.local         # Nginx Proxy Manager
192.168.14.201  game.huaqloud.local        # 2048游戏演示
192.168.14.201  trading.huaqloud.local     # TradingAgents-CN交易分析
192.168.14.201  redis.huaqloud.local       # Redis Commander管理
192.168.14.201  mongo.huaqloud.local       # Mongo Express管理
```

## 🐳 Docker环境基础

### 系统信息
- **操作系统**: Ubuntu 20.04.6 LTS
- **Docker版本**: 26.1.3
- **CPU**: 4核 Intel处理器
- **内存**: 7.8GB RAM
- **网络**: 124+ Mbps带宽，延迟良好

### 防火墙配置
```bash
# 系统防火墙已配置允许必要端口
ufw allow 9000/tcp    # Portainer
ufw allow 8090/tcp    # Beszel
ufw allow 80/tcp      # NPM HTTP
ufw allow 443/tcp     # NPM HTTPS
ufw allow 81/tcp      # NPM管理
ufw allow 2048/tcp    # 游戏演示
```

## 🎛️ Portainer容器管理平台

### 部署配置 (MVP简化版)
```bash
# 创建数据卷
docker volume create portainer_data

# 部署容器 - 使用默认bridge网络
docker run -d --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### 服务状态
- **容器名称**: portainer
- **内网IP**: 172.17.0.2
- **端口映射**: 9000:9000
- **网络模式**: bridge (默认)
- **数据持久化**: ✅ portainer_data卷
- **状态**: ✅ 运行正常

### 访问方式
- **直接访问**: http://192.168.14.201:9000
- **域名访问**: http://portal.huaqloud.local (通过NPM反向代理)
- **管理功能**: 容器/镜像/网络/卷的图形化管理

## 📊 Beszel监控平台

### Hub部署
```bash
# 使用默认bridge网络的简化配置
docker run -d --name beszel \
  -p 8090:8090 \
  -v /root/beszel_data:/beszel_data \
  henrygd/beszel
```

### Agent部署
```bash
# Agent使用默认bridge网络
docker run -d --name beszel-agent \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v ./beszel_agent_data:/var/lib/beszel-agent \
  -e KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIofTsQda5uRj+CvnlhDc0Igb7zfOUwvh/deoyFwiY8k" \
  -e LISTEN=45876 \
  -e TOKEN="1a45-3202aab93-37e-3159b22d8da" \
  -e HUB_URL="http://192.168.14.201:8090" \
  henrygd/beszel-agent
```

### 服务状态
- **Hub容器**: beszel (172.17.0.4)
- **Agent容器**: beszel-agent (bridge网络)
- **连接状态**: ✅ WebSocket连接成功
- **监控数据**: ✅ 系统和容器指标正常收集

### 访问方式
- **直接访问**: http://192.168.14.201:8090
- **域名访问**: http://monitor.huaqloud.local (通过NPM反向代理)

## 🚀 Nginx Proxy Manager反向代理

### 部署配置
```bash
# 使用默认bridge网络
docker run -d --name nginx-proxy-manager \
  -p 80:80 -p 81:81 -p 443:443 \
  -v /root/nginx-proxy-manager/data:/data \
  -v /root/nginx-proxy-manager/letsencrypt:/etc/letsencrypt \
  jc21/nginx-proxy-manager:latest
```

### 服务状态
- **容器名称**: nginx-proxy-manager
- **内网IP**: 172.17.0.5
- **端口映射**: 80:80, 443:443, 81:81
- **网络模式**: bridge (默认)
- **管理界面**: http://192.168.14.201:81

### 代理配置 (使用内网IP)
1. **Portainer代理**:
   - Domain: portal.huaqloud.local
   - Forward to: 172.17.0.2:9000

2. **Beszel代理**:
   - Domain: monitor.huaqloud.local
   - Forward to: 172.17.0.4:8090

3. **2048游戏代理**:
   - Domain: game.huaqloud.local
   - Forward to: 172.17.0.3:80

## 🎮 演示应用 - 2048游戏

### 部署配置
```bash
# 简单的演示容器
docker run -d --name game-2048 \
  -p 2048:80 \
  chengzh/docker-2048
```

### 服务状态
- **容器名称**: game-2048
- **内网IP**: 172.17.0.3
- **端口映射**: 2048:80
- **访问**: http://192.168.14.201:2048 或 http://game.huaqloud.local

## 📈 TradingAgents-CN智能交易平台

### 项目概况
- **项目名称**: TradingAgents 中文增强版
- **版本**: cn-0.1.15
- **类型**: 多智能体大语言模型金融交易决策框架
- **特色**: 专为中文用户优化，支持A股/港股/美股分析

### 部署配置
```bash
# 项目克隆
git clone https://github.com/hsliuping/TradingAgents-CN /root/TradingAgents-CN

# 环境配置
cp .env.example .env

# Docker编排部署
docker-compose build
docker-compose up -d
```

### 服务架构
1. **Web应用** (tradingagents-web)
   - 端口: 8501
   - 技术: Streamlit框架
   - 功能: AI驱动的股票分析界面

2. **数据库服务**
   - **MongoDB**: 端口27018 (数据存储)
   - **Redis**: 端口6380 (缓存服务)

3. **管理界面**
   - **Redis Commander**: 端口8083 (Redis管理)
   - **Mongo Express**: 端口8084 (MongoDB管理)

### 访问方式
- **主应用**: http://192.168.14.201:8501 或 http://trading.huaqloud.local
- **Redis管理**: http://192.168.14.201:8083 或 http://redis.huaqloud.local
- **MongoDB管理**: http://192.168.14.201:8084 或 http://mongo.huaqloud.local

### 核心功能
- 🤖 **多智能体分析**: 基于大语言模型的投资决策
- 📊 **全市场支持**: A股/港股/美股数据分析
- 🇨🇳 **中文优化**: 专为中文用户设计的交互界面
- 📈 **实时数据**: 集成多个金融数据源
- 🔍 **智能研报**: AI生成的专业投资分析报告

## 🔧 架构优化历程

### 网络架构演进
1. **初始阶段**: 使用自定义lab-network网络
2. **问题发现**: NPM无法访问其他网络中的容器
3. **MVP重构**: 全部迁移到默认bridge网络
4. **优化结果**: 简化配置，提高可靠性

### 关键经验教训
1. **MVP原则**: 简单可工作优于复杂的"完美"方案
2. **网络隔离**: Docker自定义网络会带来额外复杂性
3. **容器通信**: 默认bridge网络对实验环境完全够用
4. **配置维护**: 越简单的配置越容易维护和排错

## 📊 当前运行状态

### 容器清单
```bash
NAMES                         IMAGE                             PORTS                           NETWORKS
tradingagents-web             tradingagents-cn:latest           8501:8501                      bridge
tradingagents-mongo-express   mongo-express:latest              8084:8081                      bridge
tradingagents-redis-commander ghcr.io/joeferner/redis-commander 8083:8081                      bridge
tradingagents-redis           redis:latest                      6380:6379                      bridge
tradingagents-mongodb         mongo:4.4                         27018:27017                    bridge
nginx-proxy-manager           jc21/nginx-proxy-manager:latest   80:80,81:81,443:443            bridge
beszel-agent                  henrygd/beszel-agent              (内部通信)                      bridge
beszel                        henrygd/beszel                    8090:8090                      bridge
game-2048                     chengzh/docker-2048               2048:80                        bridge
portainer                     portainer/portainer-ce:latest     9000:9000                      bridge
```

### 网络连通性验证
- ✅ NPM → Portainer (172.17.0.2:9000) HTTP 200
- ✅ NPM → Beszel (172.17.0.4:8090) HTTP 200
- ✅ NPM → 2048游戏 (172.17.0.3:80) HTTP 200
- ✅ TradingAgents Web应用 (192.168.14.201:8501) HTTP 200
- ✅ TradingAgents数据库服务正常启动
- ✅ Beszel Agent → Hub WebSocket连接正常

### 服务健康状态
- 🟢 **Portainer**: 正常运行，Web界面可访问
- 🟢 **Beszel Hub**: 正常运行，监控数据收集正常
- 🟢 **Beszel Agent**: WebSocket连接成功，系统监控正常
- 🟢 **NPM**: 正常运行，准备配置反向代理
- 🟢 **2048游戏**: 正常运行，演示应用可访问
- 🟢 **TradingAgents**: 正常运行，AI交易分析平台可访问
- 🟢 **MongoDB**: 正常运行，数据库服务健康
- 🟢 **Redis**: 正常运行，缓存服务健康
- 🟢 **管理界面**: Redis Commander和Mongo Express可访问

## 🎯 下一步计划

### 短期目标
- [ ] 配置NPM反向代理规则实现域名访问
- [ ] 测试SSL证书自动申请功能
- [ ] 配置Beszel监控告警阈值
- [ ] 部署更多示例应用测试环境

### 长期目标
- [ ] 容器编排实验 (Docker Compose)
- [ ] 微服务架构演示
- [ ] CI/CD流水线集成
- [ ] 容器安全扫描和监控

## 📝 技术文档

### 关键配置文件
- **NPM数据目录**: `/root/nginx-proxy-manager/`
- **Beszel数据目录**: `/root/beszel_data/`
- **Beszel Agent数据**: `/root/beszel_agent_data/`
- **Portainer数据卷**: `portainer_data`

### 故障排除指南
1. **容器无法启动**: 检查端口占用和权限
2. **网络连接问题**: 验证bridge网络IP分配
3. **数据持久化问题**: 检查卷挂载路径权限
4. **性能监控异常**: 重启Beszel Agent和Hub

### 备份策略
- **Portainer**: 备份portainer_data卷
- **Beszel**: 备份/root/beszel_data和beszel_agent_data目录
- **NPM**: 备份/root/nginx-proxy-manager整个目录

---
*实验环境部署完成时间: 2025-10-14 下午*
*文档最后更新: 2025-10-14*
*架构原则: MVP - 简单、可用、可维护*