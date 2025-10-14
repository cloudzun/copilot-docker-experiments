# Docker环境安装配置记录

## 系统信息
- **操作系统**: Ubuntu 20.04.6 LTS (Focal Fossa)
- **内核版本**: 5.4.0-216-generic
- **架构**: x86_64
- **CPU**: Intel Core Ultra 7 255H (4核)
- **内存**: 7.8GB
- **磁盘**: 40GB

## 安装过程

### 1. 系统健康检查
```bash
# 系统基本信息检查
uname -a
cat /etc/os-release
df -h
free -h
uptime
```

### 2. Docker安装
```bash
# 使用Ubuntu官方源安装Docker
apt update
apt install -y docker.io docker-compose

# 启动Docker服务
systemctl start docker
systemctl enable docker
```

### 3. 系统优化配置
- 创建2GB交换分区
- 配置内核参数优化
- 设置文件句柄限制
- 配置Docker镜像加速
- 网络性能优化（BBR算法）

### 4. 防火墙配置
- 初始配置：保守安全策略
- 实验环境调整：关闭防火墙便于测试

## 安装验证

### Docker版本
```bash
$ docker --version
Docker version 26.1.3, build 26.1.3-0ubuntu1~20.04.1

$ docker-compose --version
docker-compose version 1.25.0, build unknown
```

### 功能测试
```bash
# 运行hello-world容器验证安装
docker run --rm hello-world
```

## 配置文件

### Docker守护进程配置 (`/etc/docker/daemon.json`)
- 配置镜像加速器
- 日志轮转设置
- 存储驱动优化

### 系统内核参数优化 (`/etc/sysctl.conf`)
- 网络性能优化
- 容器相关参数调整
- 内存管理优化

## 常用脚本

### 系统优化脚本
- `system_optimization.sh`: 一键系统优化配置
- `firewall_toggle.sh`: 防火墙状态管理

## 注意事项

1. **安全提醒**: 实验环境关闭了防火墙，生产环境需要重新配置
2. **网络问题**: 如遇Docker Hub连接问题，已配置国内镜像加速器
3. **资源监控**: 建议定期检查磁盘和内存使用情况

## 下一步计划

- [ ] Docker基础命令实验
- [ ] 容器镜像构建实践
- [ ] Docker Compose多服务部署
- [ ] 微服务架构实验