# 00-系统健康检查与Docker环境配置

**实验日期**: 2025年10月14日  
**AI助手**: GitHub Copilot  
**实验环境**: Ubuntu 20.04.6 LTS  

---

## 📋 实验概述

本次实验包含两个主要部分：
1. **系统健康性检查** - 全面评估虚拟机系统状态
2. **Docker安装配置** - 完整的Docker环境搭建与优化

## 🔍 第一部分：系统健康性检查

### 1.1 系统基本信息检查

```bash
# 系统版本和内核信息
uname -a
cat /etc/os-release
cat /proc/version
lscpu
```

**检查结果**：
- 操作系统：Ubuntu 20.04.6 LTS (Focal Fossa)
- 内核版本：5.4.0-216-generic
- 架构：x86_64
- CPU：Intel Core Ultra 7 255H (4核)
- 虚拟化：Microsoft Hyper-V

### 1.2 资源使用状况

```bash
# 内存和磁盘检查
free -h
df -h
uptime
```

**资源状态**：
- **内存**：总量7.8GB，使用1.7GB，可用5.8GB ✅
- **磁盘**：根分区40GB，使用6.1GB (17%)，剩余31GB ✅
- **负载**：1/5/15分钟负载均为0.02-0.07，系统空闲 ✅

### 1.3 进程和服务状态

```bash
# 高CPU进程和系统服务
ps aux --sort=-%cpu | head -10
systemctl --failed
systemctl list-units --type=service --state=active
```

**发现要点**：
- VS Code Server进程占用较高资源（正常）
- 无失败的系统服务
- 关键服务运行正常：SSH、cron、网络等

### 1.4 系统日志分析

```bash
# 错误日志检查
journalctl -p err -n 20 --no-pager
```

**日志分析**：
- 发现少量硬件相关警告（虚拟化环境常见）
- SMBus和软盘设备错误可忽略
- 检测到Spectre v2和RETBleed安全漏洞警告

### 1.5 网络和安全状态

```bash
# 网络端口和连接
netstat -tuln
ss -tuln
last -10
```

**网络状态**：
- SSH服务正常运行（端口22）
- 本地DNS服务正常
- VS Code远程连接正常
- 近期登录记录正常

### 1.6 健康检查总结

| 检查项目 | 状态 | 评价 |
|---------|------|------|
| 系统资源 | 🟢 | 优秀 - 资源充足 |
| 系统负载 | 🟢 | 优秀 - 负载极低 |
| 服务状态 | 🟢 | 正常 - 无失败服务 |
| 网络配置 | 🟢 | 正常 - 连接稳定 |
| 安全漏洞 | 🟡 | 注意 - 存在已知漏洞 |
| 整体评价 | 🟢 | **系统健康状况良好** |

---

## 🐳 第二部分：Docker安装与配置优化

### 2.1 Docker安装过程

#### 2.1.1 安装方式选择
由于网络连接问题，最终选择Ubuntu官方仓库安装：

```bash
# 更新软件包列表
apt update

# 安装Docker和Docker Compose
apt install -y docker.io docker-compose
```

#### 2.1.2 服务配置
```bash
# 启动Docker服务并设置开机自启
systemctl start docker
systemctl enable docker
```

#### 2.1.3 安装验证
```bash
# 版本检查
docker --version  # Docker version 26.1.3
docker-compose --version  # docker-compose version 1.25.0

# 功能测试
docker run --rm hello-world  # ✅ 测试成功
```

### 2.2 Docker配置优化

#### 2.2.1 守护进程配置
创建 `/etc/docker/daemon.json`：

```json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "data-root": "/var/lib/docker",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false,
  "debug": false
}
```

**配置说明**：
- 镜像加速器：配置国内镜像源提升拉取速度
- 日志轮转：限制日志文件大小，防止磁盘占用过多
- 存储驱动：使用overlay2提升性能
- 其他优化：系统集成和性能调优

