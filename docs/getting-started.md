# GitHub Copilot 辅助Docker实验 - 快速指南

## 🎯 实验目标
通过GitHub Copilot AI助手学习和掌握Docker容器化技术

## 📋 实验环境状态
✅ Ubuntu 20.04 LTS  
✅ Docker 26.1.3 已安装  
✅ Docker Compose 1.25.0 已安装  
✅ 系统优化完成  
✅ 实验环境准备就绪  

## 🚀 快速开始

### 验证Docker安装
```bash
# 检查Docker版本
docker --version
docker-compose --version

# 运行测试容器
docker run --rm hello-world
```

### 基础Docker命令
```bash
# 查看Docker信息
docker info

# 列出镜像
docker images

# 列出容器
docker ps -a

# 拉取镜像
docker pull nginx

# 运行容器
docker run -d -p 80:80 nginx
```

## 📁 目录结构说明

```
copilot-docker-experiments/
├── setup/              # 环境配置记录
│   └── installation-log.md
├── experiments/        # 实验项目目录
├── configs/           # 配置文件备份
│   └── daemon.json
├── docs/              # 文档和笔记
├── scripts/           # 实用脚本
│   ├── system_optimization.sh
│   └── firewall_toggle.sh
└── examples/          # 代码示例
```

## 🛠️ 实用脚本

```bash
# 系统优化（已执行）
./scripts/system_optimization.sh

# 防火墙管理
./scripts/firewall_toggle.sh status    # 查看状态
./scripts/firewall_toggle.sh disable   # 关闭防火墙
./scripts/firewall_toggle.sh enable    # 启用防火墙
```

## 📚 实验计划

### Phase 1: Docker基础
- [ ] 容器生命周期管理
- [ ] 镜像操作与管理
- [ ] 网络配置基础
- [ ] 数据卷使用

### Phase 2: 镜像构建
- [ ] Dockerfile编写
- [ ] 多阶段构建
- [ ] 镜像优化技巧
- [ ] 私有仓库使用

### Phase 3: 容器编排
- [ ] Docker Compose基础
- [ ] 多服务应用部署
- [ ] 服务依赖管理
- [ ] 扩缩容实践

### Phase 4: 高级应用
- [ ] 微服务架构实验
- [ ] 负载均衡配置
- [ ] 监控和日志
- [ ] 安全最佳实践

## 🔧 系统配置摘要

- **交换分区**: 2GB已配置
- **防火墙**: 已关闭（实验环境）
- **Docker加速**: 国内镜像源已配置
- **日志轮转**: 自动清理大日志文件
- **内核优化**: BBR算法，网络性能提升

## 📝 实验记录

每个实验请在 `experiments/` 目录下创建子目录，包含：
- README.md（实验说明）
- docker-compose.yml（如适用）
- Dockerfile（如适用）
- 相关配置文件
- 实验结果和总结

---

**开始您的Docker实验之旅吧！** 🐳