### 2.3 系统优化配置

#### 2.3.1 交换分区配置
```bash
# 创建2GB交换文件
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# 永久挂载
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

#### 2.3.2 内核参数优化
添加到 `/etc/sysctl.conf`：

```bash
# 内存管理
vm.swappiness=10

# 网络优化
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Docker容器优化
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1

# 文件句柄优化
fs.file-max = 65536
```

#### 2.3.3 文件句柄限制
添加到 `/etc/security/limits.conf`：

```bash
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
```

### 2.4 防火墙配置策略

#### 2.4.1 初始安全配置
```bash
# 启用防火墙
ufw enable

# 开放必要端口
ufw allow ssh
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8080/tcp  # 备用HTTP
ufw allow 3000/tcp  # 开发环境
ufw allow 5000/tcp  # 开发环境
```

#### 2.4.2 实验环境调整
考虑到实验便利性，最终关闭防火墙：

```bash
# 关闭防火墙（实验环境）
ufw disable
```

**决策说明**：
- 生产环境：建议启用防火墙，只开放必要端口
- 实验环境：为方便测试各种端口服务，暂时关闭
- 创建防火墙管理脚本，便于快速切换模式

### 2.5 自动化脚本工具

#### 2.5.1 系统优化脚本
创建 `system_optimization.sh`，包含：
- 内核参数配置
- 文件句柄限制设置
- Docker用户组配置
- 日志轮转配置
- SSH安全优化
- 防火墙规则配置
- 系统清理和验证

#### 2.5.2 防火墙管理脚本
创建 `firewall_toggle.sh`，提供：
- 启用防火墙（生产模式）
- 关闭防火墙（实验模式）
- 状态查看功能

### 2.6 配置验证结果

#### 2.6.1 Docker状态检查
```bash
systemctl status docker  # ✅ 活跃运行
docker info              # ✅ 配置正确应用
```

#### 2.6.2 系统资源状态
```bash
free -h    # 内存：7.8GB可用，交换：2GB已配置
df -h      # 磁盘：使用6.3GB/40GB
swapon     # 交换分区正常工作
```

#### 2.6.3 网络配置验证
```bash
ufw status                    # 防火墙：已关闭（实验模式）
sysctl net.ipv4.ip_forward   # IP转发：已启用
```

---

## 📊 实验总结

### ✅ 完成的主要任务

1. **系统健康检查**
   - 全面评估系统状态
   - 识别潜在问题和优化点
   - 确认系统适合容器化应用

2. **Docker环境搭建**
   - 成功安装Docker 26.1.3和Docker Compose 1.25.0
   - 配置镜像加速和日志管理
   - 验证基本功能正常

3. **系统性能优化**
   - 创建交换分区提升内存管理
   - 优化内核参数提升网络性能
   - 配置文件句柄限制支持高并发

4. **安全和管理工具**
   - 创建防火墙管理方案
   - 编写自动化配置脚本
   - 建立实验环境管理机制

### 📈 优化效果

- **内存利用率**：优化交换策略，提升内存使用效率
- **网络性能**：启用BBR算法，提升网络传输性能
- **容器性能**：配置存储驱动和日志管理，提升Docker性能
- **操作便利性**：创建脚本工具，简化日常管理操作

### 🎯 后续实验准备

系统现已完全准备就绪，可以进行：
- Docker基础操作实验
- 容器镜像构建实践
- 多服务应用部署
- 微服务架构实验

### 🔧 实用脚本位置

- `scripts/system_optimization.sh` - 系统优化脚本
- `scripts/firewall_toggle.sh` - 防火墙管理脚本
- `configs/daemon.json` - Docker配置文件备份

---

**实验状态**: ✅ 完成  
**系统状态**: 🟢 健康且已优化  
**Docker状态**: 🟢 安装完成且配置优化  
**准备程度**: 🚀 已准备好进行容器化实验