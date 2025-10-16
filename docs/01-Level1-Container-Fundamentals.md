# 01-Level1-Container-Fundamentals.md

<meta charset="UTF-8">

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

**步骤1: 验证Docker安装**
```bash
# 查看Docker版本
docker --version
```
*预期输出*: `Docker version 26.1.3, build ...`

```bash
# 查看Docker系统信息
docker info
```
*预期输出*: 显示Docker守护进程状态、存储驱动等详细信息

**步骤2: 镜像操作练习**
```bash
# 拉取nginx镜像
docker pull nginx:latest
```
*说明*: 从Docker Hub下载最新版本的nginx镜像

```bash
# 查看本地镜像列表
docker images
```
*预期输出*: 显示本地所有镜像，包括刚下载的nginx

```bash
# 查看镜像详细信息
docker inspect nginx:latest
```
*说明*: 显示镜像的详细配置信息，包括层信息、环境变量等

**步骤3: 运行第一个容器**
```bash
# 运行nginx容器（后台模式）
docker run -d -p 8080:80 nginx
```
*说明*: `-d` 后台运行，`-p 8080:80` 端口映射（宿主机8080映射到容器80）

```bash
# 查看运行中的容器
docker ps
```
*预期输出*: 显示正在运行的容器列表，包括容器ID、镜像、端口等信息

```bash
# 测试访问
curl http://localhost:8080
```
*预期输出*: 显示nginx默认欢迎页面的HTML内容

**步骤4: 容器日志和交互操作**
```bash
# 查看容器日志
docker logs <container_id>
```
*说明*: 将`<container_id>`替换为实际的容器ID（从docker ps获得）

```bash
# 进入容器内部
docker exec -it <container_id> /bin/bash
```
*说明*: `-it` 交互模式，进入容器后可以执行bash命令

```bash
# 在容器内部查看nginx进程（容器内执行）
ps aux | grep nginx
```

```bash
# 退出容器（容器内执行）
exit
```

**步骤5: 容器停止和清理**
```bash
# 停止容器
docker stop <container_id>
```

```bash
# 查看所有容器（包括已停止的）
docker ps -a
```

```bash
# 删除容器
docker rm <container_id>
```

```bash
# 删除镜像
docker rmi nginx:latest
```

#### 1.5 容器生命周期管理

**步骤1: 容器状态转换演示**
```bash
# 重新拉取nginx镜像
docker pull nginx:latest
```

```bash
# 创建容器但不启动
docker create --name my-nginx -p 8081:80 nginx:latest
```
*说明*: `--name` 给容器指定名称，便于管理

```bash
# 查看容器状态（应该是Created）
docker ps -a
```

```bash
# 启动已创建的容器
docker start my-nginx
```

```bash
# 验证容器运行状态
docker ps
```

**步骤2: 容器暂停和恢复**
```bash
# 暂停容器
docker pause my-nginx
```

```bash
# 查看容器状态（应该显示Paused）
docker ps
```

```bash
# 尝试访问（应该无响应）
timeout 3 curl http://localhost:8081 || echo "Container is paused"
```

```bash
# 恢复容器
docker unpause my-nginx
```

```bash
# 验证恢复（应该正常响应）
curl http://localhost:8081
```

**步骤3: 容器重启和强制停止**
```bash
# 重启容器
docker restart my-nginx
```

```bash
# 查看重启后的运行时间
docker ps
```

```bash
# 强制停止容器
docker kill my-nginx
```

```bash
# 清理容器
docker rm my-nginx
```

### 🎪 动手项目: 运行第一个Web应用

**项目目标**: 部署一个自定义的静态网站

**步骤1: 创建项目目录**
```bash
# 创建工作目录
mkdir my-first-website
```

```bash
# 进入项目目录
cd my-first-website
```

**步骤2: 创建网站内容**
```bash
# 创建HTML页面
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>我的第一个Docker网站</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>欢迎来到Docker世界！</h1>
    <p>这是我用Docker部署的第一个网站。</p>
</body>
</html>
EOF
```
*说明*: 创建一个简单的HTML页面作为网站内容

**步骤3: 使用数据卷部署**
```bash
# 使用nginx镜像并挂载当前目录
docker run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html --name my-website nginx:latest
```
*说明*: `-v $(pwd):/usr/share/nginx/html` 将当前目录挂载到nginx的web根目录

**步骤4: 验证部署**
```bash
# 测试网站访问
curl http://localhost:8080
```
*预期输出*: 显示我们创建的HTML页面内容

```bash
# 查看容器状态
docker ps
```

**步骤5: 清理资源**
```bash
# 停止并删除容器
docker stop my-website
```

```bash
# 删除容器
docker rm my-website
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

**什么是多阶段构建？**

多阶段构建(Multi-stage builds)是Docker 17.05引入的功能，允许在一个Dockerfile中使用多个FROM指令，每个FROM指令开始一个新的构建阶段。这种技术主要用于：

- **减小镜像体积**: 最终镜像只包含运行时必需的文件
- **简化构建流程**: 在一个文件中完成构建和打包
- **提高安全性**: 构建工具和源代码不会出现在最终镜像中
- **优化构建缓存**: 不同阶段可以独立缓存

**构建阶段对比**:
```
┌─────────────────────────────────────────────────┐
│                传统单阶段构建                     │
├─────────────────────────────────────────────────┤
│ FROM node:16                                    │
│ • 包含完整Node.js环境 (~900MB)                   │
│ • 包含源代码和依赖                               │
│ • 包含构建工具 (npm, yarn等)                     │
│ • 最终镜像体积大，安全风险高                      │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│                多阶段构建优化                     │
├─────────────────────────────────────────────────┤
│ Stage 1: FROM node:16 AS builder                │
│ • 用于构建和编译                                 │
│ • 安装依赖，执行构建命令                         │
│ │                                               │
│ Stage 2: FROM nginx:alpine                      │
│ • 轻量级运行环境 (~15MB)                         │
│ • 只复制构建产物                                 │
│ • 最终镜像小且安全                               │
└─────────────────────────────────────────────────┘
```

**示例Dockerfile详解**:
```dockerfile
# 构建阶段 - 用于编译和构建应用
FROM node:16 AS builder
# ↑ 使用Node.js 16作为构建环境，命名为"builder"

WORKDIR /app
# 设置工作目录为/app

COPY package*.json ./
# 优先复制package.json文件，利用Docker缓存机制
# 如果package.json未变化，下面的npm install会使用缓存

RUN npm install
# 安装所有依赖（包括开发依赖）

COPY . .
# 复制所有源代码到容器中

RUN npm run build
# 执行构建命令，生成生产环境代码（通常在dist/目录）

# 运行阶段 - 轻量级生产环境
FROM nginx:alpine
# ↑ 使用轻量级的nginx:alpine作为运行环境（仅约15MB）

COPY --from=builder /app/dist /usr/share/nginx/html
# ↑ 关键指令：从builder阶段复制构建产物
# 只复制必需的静态文件，不包含源码和node_modules

EXPOSE 80
# 声明容器对外暴露80端口

CMD ["nginx", "-g", "daemon off;"]
# 启动nginx服务器，-g "daemon off;"确保nginx在前台运行
```

**构建过程解析**:
```bash
# 第一阶段执行的操作
1. 下载node:16镜像 (~900MB)
2. 安装npm依赖
3. 编译源代码
4. 生成dist/目录

# 第二阶段执行的操作  
1. 下载nginx:alpine镜像 (~15MB)
2. 从第一阶段复制dist/目录
3. 配置nginx服务
4. 生成最终镜像 (~20MB)
```

**优化效果对比**:
```
传统方式: node:16 + 源码 + node_modules ≈ 1.2GB
多阶段构建: nginx:alpine + 静态文件 ≈ 20MB
体积减少: 约98%！
```

**最佳实践提示**:
- 构建阶段使用功能完整的基础镜像
- 运行阶段使用最小化的基础镜像  
- 合理利用.dockerignore排除不必要文件
- 将经常变化的步骤放在Dockerfile后面

### 🛠️ 实践操作 (5小时)

#### 2.4 构建第一个自定义镜像

**步骤1: 准备构建环境**
```bash
# 创建构建目录
mkdir my-custom-nginx && cd my-custom-nginx
```

**步骤2: 创建Dockerfile**
```bash
# 创建Dockerfile
cat > Dockerfile << 'EOF'
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
EOF
```

**步骤3: 创建配置文件**
```bash
# 创建nginx配置
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF
```

**步骤4: 创建网站内容**
```bash
# 创建html目录
mkdir html
```

```bash
# 创建首页
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>自定义Nginx镜像</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>这是我的自定义Docker镜像！</h1>
    <p>构建时间: 2024年10月</p>
</body>
</html>
EOF
```

#### 2.5 镜像构建与管理

**步骤1: 构建镜像**
```bash
# 构建镜像并指定标签
docker build -t my-website:v1.0 .
```
*说明*: `.` 表示使用当前目录的Dockerfile进行构建

**步骤2: 查看构建结果**
```bash
# 查看镜像列表
docker images my-website
```

```bash
# 查看构建历史
docker history my-website:v1.0
```
*说明*: 显示镜像各层的构建历史和大小

**步骤3: 镜像标记管理**
```bash
# 添加latest标签
docker tag my-website:v1.0 my-website:latest
```

```bash
# 验证标签
docker images my-website
```
*预期输出*: 应该看到两个标签指向同一个镜像ID

**步骤4: 测试自定义镜像**
```bash
# 运行自定义镜像
docker run -d -p 8081:80 --name custom-nginx my-website:v1.0
```

```bash
# 测试访问
curl http://localhost:8081
```

```bash
# 查看健康检查状态
docker ps
```
*说明*: STATUS列会显示健康检查结果

**步骤5: 清理实验容器**
```bash
# 停止容器
docker stop custom-nginx
```

```bash
# 删除容器
docker rm custom-nginx
```

```bash
# 查看容器是否已清理
docker ps -a
```
*说明*: 应该看不到custom-nginx容器，养成及时清理的好习惯

### 🎪 动手项目: 构建个人静态博客

**项目目标**: 使用Hugo构建静态博客并容器化

**📊 预期成果**:
- ✅ 多阶段构建的Docker镜像（约53MB）
- ✅ 中文博客网站，包含文章列表和详细页面
- ✅ 响应式设计，支持移动端访问
- ✅ SEO友好的HTML结构和meta标签
- ✅ Nginx静态文件服务，支持gzip压缩

**🏗️ 技术架构**:
```
Hugo源码 → Docker构建阶段1(hugomods/hugo) → 静态文件生成
                                              ↓
最终镜像 ← Docker构建阶段2(nginx:alpine) ← 静态文件复制
```

**步骤1: 创建项目结构**
```bash
# 创建博客项目目录
mkdir hugo-blog && cd hugo-blog
```
*说明*: 建立独立的项目目录，便于版本控制和项目管理

**步骤2: 创建多阶段Dockerfile**
```bash
# 创建Dockerfile
cat > Dockerfile << 'EOF'
# 构建阶段
FROM hugomods/hugo:latest AS builder

WORKDIR /src
COPY . .

# 直接构建，不要重新初始化站点
RUN hugo --minify --gc

# 运行阶段
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
```
*关键说明*: 
- **多阶段构建优势**: 最终镜像大小只需约53MB，比单阶段构建减少95%体积
- **构建阶段修正**: 移除`hugo new site . --force`避免覆盖我们的配置文件
- **--minify参数**: 压缩生成的HTML、CSS、JS文件，提升加载性能
- **--gc参数**: 清理构建过程中的临时文件

**步骤3: 创建Hugo配置**
```bash
# 创建hugo配置文件
cat > config.yaml << 'EOF'
baseURL: 'http://localhost'
languageCode: 'zh-cn'
title: '我的Docker博客'
defaultContentLanguage: 'zh-cn'

params:
  description: '使用Hugo和Docker构建的个人博客'

# 确保正确解析中文内容
markup:
  goldmark:
    renderer:
      unsafe: true
EOF
```
*关键配置说明*: 
- **baseURL**: 设置博客的基础URL，生产环境需修改为实际域名
- **languageCode**: 指定网站语言为简体中文，影响HTML lang属性
- **defaultContentLanguage**: 确保Hugo正确处理中文内容和日期格式
- **markup.goldmark.renderer.unsafe**: 允许在Markdown中使用HTML标签，增强内容灵活性

**步骤4: 创建示例内容**
```bash
# 创建内容目录
mkdir -p content/posts
```

```bash
# 创建第一篇文章
cat > content/posts/first-post.md << 'EOF'
---
title: "我的第一篇Docker博客"
date: 2024-10-15T10:00:00+08:00
draft: false
---

# 欢迎来到我的博客

这是使用Hugo和Docker构建的第一篇博客文章。

## Docker的优势

- 环境一致性
- 快速部署
- 易于扩展
EOF
```

**步骤4.1: 创建布局模板（解决主题问题）**
```bash
# 创建布局目录
mkdir -p layouts/_default
```
*说明*: Hugo需要layouts目录来存放自定义模板，`_default`是默认模板目录

```bash
# 创建基础模板
cat > layouts/_default/baseof.html << 'EOF'
<!DOCTYPE html>
<html lang="{{ site.Language.Lang }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ .Title }} | {{ site.Title }}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { border-bottom: 1px solid #ccc; padding-bottom: 20px; margin-bottom: 20px; }
        .post { margin-bottom: 30px; }
        .post-title { color: #333; }
        .post-date { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <header class="header">
            <h1><a href="{{ "/" | relURL }}">{{ site.Title }}</a></h1>
        </header>
        <main>
            {{ block "main" . }}{{ end }}
        </main>
    </div>
</body>
</html>
EOF
```
*模板关键要素解析*:
- **{{ site.Language.Lang }}**: 动态输出语言代码，支持SEO和多语言
- **{{ .Title }} | {{ site.Title }}**: 页面标题格式，有利于搜索引擎优化
- **{{ "/" | relURL }}**: 生成相对URL，适应不同部署环境
- **{{ block "main" . }}**: 定义内容块，子模板可以替换此部分
- **响应式CSS**: 使用max-width确保在不同设备上正常显示

```bash
# 创建首页模板
cat > layouts/_default/list.html << 'EOF'
{{ define "main" }}
<h2>最新文章</h2>
{{ range .Pages }}
<article class="post">
    <h3 class="post-title"><a href="{{ .Permalink }}">{{ .Title }}</a></h3>
    <p class="post-date">{{ .Date.Format "2006-01-02" }}</p>
    <p>{{ .Summary }}</p>
</article>
{{ end }}
{{ end }}
EOF
```
*列表模板逻辑说明*:
- **{{ range .Pages }}**: 遍历当前section下的所有页面
- **{{ .Permalink }}**: 生成页面的永久链接
- **{{ .Date.Format "2006-01-02" }}**: Go时间格式化，显示为YYYY-MM-DD格式
- **{{ .Summary }}**: 自动生成页面摘要，通常是前70个字符

```bash
# 创建单页模板
cat > layouts/_default/single.html << 'EOF'
{{ define "main" }}
<article class="post">
    <h1 class="post-title">{{ .Title }}</h1>
    <p class="post-date">{{ .Date.Format "2006-01-02" }}</p>
    <div class="content">
        {{ .Content }}
    </div>
</article>
<p><a href="{{ "/" | relURL }}">← 返回首页</a></p>
{{ end }}
EOF
```
*单页模板特点*:
- **{{ .Content }}**: 渲染Markdown内容为HTML
- **导航链接**: 提供返回首页的用户友好导航

```bash
# 创建优化的首页模板（直接显示文章列表）
cat > layouts/index.html << 'EOF'
{{ define "main" }}
<h2>欢迎来到我的博客</h2>
<p>{{ site.Params.description }}</p>

<h2>最新文章</h2>
{{ range (where site.RegularPages "Section" "posts") }}
<article class="post">
    <h3 class="post-title"><a href="{{ .Permalink }}">{{ .Title }}</a></h3>
    <p class="post-date">{{ .Date.Format "2006-01-02" }}</p>
    <p>{{ .Summary }}</p>
    <p><a href="{{ .Permalink }}">阅读全文 →</a></p>
</article>
{{ end }}
{{ end }}
EOF
```
*首页模板高级功能*:
- **where过滤器**: `where site.RegularPages "Section" "posts"`仅显示posts目录下的文章
- **site.RegularPages**: 获取所有常规页面，排除index页面
- **动态描述**: 从配置文件读取博客描述，便于统一管理

```bash
# 创建nginx配置文件
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF
```
*Nginx配置详细解析*:
- **worker_connections 1024**: 设置每个worker进程的最大连接数，影响并发性能
- **include mime.types**: 加载MIME类型映射，确保正确的Content-Type响应头
- **gzip压缩**: 启用文本文件压缩，减少传输带宽，提升加载速度
- **try_files指令**: 实现SPA路由支持，$uri找不到时回退到index.html
- **静态文件优化**: 适合Hugo生成的静态网站的访问模式

**步骤6: 构建和运行**
```bash
# 构建博客镜像
docker build -t hugo-blog:latest .
```
*构建过程监控要点*:
- 观察两个构建阶段的执行时间和输出
- 第一阶段下载hugo镜像约467MB，第二阶段nginx:alpine仅15MB
- Hugo生成页面数量应显示为10+页面（包括分类、标签等）

```bash
# 如果构建成功，运行博客容器
docker run -d -p 8082:80 --name my-blog hugo-blog:latest
```
*容器运行参数说明*:
- **-d**: 后台运行模式，容器在后台持续提供服务
- **-p 8082:80**: 端口映射，宿主机8082端口映射到容器80端口
- **--name**: 指定容器名称，便于后续管理和调试

```bash
# 访问博客进行验证
curl http://localhost:8082
```
*验证检查点*:
- 响应包含正确的HTML5文档结构
- 网站标题显示为"我的Docker博客"
- 页面语言属性为zh-cn
- 包含文章列表和"阅读全文"链接

**步骤7: 构建问题排除与优化验证**

如果遇到构建错误，可以尝试以下解决方案：

```bash
# 方案1: 分阶段调试构建过程
docker build --no-cache -t hugo-blog:debug . 2>&1 | tee build.log
```
*调试技巧*:
- **--no-cache**: 禁用缓存，确保每步都重新执行
- **2>&1**: 重定向错误输出到标准输出
- **tee**: 同时输出到终端和文件，便于后续分析

```bash
# 方案2: 进入Hugo构建环境手动调试
docker run -it --rm -v $(pwd):/src hugomods/hugo:latest sh
# 在容器内执行以下命令
# cd /src && ls -la
# hugo --minify --gc --verbose
```
*手动调试价值*:
- 验证文件结构是否正确
- 检查Hugo配置文件语法
- 观察详细的构建输出信息

```bash
# 方案3: 验证构建产物
docker run --rm -v $(pwd):/src hugomods/hugo:latest hugo --minify --gc
ls -la public/
```
*构建产物检查*:
- public/index.html应该存在且包含正确内容
- posts/目录应该包含文章页面
- CSS和HTML应该被正确压缩

**步骤8: 验证和清理**
```bash
# 查看最终镜像大小
docker images hugo-blog
```
*镜像大小分析*:
- 优化后的镜像大小应该在50-60MB左右
- 相比传统方式减少约95%的体积
- 主要组成：nginx:alpine基础镜像 + Hugo生成的静态文件

```bash
# 性能和功能验证
curl -s http://localhost:8082 | grep -E "(title|博客|文章)"
curl -s http://localhost:8082/posts/first-post/ | grep -E "(Docker|环境一致性)"
```
*功能验证要点*:
- 首页应该显示博客标题和文章列表
- 文章页面应该包含完整的Markdown渲染内容
- 中文内容显示正常，无乱码问题

### 🎯 项目成功验收标准

完成Hugo博客项目后，您应该能够：

1. **技术掌握验证** ✅
   ```bash
   # 验证镜像构建成功
   docker images hugo-blog
   # 预期输出：镜像大小约50-60MB，标签为latest
   
   # 验证容器运行正常
   docker run -d -p 8082:80 --name test-blog hugo-blog:latest
   curl -s http://localhost:8082 | grep "我的Docker博客"
   # 预期输出：包含博客标题的HTML内容
   ```

2. **功能完整性检查** ✅
   - 首页显示博客标题和文章列表
   - 点击文章链接可以访问详细页面
   - 中文内容显示正常，无编码问题
   - 页面响应式设计，移动端友好

3. **性能指标达标** ✅
   - 镜像大小控制在60MB以内
   - 页面加载时间小于100ms（本地测试）
   - Gzip压缩正常工作
   - HTTP响应状态码200

4. **代码质量要求** ✅
   - Dockerfile采用多阶段构建最佳实践
   - HTML模板结构清晰，SEO友好
   - Nginx配置优化，支持静态文件服务
   - 代码注释完整，便于维护

**验收完成后清理**
```bash
# 清理测试容器
docker stop my-blog && docker rm my-blog
```

```bash
# 检查容器是否成功清理
docker ps -a | grep my-blog || echo "✅ 容器已成功清理"
```

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

#### 3.2 自定义网络管理

**网络类型对比**:
- `bridge`: 默认模式，容器间可通过内网通信
- `host`: 直接使用宿主机网络  
- `none`: 无网络连接
- `container`: 共享其他容器的网络

**自定义网络命令**:
```bash
# 创建自定义桥接网络
docker network create --driver bridge my-network
```

```bash
# 查看网络详情
docker network inspect my-network
```

```bash
# 容器连接到指定网络
docker run -d --name app1 --network my-network nginx
```

#### 3.3 数据持久化方案

**存储类型对比**:
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

**步骤1: 创建应用网络**
```bash
# 创建专用网络
docker network create blog-network
```
*说明*: 为博客应用创建独立的网络环境，容器间可通过服务名通信

```bash
# 查看网络配置
docker network ls
```
*预期输出*: 显示所有网络，包括新建的blog-network

```bash
# 查看网络详细信息
docker network inspect blog-network
```
*说明*: 显示网络的子网、网关、IPAM配置等详细信息

**步骤2: 部署数据库容器**
```bash
# 运行MySQL数据库
docker run -d \
  --name blog-db \
  --network blog-network \
  -e MYSQL_ROOT_PASSWORD=secret123 \
  -e MYSQL_DATABASE=blog \
  mysql:8.0
```
*关键参数说明*:
- `--network blog-network`: 将容器连接到自定义网络
- `-e MYSQL_ROOT_PASSWORD`: 设置MySQL root用户密码
- `-e MYSQL_DATABASE`: 创建初始数据库

```bash
# 查看数据库启动状态
docker logs blog-db
```
*说明*: 等待看到"ready for connections"表示MySQL启动完成

**步骤3: 测试网络连通性**
```bash
# 创建测试容器连接到同一网络
docker run -it --network blog-network --rm alpine sh
```
*说明*: `--rm` 参数确保测试容器退出后自动删除

*在容器内执行*:
```bash
# 测试数据库连接（容器内执行）
ping blog-db
```
*预期结果*: 能够ping通blog-db容器，说明网络连通正常

```bash
# 安装网络工具并测试端口（容器内执行）
apk add --no-cache curl
curl -v telnet://blog-db:3306
```
*说明*: 测试MySQL端口3306是否可访问

```bash
# 退出测试容器（容器内执行）
exit
```

**步骤4: 部署应用容器**
```bash
# 运行应用容器（示例）
docker run -d \
  --name blog-app \
  --network blog-network \
  -p 3000:3000 \
  -e DB_HOST=blog-db \
  -e DB_USER=root \
  -e DB_PASSWORD=secret123 \
  nginx:alpine
```
*关键配置说明*:
- `DB_HOST=blog-db`: 使用容器名作为主机名，Docker会自动解析为容器IP
- 环境变量传递数据库连接信息，应用程序可以直接使用
- `-p 3000:3000`: 暴露应用端口到宿主机

**步骤5: 验证容器间通信**
```bash
# 查看网络中的所有容器
docker network inspect blog-network | grep -A 5 "Containers"
```
*说明*: 显示网络中连接的容器及其IP地址

```bash
# 测试应用容器到数据库的连接
docker exec blog-app ping blog-db
```
*预期结果*: 应用容器能够ping通数据库容器

```bash
# 查看所有容器状态
docker ps
```
*验证*: blog-db和blog-app容器都应该处于运行状态

**步骤6: 清理实验环境**
```bash
# 一键清理所有实验资源
docker stop blog-app blog-db && docker rm blog-app blog-db && docker network rm blog-network
```

```bash
# 验证清理结果
docker ps -a | grep blog || echo "✅ 容器已清理完成"
docker network ls | grep blog || echo "✅ 网络已清理完成"
```
*说明*: 良好的实验习惯是及时清理资源，避免积累过多测试容器

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

#### 4.3 构建完整的多容器博客系统

**项目目标**: 创建一个真实可用的博客系统，让你亲身体验多容器应用的协作

**📋 系统架构预览**:
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   前端服务      │    │   后端API服务    │    │   数据库服务    │
│   (Nginx)       │◄──►│   (Node.js)     │◄──►│   (MySQL)       │
│   端口: 8080    │    │   内部端口: 3000  │    │   端口: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                    ┌─────────────────┐    ┌─────────────────┐
                    │   缓存服务      │    │   管理工具      │
                    │   (Redis)       │    │   (Adminer)     │
                    │   端口: 6379    │    │   端口: 8081    │
                    └─────────────────┘    └─────────────────┘
```

**步骤1: 创建项目目录结构**
```bash
# 创建项目根目录
mkdir blog-compose-demo && cd blog-compose-demo
```

**步骤2: 创建Docker Compose配置文件**
```bash
# 创建主配置文件
cat > docker-compose.yml << 'EOF'
version: '3.3'

services:
  # 前端服务 - Nginx静态文件服务
  frontend:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./frontend:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - blog-network

  # 后端API服务 - Node.js简单API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - DB_HOST=database
      - DB_NAME=blog
      - DB_USER=bloguser
      - DB_PASSWORD=secret123
      - REDIS_HOST=cache
      - NODE_ENV=production
    depends_on:
      - database
      - cache
    restart: unless-stopped
    networks:
      - blog-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 数据库服务
  database:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=blog
      - MYSQL_USER=bloguser
      - MYSQL_PASSWORD=secret123
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
    restart: unless-stopped
    networks:
      - blog-network
    ports:
      - "3306:3306"  # 暴露端口方便调试

  # 缓存服务
  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - blog-network
    ports:
      - "6379:6379"  # 暴露端口方便调试

  # 数据库管理工具 - 可选
  adminer:
    image: adminer:latest
    ports:
      - "8081:8080"
    depends_on:
      - database
    restart: unless-stopped
    networks:
      - blog-network

volumes:
  mysql_data:
  redis_data:

networks:
  blog-network:
    driver: bridge
EOF
```

**步骤3: 创建后端服务代码**
```bash
# 创建后端目录
mkdir backend

# 创建Node.js应用
cat > backend/package.json << 'EOF'
{
  "name": "blog-backend",
  "version": "1.0.0",
  "description": "Blog system backend API",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "redis": "^4.6.7",
    "cors": "^2.8.5"
  }
}
EOF

# 创建后端API代码
cat > backend/app.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');
const cors = require('cors');

const app = express();
const port = 3000;

// 中间件
app.use(cors());
app.use(express.json());

// Redis客户端
let redisClient;
(async () => {
  try {
    redisClient = redis.createClient({
      socket: {
        host: process.env.REDIS_HOST || 'localhost',
        port: 6379
      }
    });
    
    redisClient.on('error', (err) => console.log('Redis Client Error', err));
    await redisClient.connect();
    console.log('✅ Redis connected successfully');
  } catch (error) {
    console.log('❌ Redis connection failed:', error.message);
  }
})();

// MySQL连接池
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'bloguser',
  password: process.env.DB_PASSWORD || 'secret123',
  database: process.env.DB_NAME || 'blog',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ Database connected successfully');
    connection.release();
  } catch (error) {
    console.log('❌ Database connection failed:', error.message);
  }
})();

// 健康检查端点
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    services: {
      database: pool ? 'connected' : 'disconnected',
      redis: redisClient?.isOpen ? 'connected' : 'disconnected'
    }
  });
});

// 获取所有文章
app.get('/api/posts', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, title, content, author, created_at FROM posts ORDER BY created_at DESC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
});

// 创建新文章
app.post('/api/posts', async (req, res) => {
  try {
    const { title, content, author } = req.body;
    
    if (!title || !content || !author) {
      return res.status(400).json({ error: 'Title, content, and author are required' });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO posts (title, content, author, created_at) VALUES (?, ?, ?, NOW())',
      [title, content, author]
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Post created successfully' 
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
});

// 获取系统统计信息
app.get('/api/stats', async (req, res) => {
  try {
    const [postCount] = await pool.execute('SELECT COUNT(*) as count FROM posts');
    
    res.json({
      totalPosts: postCount[0].count,
      cacheStatus: redisClient?.isOpen ? 'connected' : 'disconnected',
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Blog API server running on port ${port}`);
});
EOF

# 创建Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 复制package文件并安装依赖
COPY package*.json ./
RUN npm install --production

# 安装curl用于健康检查
RUN apk add --no-cache curl

# 复制应用代码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 更改文件权限
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

CMD ["npm", "start"]
EOF
```

**步骤4: 创建前端界面**
```bash
# 创建前端目录
mkdir frontend

# 创建响应式博客界面（这里只显示关键部分，完整代码较长）
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人博客系统 - Docker Compose演示</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f4f4f4; }
        .container { max-width: 1200px; margin: 0 auto; }
        header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                 color: white; text-align: center; padding: 2rem; margin-bottom: 2rem; 
                 border-radius: 10px; }
        .status-panel { background: white; padding: 1.5rem; border-radius: 8px; 
                        margin-bottom: 2rem; }
        .posts-section { background: white; padding: 1.5rem; border-radius: 8px; }
        .post { border: 1px solid #eee; padding: 1.5rem; margin-bottom: 1rem; 
                border-radius: 8px; background: white; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🚀 个人博客系统</h1>
            <p>Docker Compose 多容器应用演示</p>
        </header>

        <div class="status-panel">
            <h2>📊 系统状态</h2>
            <div id="backend-status">检查中...</div>
            <div id="database-status">检查中...</div>
            <div id="cache-status">检查中...</div>
            <div id="post-count">统计中...</div>
        </div>

        <div class="posts-section">
            <h2>📝 发布新文章</h2>
            <form id="post-form">
                <input type="text" id="title" placeholder="文章标题" required><br>
                <input type="text" id="author" placeholder="作者姓名" required><br>
                <textarea id="content" placeholder="文章内容" required></textarea><br>
                <button type="submit">发布文章</button>
            </form>

            <h2>📚 最新文章</h2>
            <div id="posts-container">正在加载文章...</div>
        </div>
    </div>

    <script>
        // JavaScript代码处理API交互
        async function loadPosts() {
            const response = await fetch('/api/posts');
            const posts = await response.json();
            // 渲染文章列表
        }
        
        // 页面加载时初始化
        document.addEventListener('DOMContentLoaded', loadPosts);
    </script>
</body>
</html>
EOF
```

**步骤5: 创建Nginx配置**
```bash
# 创建Nginx配置文件
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:3000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        # 静态文件服务
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        
        # API代理到后端
        location /api/ {
            proxy_pass http://backend/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # 健康检查
        location /health {
            proxy_pass http://backend/health;
        }
    }
}
EOF
```

**步骤6: 创建数据库初始化脚本**
```bash
# 创建数据库初始化目录
mkdir init-db

# 创建数据库表和示例数据
cat > init-db/01-init.sql << 'EOF'
USE blog;

CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO posts (title, content, author) VALUES 
('欢迎来到Docker Compose博客系统', 
'这是一个完整的多容器博客应用演示。系统包含前端、后端、数据库和缓存服务。', 
'系统管理员'),
('Docker Compose的优势', 
'Docker Compose让多容器应用管理变得简单。一键启动所有服务，自动配置网络。', 
'Docker专家');
EOF
```

**步骤7: 启动系统并验证**
```bash
# 启动所有服务
docker-compose up -d
```

```bash
# 查看服务状态
docker-compose ps
```
*预期输出*: 所有服务都应该显示为"Up"状态

```bash
# 验证系统健康状态
curl http://localhost:8080/health
```
*预期输出*: 
```json
{
  "status": "healthy",
  "services": {
    "database": "connected",
    "redis": "connected"
  }
}
```

**步骤8: 用户观测和交互验证**

**🌐 Web界面访问验证**:
1. **打开博客主页**: http://localhost:8080
   - 查看响应式界面设计
   - 观察系统状态面板（应显示所有服务正常）
   - 查看预加载的示例文章

2. **测试发布文章功能**:
   - 在Web界面填写新文章表单
   - 点击"发布文章"按钮
   - 观察文章是否立即出现在列表中

3. **数据库管理界面**: http://localhost:8081
   - 使用Adminer连接数据库
   - 服务器: `database`
   - 用户名: `bloguser`
   - 密码: `secret123`
   - 数据库: `blog`

**🔧 API接口测试验证**:
```bash
# 获取文章列表
curl http://localhost:8080/api/posts

# 发布新文章
curl -X POST http://localhost:8080/api/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"API测试文章","content":"通过curl命令发布","author":"测试用户"}'

# 查看系统统计
curl http://localhost:8080/api/stats
```

**🎯 完整版本体验**

如果你想体验更完整、功能更丰富的博客系统，请使用我们准备的完整版本：

```bash
# 进入完整版目录
cd /root/copilot-docker-experiments/experiments/blog-compose-system/

# 使用一键部署脚本
./deploy.sh

# 或者手动部署
docker-compose up -d
```

**完整版特性**:
- ✅ **实时服务监控**: 可视化监控面板，实时显示所有5个服务状态
- ✅ **自动健康检查**: 每30秒自动检查服务健康状态，支持手动刷新
- ✅ **完善的错误处理**: 连接失败、超时等异常情况的友好提示
- ✅ **生产级配置**: 包含安全头、性能优化、日志管理
- ✅ **丰富的示例数据**: 预置多篇技术文章，展示真实使用场景
- ✅ **详细的部署文档**: 包含故障排除、扩展功能等指导

**完整版访问地址**:
- 主页监控面板: http://localhost
- 数据库管理: http://localhost:8080
- 详细文档: 查看 `experiments/blog-compose-system/README.md`

---

**📋 用户观测清单**

作为用户，你应该能够观察到以下现象：

**1. 容器编排效果**
```bash
# 查看所有容器状态
docker-compose ps
```
*观测点*: 5个服务全部启动成功，状态为Up

**2. 服务间通信**
- 前端能通过服务名访问后端API
- 后端能连接MySQL数据库
- 后端能连接Redis缓存
- 所有服务在同一个Docker网络中

**3. 数据持久化**
```bash
# 停止服务
docker-compose down

# 重新启动
docker-compose up -d

# 验证数据是否保持
curl http://localhost/posts
```
*观测点*: 数据库中的文章数据依然存在

**4. 负载均衡和扩展**
```bash
# 扩展后端服务到3个实例
docker-compose up -d --scale backend=3

# 查看扩展效果
docker-compose ps backend
```
*观测点*: 多个后端实例均匀处理请求

**5. 日志聚合查看**
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
```
*观测点*: 可以统一查看所有服务的运行日志
curl http://localhost:8080/api/stats
```

**📊 多容器协作观测**:
```bash
# 查看所有容器日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs backend
docker-compose logs database

# 查看容器资源使用
docker stats
```

**🔍 网络连通性验证**:
```bash
# 进入后端容器测试内部网络
docker-compose exec backend sh

# 在容器内测试（容器内执行）
ping database  # 应该能ping通
ping cache     # 应该能ping通
curl http://cache:6379  # 测试Redis连接
```

**步骤9: 清理和重新启动测试**
```bash
# 停止所有服务
docker-compose down

# 查看数据持久化（数据卷应该保留）
docker volume ls | grep blog-compose-demo

# 重新启动验证数据持久化
docker-compose up -d

# 验证之前发布的文章仍然存在
curl http://localhost:8080/api/posts
```

#### 4.4 Compose命令操作与系统监控

**基础操作命令**:
```bash
# 启动所有服务（后台模式）
docker-compose up -d

# 查看服务状态和端口映射
docker-compose ps

# 查看服务日志（实时跟踪）
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f database

# 重启特定服务
docker-compose restart backend

# 停止所有服务
docker-compose down

# 停止并删除数据卷（注意：会丢失数据）
docker-compose down -v
```

**🔍 系统监控和观测技巧**:

**1. 实时性能监控**
```bash
# 查看所有容器CPU和内存使用情况
docker stats

# 查看特定容器资源使用
docker stats blog-compose-demo_backend_1
```
*观测要点*: 
- CPU使用率应该在启动后稳定在较低水平
- 内存使用：MySQL约400MB，Node.js约50MB，Redis约10MB
- 网络IO反映实际用户访问量

**2. 服务健康状态检查**
```bash
# 检查所有容器健康状态
docker-compose ps

# 详细检查单个服务健康状态
docker inspect blog-compose-demo_backend_1 | grep -A 20 "Health"
```
*健康状态说明*:
- `healthy`: 服务正常运行
- `unhealthy`: 服务异常，需要检查日志
- `starting`: 正在启动中，等待健康检查通过

**3. 网络连通性测试**
```bash
# 查看Docker网络配置
docker network ls

# 检查自定义网络详情
docker network inspect blog-compose-demo_blog-network

# 容器间网络测试
docker-compose exec backend ping database
docker-compose exec backend ping cache
```

**4. 数据持久化验证**
```bash
# 查看数据卷使用情况
docker volume ls | grep blog-compose-demo

# 检查数据卷详细信息
docker volume inspect blog-compose-demo_mysql_data

# 模拟数据持久化测试
docker-compose down
docker-compose up -d
curl http://localhost:8080/api/posts  # 数据应该仍然存在
```

**🚨 故障排除指南**:

**问题1: 容器无法启动**
```bash
# 查看容器启动错误
docker-compose logs [service-name]

# 检查端口冲突
netstat -tlnp | grep :8080
lsof -i :8080
```

**问题2: 服务间无法通信**
```bash
# 检查网络配置
docker-compose exec backend nslookup database
docker-compose exec backend ping database

# 检查防火墙设置
sudo ufw status
```

**问题3: 数据库连接失败**
```bash
# 进入数据库容器检查
docker-compose exec database mysql -u bloguser -p blog

# 查看MySQL进程和端口
docker-compose exec database ps aux | grep mysql
docker-compose exec database netstat -tlnp | grep 3306
```

**🎯 用户体验验证清单**:

**Web界面功能测试**:
- [ ] 博客首页正常加载 (http://localhost:8080)
- [ ] 系统状态面板显示所有服务正常
- [ ] 能够发布新文章并立即显示
- [ ] 文章列表正确显示时间和作者
- [ ] 响应式设计在移动端正常工作

**API接口功能测试**:
- [ ] 健康检查接口返回正常 (GET /health)
- [ ] 获取文章列表成功 (GET /api/posts)
- [ ] 发布文章接口工作正常 (POST /api/posts)
- [ ] 统计信息接口返回正确数据 (GET /api/stats)

**数据管理验证**:
- [ ] Adminer界面能够连接数据库 (http://localhost:8081)
- [ ] 数据库表结构正确创建
- [ ] 示例数据成功插入
- [ ] 新发布的文章保存到数据库

**性能和稳定性**:
- [ ] 页面加载时间小于2秒
- [ ] API响应时间小于100ms
- [ ] 容器重启后数据完整保留
- [ ] 系统能够处理并发访问

**📈 扩展实验建议**:

**1. 负载测试**
```bash
# 使用ab工具进行简单负载测试
ab -n 100 -c 10 http://localhost:8080/

# 测试API接口性能
ab -n 50 -c 5 http://localhost:8080/api/posts
```

**2. 扩展实验**
```bash
# 尝试扩展后端服务到多个实例
docker-compose up -d --scale backend=3

# 查看负载均衡效果
docker-compose ps
```

**3. 日志分析**
```bash
# 实时监控所有服务日志
docker-compose logs -f --tail=100

# 分析错误日志
docker-compose logs | grep -i error
docker-compose logs | grep -i warning
```

---

## 📖 Module 5: 微服务架构设计与实践

### 🎯 学习目标
- 理解微服务架构设计原则和拆分策略
- 掌握从单体应用向微服务的渐进式演进
- 实现API网关和服务间通信
- 在Module 4基础上扩展用户认证和评论系统

### 📚 理论学习 (2小时)

#### 5.1 微服务架构演进之路

**从单体到微服务的渐进式演进**:
```
Module 4: 单体应用架构
┌─────────────────────────────────────────────────┐
│ Frontend → Backend (单体) → Database + Cache    │
│ (Nginx)   (所有API集中)   (MySQL + Redis)      │
└─────────────────────────────────────────────────┘

Module 5: 微服务架构
┌─────────────────────────────────────────────────────────────┐
│ Frontend → API Gateway → [User Service]   → Shared Database │
│ (React)   (Nginx路由)    [Post Service]   → (MySQL扩展)    │
│                         [Comment Service] → + Cache        │
└─────────────────────────────────────────────────────────────┘
```

#### 5.2 微服务设计原则

**核心设计理念**:
```
┌─────────────────────────────────────────────────┐
│            轻量级微服务设计原则                  │
├─────────────────────────────────────────────────┤
│ ✅ 业务职责分离: 用户、文章、评论独立服务       │
│ ✅ 数据共享优化: 共用数据库，减少复杂性        │
│ ✅ 渐进式重构: 基于已有代码，最小化改动        │
│ ✅ 接口标准化: 统一的RESTful API设计          │
│ ✅ 故障隔离: 单服务异常不影响整体功能         │
│ ✅ 独立部署: 每个服务可单独更新和扩展         │
└─────────────────────────────────────────────────┘
```

#### 5.3 服务拆分策略

**基于Module 4的服务拆分方案**:
```
原始单体 backend/app.js 拆分为:

├── user-service (用户管理微服务)
│   ├── 用户注册、登录、JWT认证
│   ├── 个人资料管理
│   ├── 简单权限控制
│   └── API: /users/*
│
├── post-service (文章管理微服务)
│   ├── 复用现有文章CRUD逻辑
│   ├── 文章与作者关联
│   ├── 文章状态管理
│   └── API: /posts/*
│
└── comment-service (评论系统微服务)
    ├── 多级评论和回复
    ├── 评论审核管理
    ├── 评论统计功能
    └── API: /comments/*
```

#### 5.4 API网关模式

**统一入口和路由策略**:
```nginx
# API Gateway 路由规则
upstream user_service {
    server user-service:3001;
}

upstream post_service {
    server post-service:3002;
}

upstream comment_service {
    server comment-service:3003;
}

server {
    listen 80;
    
    # 用户相关API
    location /api/users/ {
        proxy_pass http://user_service/;
    }
    
    # 文章相关API  
    location /api/posts/ {
        proxy_pass http://post_service/;
    }
    
    # 评论相关API
    location /api/comments/ {
        proxy_pass http://comment_service/;
    }
    
    # 健康检查聚合
    location /api/health {
        proxy_pass http://post_service/health;
    }
}
```

### 🛠️ 实践操作 (4小时)

#### 5.5 项目结构创建与代码复用

**步骤1: 创建微服务版本项目**
```bash
# 复制Module 4的成功实践作为基础
cp -r /root/copilot-docker-experiments/experiments/blog-compose-system/ \
      /root/copilot-docker-experiments/experiments/blog-microservices-system/

cd blog-microservices-system

# 创建微服务目录结构
mkdir -p services/{user-service,post-service,comment-service}
mkdir -p gateway
```

**步骤2: 数据库结构扩展**
```bash
# 创建扩展的数据库初始化脚本
cat > init-db/02-add-users.sql << 'EOF'
-- 在现有blog_system数据库基础上扩展用户表
USE blog_system;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 为现有posts表添加作者关联
ALTER TABLE posts ADD COLUMN IF NOT EXISTS author_id INT DEFAULT 1;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS status ENUM('draft', 'published') DEFAULT 'published';

-- 插入示例用户
INSERT IGNORE INTO users (id, username, email, password_hash, display_name) VALUES 
(1, 'admin', 'admin@blog.com', '$2b$10$hash', '系统管理员'),
(2, 'author1', 'author1@blog.com', '$2b$10$hash', '技术作者'),
(3, 'reader1', 'reader1@blog.com', '$2b$10$hash', '普通读者');

-- 更新现有文章的作者信息
UPDATE posts SET author_id = 1 WHERE author IS NULL OR author = '系统管理员';
UPDATE posts SET author_id = 2 WHERE author = 'Docker专家';
EOF

cat > init-db/03-add-comments.sql << 'EOF'
-- 评论表
USE blog_system;

CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    parent_id INT DEFAULT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_id (parent_id)
);

-- 插入示例评论
INSERT IGNORE INTO comments (post_id, user_id, content) VALUES 
(1, 2, '这篇文章写得非常好！Docker Compose确实让多容器管理变得简单。'),
(1, 3, '感谢分享，学到了很多容器编排的知识。'),
(2, 1, '微服务架构是现代应用开发的趋势，值得深入学习。');
EOF
```

#### 5.6 微服务代码开发

**步骤3: User Service 开发**
```bash
# 创建用户服务目录和依赖
mkdir -p services/user-service
cd services/user-service

# 创建package.json (复用现有依赖)
cat > package.json << 'EOF'
{
  "name": "user-service",
  "version": "1.0.0",
  "description": "User management microservice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "bcrypt": "^5.1.0",
    "jsonwebtoken": "^9.0.2",
    "cors": "^2.8.5"
  }
}
EOF

# 创建用户服务主文件 (基于Module 4的数据库连接逻辑)
cat > app.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const port = 3001;

// 中间件
app.use(cors());
app.use(express.json());

// 数据库连接配置 (复用Module 4的配置)
const dbConfig = {
  host: process.env.DB_HOST || 'database',
  user: process.env.DB_USER || 'bloguser',
  password: process.env.DB_PASSWORD || 'secret123',
  database: process.env.DB_NAME || 'blog_system',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ User Service: Database connected successfully');
    connection.release();
  } catch (error) {
    console.log('❌ User Service: Database connection failed:', error.message);
  }
})();

// JWT密钥
const JWT_SECRET = process.env.JWT_SECRET || 'user-service-secret-key';

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    service: 'user-service',
    status: 'healthy', 
    timestamp: new Date().toISOString()
  });
});

// 用户注册
app.post('/register', async (req, res) => {
  try {
    const { username, email, password, display_name } = req.body;
    
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Username, email, and password are required' });
    }
    
    // 检查用户是否已存在
    const [existing] = await pool.execute(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [username, email]
    );
    
    if (existing.length > 0) {
      return res.status(409).json({ error: 'Username or email already exists' });
    }
    
    // 密码加密
    const password_hash = await bcrypt.hash(password, 10);
    
    // 创建用户
    const [result] = await pool.execute(
      'INSERT INTO users (username, email, password_hash, display_name) VALUES (?, ?, ?, ?)',
      [username, email, password_hash, display_name || username]
    );
    
    res.status(201).json({ 
      id: result.insertId,
      username,
      email,
      display_name: display_name || username,
      message: 'User registered successfully' 
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

// 用户登录
app.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }
    
    // 查找用户
    const [users] = await pool.execute(
      'SELECT id, username, email, password_hash, display_name FROM users WHERE username = ? OR email = ?',
      [username, username]
    );
    
    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const user = users[0];
    
    // 验证密码
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // 生成JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username,
        email: user.email 
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        display_name: user.display_name
      }
    });
  } catch (error) {
    console.error('Error logging in user:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

// 获取用户信息
app.get('/profile/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    
    const [users] = await pool.execute(
      'SELECT id, username, email, display_name, avatar_url, created_at FROM users WHERE id = ?',
      [userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(users[0]);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// 获取所有用户列表 (用于作者选择)
app.get('/list', async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT id, username, display_name FROM users ORDER BY display_name'
    );
    
    res.json(users);
  } catch (error) {
    console.error('Error fetching users list:', error);
    res.status(500).json({ error: 'Failed to fetch users list' });
  }
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 User Service running on port ${port}`);
});
EOF

# 创建Dockerfile (复用Module 4的构建逻辑)
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 复制package文件并安装依赖
COPY package*.json ./
RUN npm install --production

# 安装curl用于健康检查
RUN apk add --no-cache curl

# 复制应用代码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 更改文件权限
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3001

CMD ["npm", "start"]
EOF

cd ../..
```

**步骤4: Post Service 开发 (复用Module 4代码)**
```bash
# 创建文章服务目录
mkdir -p services/post-service
cd services/post-service

# 复制并修改现有的backend代码
cp ../../backend/package.json .
cp ../../backend/Dockerfile .

# 创建专注于文章管理的服务
cat > app.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const port = 3002;

// 中间件
app.use(cors());
app.use(express.json());

// 数据库连接配置 (完全复用Module 4的配置)
const dbConfig = {
  host: process.env.DB_HOST || 'database',
  user: process.env.DB_USER || 'bloguser',
  password: process.env.DB_PASSWORD || 'secret123',
  database: process.env.DB_NAME || 'blog_system',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ Post Service: Database connected successfully');
    connection.release();
  } catch (error) {
    console.log('❌ Post Service: Database connection failed:', error.message);
  }
})();

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    service: 'post-service',
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    database: pool ? 'connected' : 'disconnected'
  });
});

// 获取所有文章 (扩展为包含作者信息)
app.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT p.id, p.title, p.content, p.author, p.created_at, p.status,
             u.username as author_username, u.display_name as author_display_name
      FROM posts p 
      LEFT JOIN users u ON p.author_id = u.id
      WHERE p.status = 'published'
      ORDER BY p.created_at DESC
    `);
    res.json(rows);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
});

// 获取单篇文章
app.get('/:id', async (req, res) => {
  try {
    const postId = req.params.id;
    const [rows] = await pool.execute(`
      SELECT p.id, p.title, p.content, p.author, p.created_at, p.status,
             u.username as author_username, u.display_name as author_display_name
      FROM posts p 
      LEFT JOIN users u ON p.author_id = u.id
      WHERE p.id = ? AND p.status = 'published'
    `, [postId]);
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching post:', error);
    res.status(500).json({ error: 'Failed to fetch post' });
  }
});

// 创建新文章 (支持作者选择)
app.post('/', async (req, res) => {
  try {
    const { title, content, author, author_id } = req.body;
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO posts (title, content, author, author_id, created_at, status) VALUES (?, ?, ?, ?, NOW(), ?)',
      [title, content, author || 'Anonymous', author_id || 1, 'published']
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Post created successfully' 
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
});

// 获取文章统计信息
app.get('/stats/summary', async (req, res) => {
  try {
    const [postCount] = await pool.execute('SELECT COUNT(*) as count FROM posts WHERE status = "published"');
    const [authorCount] = await pool.execute('SELECT COUNT(DISTINCT author_id) as count FROM posts WHERE status = "published"');
    
    res.json({
      totalPosts: postCount[0].count,
      totalAuthors: authorCount[0].count,
      service: 'post-service',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching post stats:', error);
    res.status(500).json({ error: 'Failed to fetch post stats' });
  }
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Post Service running on port ${port}`);
});
EOF

# 修改Dockerfile端口
sed -i 's/EXPOSE 3000/EXPOSE 3002/' Dockerfile

cd ../..
```

**步骤5: Comment Service 开发**
```bash
# 创建评论服务目录
mkdir -p services/comment-service
cd services/comment-service

# 复制基础配置
cp ../../backend/package.json .
cp ../../backend/Dockerfile .

# 创建评论管理服务
cat > app.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const port = 3003;

// 中间件
app.use(cors());
app.use(express.json());

// 数据库连接配置
const dbConfig = {
  host: process.env.DB_HOST || 'database',
  user: process.env.DB_USER || 'bloguser',
  password: process.env.DB_PASSWORD || 'secret123',
  database: process.env.DB_NAME || 'blog_system',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ Comment Service: Database connected successfully');
    connection.release();
  } catch (error) {
    console.log('❌ Comment Service: Database connection failed:', error.message);
  }
})();

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    service: 'comment-service',
    status: 'healthy', 
    timestamp: new Date().toISOString()
  });
});

// 获取文章的所有评论
app.get('/post/:postId', async (req, res) => {
  try {
    const postId = req.params.postId;
    
    const [comments] = await pool.execute(`
      SELECT c.id, c.content, c.created_at, c.parent_id,
             u.username, u.display_name as author_name
      FROM comments c
      JOIN users u ON c.user_id = u.id
      WHERE c.post_id = ? AND c.status = 'approved'
      ORDER BY c.created_at ASC
    `, [postId]);
    
    res.json(comments);
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
});

// 发布新评论
app.post('/post/:postId', async (req, res) => {
  try {
    const postId = req.params.postId;
    const { content, user_id, parent_id } = req.body;
    
    if (!content || !user_id) {
      return res.status(400).json({ error: 'Content and user_id are required' });
    }
    
    // 检查文章是否存在
    const [posts] = await pool.execute('SELECT id FROM posts WHERE id = ?', [postId]);
    if (posts.length === 0) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // 检查用户是否存在
    const [users] = await pool.execute('SELECT id FROM users WHERE id = ?', [user_id]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO comments (post_id, user_id, content, parent_id, status, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
      [postId, user_id, content, parent_id || null, 'approved']
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Comment created successfully' 
    });
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({ error: 'Failed to create comment' });
  }
});

// 获取评论统计信息
app.get('/stats/summary', async (req, res) => {
  try {
    const [commentCount] = await pool.execute('SELECT COUNT(*) as count FROM comments WHERE status = "approved"');
    const [postWithComments] = await pool.execute('SELECT COUNT(DISTINCT post_id) as count FROM comments WHERE status = "approved"');
    
    res.json({
      totalComments: commentCount[0].count,
      postsWithComments: postWithComments[0].count,
      service: 'comment-service',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching comment stats:', error);
    res.status(500).json({ error: 'Failed to fetch comment stats' });
  }
});

// 删除评论 (简单实现)
app.delete('/:commentId', async (req, res) => {
  try {
    const commentId = req.params.commentId;
    
    const [result] = await pool.execute(
      'DELETE FROM comments WHERE id = ?',
      [commentId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    
    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ error: 'Failed to delete comment' });
  }
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Comment Service running on port ${port}`);
});
EOF

# 修改Dockerfile端口
sed -i 's/EXPOSE 3000/EXPOSE 3003/' Dockerfile

cd ../..
```

#### 5.7 API网关配置

**步骤6: 创建API网关配置**
```bash
# 创建网关目录和配置
mkdir -p gateway

# 创建API网关的Nginx配置 (基于Module 4扩展)
cat > gateway/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # 上游服务定义
    upstream user_service {
        server user-service:3001;
    }
    
    upstream post_service {
        server post-service:3002;
    }
    
    upstream comment_service {
        server comment-service:3003;
    }
    
    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'service="$upstream_addr"';
    
    access_log /var/log/nginx/access.log main;
    
    # 主服务器配置
    server {
        listen 80;
        server_name localhost;
        
        # 静态文件服务 (复用Module 4的前端)
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
        
        # 用户服务路由
        location /api/users/ {
            proxy_pass http://user_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS处理
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS';
            add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            
            if ($request_method = 'OPTIONS') {
                return 204;
            }
        }
        
        # 文章服务路由  
        location /api/posts/ {
            proxy_pass http://post_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS';
            add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            
            if ($request_method = 'OPTIONS') {
                return 204;
            }
        }
        
        # 评论服务路由
        location /api/comments/ {
            proxy_pass http://comment_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS';
            add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            
            if ($request_method = 'OPTIONS') {
                return 204;
            }
        }
        
        # 聚合健康检查
        location /api/health {
            proxy_pass http://post_service/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # 系统状态聚合 (调用所有服务的统计接口)
        location /api/stats {
            access_by_lua_block {
                local http = require "resty.http"
                local cjson = require "cjson"
                
                -- 这里可以实现统计信息聚合逻辑
                -- 简化版本直接代理到post服务
            }
            proxy_pass http://post_service/stats/summary;
        }
        
        # Nginx状态页面 (可选)
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
    }
}
EOF
```

#### 5.8 Docker Compose微服务编排

**步骤7: 创建微服务版本的Docker Compose配置**
```bash
# 创建微服务版本的docker-compose文件
cat > docker-compose.microservices.yml << 'EOF'
version: '3.3'

services:
  # API网关 - 替代原来的frontend服务
  api-gateway:
    image: nginx:alpine
    ports:
      - "8086:80"  # 使用新端口避免与Module 4冲突
    volumes:
      - ./frontend:/usr/share/nginx/html
      - ./gateway/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - post-service
      - comment-service
    restart: unless-stopped
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 用户服务
  user-service:
    build:
      context: ./services/user-service
      dockerfile: Dockerfile
    environment:
      - DB_HOST=database
      - DB_NAME=blog_system
      - DB_USER=bloguser
      - DB_PASSWORD=secret123
      - JWT_SECRET=microservices-jwt-secret-key
      - NODE_ENV=production
    depends_on:
      - database
    restart: unless-stopped
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 文章服务
  post-service:
    build:
      context: ./services/post-service
      dockerfile: Dockerfile
    environment:
      - DB_HOST=database
      - DB_NAME=blog_system
      - DB_USER=bloguser
      - DB_PASSWORD=secret123
      - NODE_ENV=production
    depends_on:
      - database
      - cache
    restart: unless-stopped
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3002/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 评论服务
  comment-service:
    build:
      context: ./services/comment-service
      dockerfile: Dockerfile
    environment:
      - DB_HOST=database
      - DB_NAME=blog_system
      - DB_USER=bloguser
      - DB_PASSWORD=secret123
      - NODE_ENV=production
    depends_on:
      - database
    restart: unless-stopped
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3003/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 数据库服务 (完全复用Module 4配置)
  database:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=blog_system
      - MYSQL_USER=bloguser
      - MYSQL_PASSWORD=secret123
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
      - ./mysql.cnf:/etc/mysql/conf.d/mysql.cnf
    restart: unless-stopped
    networks:
      - microservices-network
    ports:
      - "3308:3306"  # 使用新端口避免冲突

  # 缓存服务 (复用Module 4配置)
  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - microservices-network
    ports:
      - "6382:6379"  # 使用新端口避免冲突

  # 数据库管理工具 (复用Module 4配置)
  adminer:
    image: adminer:latest
    ports:
      - "8083:8080"  # 使用新端口避免冲突
    depends_on:
      - database
    restart: unless-stopped
    networks:
      - microservices-network

volumes:
  mysql_data:
  redis_data:

networks:
  microservices-network:
    driver: bridge
    name: blog-microservices-network
EOF
```

#### 5.9 前端界面升级

**步骤8: 扩展前端界面以支持新功能**
```bash
# 备份原有前端文件
cp frontend/index.html frontend/index.html.backup

# 创建增强版前端界面
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>微服务博客系统 - Module 5 演示</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; color: #333;
        }
        
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        
        header { 
            background: rgba(255,255,255,0.1); backdrop-filter: blur(10px);
            color: white; text-align: center; padding: 2rem; margin-bottom: 2rem; 
            border-radius: 15px; box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }
        
        .header-nav { 
            display: flex; justify-content: center; gap: 20px; margin-top: 15px;
        }
        
        .nav-btn {
            background: rgba(255,255,255,0.2); color: white; border: none;
            padding: 8px 16px; border-radius: 20px; cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .nav-btn:hover { background: rgba(255,255,255,0.3); }
        .nav-btn.active { background: rgba(255,255,255,0.4); }
        
        .panel { 
            background: white; margin-bottom: 20px; border-radius: 12px; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1); overflow: hidden;
        }
        
        .panel-header { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; padding: 15px 20px; font-weight: 600;
            display: flex; justify-content: space-between; align-items: center;
        }
        
        .panel-content { padding: 20px; }
        
        .status-grid { 
            display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px; margin-bottom: 20px;
        }
        
        .status-item { 
            background: #f8f9fa; padding: 15px; border-radius: 8px;
            border-left: 4px solid #28a745;
            transition: all 0.3s ease;
        }
        
        .status-item.checking { border-color: #ffc107; }
        .status-item.error { border-color: #dc3545; }
        
        .service-name { font-weight: 600; margin-bottom: 5px; }
        .service-desc { font-size: 0.9em; color: #666; margin-bottom: 8px; }
        .service-status { 
            display: inline-block; padding: 2px 8px; border-radius: 12px;
            font-size: 0.8em; font-weight: 500; color: white;
        }
        
        .status-healthy { background: #28a745; }
        .status-checking { background: #ffc107; }
        .status-error { background: #dc3545; }
        
        .form-group { margin-bottom: 15px; }
        .form-row { display: flex; gap: 10px; align-items: end; }
        
        input, textarea, select { 
            width: 100%; padding: 12px; border: 2px solid #e1e5e9;
            border-radius: 6px; font-size: 14px;
            transition: border-color 0.3s ease;
        }
        
        input:focus, textarea:focus, select:focus { 
            outline: none; border-color: #667eea;
        }
        
        textarea { resize: vertical; min-height: 100px; }
        
        button { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; border: none; padding: 12px 24px;
            border-radius: 6px; cursor: pointer; font-weight: 500;
            transition: all 0.3s ease;
        }
        
        button:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(102,126,234,0.4); }
        button:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
        
        .btn-small { padding: 6px 12px; font-size: 0.85em; }
        .btn-danger { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); }
        
        .post-item, .comment-item { 
            background: #f8f9fa; padding: 15px; margin-bottom: 15px;
            border-radius: 8px; border-left: 4px solid #667eea;
        }
        
        .post-title { font-weight: 600; margin-bottom: 8px; color: #333; }
        .post-meta { font-size: 0.9em; color: #666; margin-bottom: 10px; }
        .post-content { line-height: 1.6; }
        
        .comment-item { margin-left: 20px; border-left-color: #28a745; }
        .comment-author { font-weight: 600; color: #667eea; }
        .comment-content { margin-top: 5px; }
        
        .auth-section { 
            background: rgba(255,255,255,0.95); padding: 20px; border-radius: 12px;
            margin-bottom: 20px; display: none;
        }
        
        .auth-section.active { display: block; }
        
        .user-info { 
            background: rgba(102,126,234,0.1); padding: 15px; border-radius: 8px;
            display: flex; justify-content: space-between; align-items: center;
        }
        
        .refresh-btn { 
            background: rgba(255,255,255,0.2); color: #667eea; border: 1px solid #667eea;
            padding: 6px 12px; border-radius: 4px; cursor: pointer;
        }
        
        .loading { 
            display: inline-block; width: 20px; height: 20px;
            border: 2px solid #f3f3f3; border-top: 2px solid #667eea;
            border-radius: 50%; animation: spin 1s linear infinite;
        }
        
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        
        .hidden { display: none !important; }
        
        @media (max-width: 768px) {
            .container { padding: 10px; }
            .header-nav { flex-wrap: wrap; }
            .form-row { flex-direction: column; }
            .status-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🚀 微服务博客系统</h1>
            <p>Docker Compose + 微服务架构演示 (Module 5)</p>
            <div class="header-nav">
                <button class="nav-btn active" onclick="showSection('dashboard')">系统监控</button>
                <button class="nav-btn" onclick="showSection('auth')">用户认证</button>
                <button class="nav-btn" onclick="showSection('posts')">文章管理</button>
                <button class="nav-btn" onclick="showSection('comments')">评论系统</button>
            </div>
        </header>

        <!-- 系统监控面板 -->
        <div id="dashboard-section">
            <div class="panel">
                <div class="panel-header">
                    <span>📊 微服务状态监控</span>
                    <button class="refresh-btn" onclick="checkAllServices()">
                        <span id="refresh-icon">🔄</span> 刷新状态
                    </button>
                </div>
                <div class="panel-content">
                    <div class="status-grid" id="services-status">
                        <!-- 动态加载服务状态 -->
                    </div>
                </div>
            </div>
        </div>

        <!-- 用户认证面板 -->
        <div id="auth-section" class="auth-section">
            <div class="panel">
                <div class="panel-header">
                    <span>👤 用户认证系统</span>
                </div>
                <div class="panel-content">
                    <div id="login-form">
                        <h3>用户登录</h3>
                        <div class="form-group">
                            <input type="text" id="login-username" placeholder="用户名或邮箱">
                        </div>
                        <div class="form-group">
                            <input type="password" id="login-password" placeholder="密码">
                        </div>
                        <button onclick="loginUser()">登录</button>
                        <button onclick="showRegisterForm()" style="margin-left: 10px;">注册新用户</button>
                    </div>

                    <div id="register-form" class="hidden">
                        <h3>用户注册</h3>
                        <div class="form-group">
                            <input type="text" id="reg-username" placeholder="用户名">
                        </div>
                        <div class="form-group">
                            <input type="email" id="reg-email" placeholder="邮箱地址">
                        </div>
                        <div class="form-group">
                            <input type="password" id="reg-password" placeholder="密码">
                        </div>
                        <div class="form-group">
                            <input type="text" id="reg-display-name" placeholder="显示名称（可选）">
                        </div>
                        <button onclick="registerUser()">注册</button>
                        <button onclick="showLoginForm()" style="margin-left: 10px;">返回登录</button>
                    </div>

                    <div id="user-info" class="user-info hidden">
                        <!-- 用户信息显示区域 -->
                    </div>
                </div>
            </div>
        </div>

        <!-- 文章管理面板 -->
        <div id="posts-section" class="auth-section">
            <div class="panel">
                <div class="panel-header">
                    <span>📝 文章发布系统</span>
                </div>
                <div class="panel-content">
                    <form id="post-form">
                        <div class="form-row">
                            <div style="flex: 2;">
                                <input type="text" id="post-title" placeholder="文章标题" required>
                            </div>
                            <div style="flex: 1;">
                                <select id="post-author">
                                    <option value="">选择作者...</option>
                                </select>
                            </div>
                            <div>
                                <button type="submit">发布文章</button>
                            </div>
                        </div>
                        <div class="form-group">
                            <textarea id="post-content" placeholder="文章内容..." required></textarea>
                        </div>
                    </form>
                </div>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <span>📚 文章列表</span>
                    <button class="refresh-btn" onclick="loadPosts()">刷新列表</button>
                </div>
                <div class="panel-content">
                    <div id="posts-container">正在加载文章...</div>
                </div>
            </div>
        </div>

        <!-- 评论系统面板 -->
        <div id="comments-section" class="auth-section">
            <div class="panel">
                <div class="panel-header">
                    <span>💬 评论系统</span>
                </div>
                <div class="panel-content">
                    <div id="comments-container">
                        <p>请先选择一篇文章查看评论...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 全局变量
        let currentUser = null;
        let authToken = null;
        let currentSection = 'dashboard';

        // 页面初始化
        document.addEventListener('DOMContentLoaded', function() {
            checkAllServices();
            loadUsers();
            loadPosts();
            
            // 检查本地存储的登录状态
            const savedToken = localStorage.getItem('authToken');
            const savedUser = localStorage.getItem('currentUser');
            if (savedToken && savedUser) {
                authToken = savedToken;
                currentUser = JSON.parse(savedUser);
                updateUserInterface();
            }
        });

        // 节面切换
        function showSection(section) {
            // 更新导航按钮状态
            document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            
            // 隐藏所有sections
            document.querySelectorAll('[id$="-section"]').forEach(sec => {
                sec.style.display = 'none';
            });
            
            // 显示目标section
            document.getElementById(section + '-section').style.display = 'block';
            currentSection = section;
        }

        // 服务状态检查
        async function checkAllServices() {
            const refreshIcon = document.getElementById('refresh-icon');
            refreshIcon.textContent = '⏳';
            
            const services = [
                { name: 'API网关', endpoint: '/api/health', desc: 'Nginx反向代理和路由' },
                { name: '用户服务', endpoint: '/api/users/health', desc: '认证、注册、用户管理' },
                { name: '文章服务', endpoint: '/api/posts/health', desc: '文章发布、编辑、查询' },
                { name: '评论服务', endpoint: '/api/comments/health', desc: '评论发布、审核、管理' },
                { name: '数据库', endpoint: '/api/posts/health', desc: 'MySQL数据持久化' }
            ];

            const container = document.getElementById('services-status');
            container.innerHTML = '';

            for (const service of services) {
                const statusItem = createServiceStatusItem(service);
                container.appendChild(statusItem);
                
                try {
                    const response = await fetch(service.endpoint);
                    const data = await response.json();
                    
                    if (response.ok) {
                        updateServiceStatus(statusItem, 'healthy', `✅ 运行正常 (${data.service || 'API'})`);
                    } else {
                        updateServiceStatus(statusItem, 'error', `❌ 服务异常 (${response.status})`);
                    }
                } catch (error) {
                    updateServiceStatus(statusItem, 'error', `❌ 连接失败: ${error.message}`);
                }
            }
            
            refreshIcon.textContent = '🔄';
        }

        function createServiceStatusItem(service) {
            const item = document.createElement('div');
            item.className = 'status-item checking';
            item.innerHTML = `
                <div class="service-name">${service.name}</div>
                <div class="service-desc">${service.desc}</div>
                <div class="service-status status-checking">🔄 检查中...</div>
            `;
            return item;
        }

        function updateServiceStatus(item, status, message) {
            const statusEl = item.querySelector('.service-status');
            statusEl.textContent = message;
            statusEl.className = `service-status status-${status}`;
            item.className = `status-item ${status}`;
        }

        // 用户认证相关函数
        function showLoginForm() {
            document.getElementById('login-form').classList.remove('hidden');
            document.getElementById('register-form').classList.add('hidden');
        }

        function showRegisterForm() {
            document.getElementById('login-form').classList.add('hidden');
            document.getElementById('register-form').classList.remove('hidden');
        }

        async function registerUser() {
            const username = document.getElementById('reg-username').value;
            const email = document.getElementById('reg-email').value;
            const password = document.getElementById('reg-password').value;
            const display_name = document.getElementById('reg-display-name').value;

            if (!username || !email || !password) {
                alert('请填写所有必填字段');
                return;
            }

            try {
                const response = await fetch('/api/users/register', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ username, email, password, display_name })
                });

                const data = await response.json();

                if (response.ok) {
                    alert('注册成功！请登录');
                    showLoginForm();
                    // 清空表单
                    document.getElementById('reg-username').value = '';
                    document.getElementById('reg-email').value = '';
                    document.getElementById('reg-password').value = '';
                    document.getElementById('reg-display-name').value = '';
                } else {
                    alert('注册失败: ' + data.error);
                }
            } catch (error) {
                alert('注册请求失败: ' + error.message);
            }
        }

        async function loginUser() {
            const username = document.getElementById('login-username').value;
            const password = document.getElementById('login-password').value;

            if (!username || !password) {
                alert('请输入用户名和密码');
                return;
            }

            try {
                const response = await fetch('/api/users/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ username, password })
                });

                const data = await response.json();

                if (response.ok) {
                    authToken = data.token;
                    currentUser = data.user;
                    
                    // 保存到本地存储
                    localStorage.setItem('authToken', authToken);
                    localStorage.setItem('currentUser', JSON.stringify(currentUser));
                    
                    updateUserInterface();
                    alert('登录成功！');
                } else {
                    alert('登录失败: ' + data.error);
                }
            } catch (error) {
                alert('登录请求失败: ' + error.message);
            }
        }

        function logout() {
            authToken = null;
            currentUser = null;
            localStorage.removeItem('authToken');
            localStorage.removeItem('currentUser');
            updateUserInterface();
        }

        function updateUserInterface() {
            const loginForm = document.getElementById('login-form');
            const registerForm = document.getElementById('register-form');
            const userInfo = document.getElementById('user-info');

            if (currentUser) {
                loginForm.classList.add('hidden');
                registerForm.classList.add('hidden');
                userInfo.classList.remove('hidden');
                
                userInfo.innerHTML = `
                    <div>
                        <strong>👤 ${currentUser.display_name || currentUser.username}</strong>
                        <div style="font-size: 0.9em; color: #666;">${currentUser.email}</div>
                    </div>
                    <button onclick="logout()" class="btn-small btn-danger">退出登录</button>
                `;
            } else {
                loginForm.classList.remove('hidden');
                registerForm.classList.add('hidden');
                userInfo.classList.add('hidden');
            }
        }

        // 加载用户列表(用于作者选择)
        async function loadUsers() {
            try {
                const response = await fetch('/api/users/list');
                const users = await response.json();
                
                const select = document.getElementById('post-author');
                select.innerHTML = '<option value="">选择作者...</option>';
                
                users.forEach(user => {
                    const option = document.createElement('option');
                    option.value = user.id;
                    option.textContent = user.display_name || user.username;
                    select.appendChild(option);
                });
            } catch (error) {
                console.error('加载用户列表失败:', error);
            }
        }

        // 文章相关函数
        async function loadPosts() {
            try {
                const response = await fetch('/api/posts/');
                const posts = await response.json();
                
                const container = document.getElementById('posts-container');
                
                if (posts.length === 0) {
                    container.innerHTML = '<p>暂无文章，发布第一篇文章吧！</p>';
                    return;
                }
                
                container.innerHTML = posts.map(post => `
                    <div class="post-item" onclick="showComments(${post.id})">
                        <div class="post-title">${post.title}</div>
                        <div class="post-meta">
                            作者: ${post.author_display_name || post.author} | 
                            发布时间: ${new Date(post.created_at).toLocaleString()}
                            ${post.id ? ' | 点击查看评论' : ''}
                        </div>
                        <div class="post-content">${post.content.substring(0, 200)}${post.content.length > 200 ? '...' : ''}</div>
                    </div>
                `).join('');
            } catch (error) {
                document.getElementById('posts-container').innerHTML = '<p>加载文章失败: ' + error.message + '</p>';
            }
        }

        // 发布文章
        document.getElementById('post-form').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const title = document.getElementById('post-title').value;
            const content = document.getElementById('post-content').value;
            const author_id = document.getElementById('post-author').value;
            
            if (!title || !content) {
                alert('请填写标题和内容');
                return;
            }
            
            try {
                const response = await fetch('/api/posts/', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 
                        title, 
                        content, 
                        author: currentUser?.display_name || '匿名用户',
                        author_id: author_id || currentUser?.id || 1
                    })
                });
                
                const data = await response.json();
                
                if (response.ok) {
                    alert('文章发布成功！');
                    document.getElementById('post-title').value = '';
                    document.getElementById('post-content').value = '';
                    loadPosts();
                } else {
                    alert('发布失败: ' + data.error);
                }
            } catch (error) {
                alert('发布请求失败: ' + error.message);
            }
        });

        // 评论相关函数
        async function showComments(postId) {
            if (currentSection !== 'comments') {
                showSection('comments');
            }
            
            try {
                const response = await fetch(`/api/comments/post/${postId}`);
                const comments = await response.json();
                
                const container = document.getElementById('comments-container');
                
                if (comments.length === 0) {
                    container.innerHTML = `
                        <p>暂无评论</p>
                        ${currentUser ? `
                            <div style="margin-top: 20px;">
                                <textarea id="new-comment-${postId}" placeholder="发表评论..." style="width: 100%; height: 80px;"></textarea>
                                <button onclick="addComment(${postId})" style="margin-top: 10px;">发表评论</button>
                            </div>
                        ` : '<p>请先登录后发表评论</p>'}
                    `;
                    return;
                }
                
                container.innerHTML = `
                    <h3>文章评论 (${comments.length}条)</h3>
                    ${comments.map(comment => `
                        <div class="comment-item">
                            <div class="comment-author">${comment.author_name}</div>
                            <div class="comment-content">${comment.content}</div>
                            <div style="font-size: 0.8em; color: #999; margin-top: 5px;">
                                ${new Date(comment.created_at).toLocaleString()}
                            </div>
                        </div>
                    `).join('')}
                    
                    ${currentUser ? `
                        <div style="margin-top: 20px;">
                            <textarea id="new-comment-${postId}" placeholder="发表评论..." style="width: 100%; height: 80px;"></textarea>
                            <button onclick="addComment(${postId})" style="margin-top: 10px;">发表评论</button>
                        </div>
                    ` : '<p>请先登录后发表评论</p>'}
                `;
            } catch (error) {
                document.getElementById('comments-container').innerHTML = '<p>加载评论失败: ' + error.message + '</p>';
            }
        }

        async function addComment(postId) {
            if (!currentUser) {
                alert('请先登录');
                return;
            }
            
            const content = document.getElementById(`new-comment-${postId}`).value;
            if (!content.trim()) {
                alert('请输入评论内容');
                return;
            }
            
            try {
                const response = await fetch(`/api/comments/post/${postId}`, {
                    method: 'POST',
                    headers: { 
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${authToken}`
                    },
                    body: JSON.stringify({ 
                        content,
                        user_id: currentUser.id
                    })
                });
                
                const data = await response.json();
                
                if (response.ok) {
                    alert('评论发布成功！');
                    showComments(postId); // 重新加载评论
                } else {
                    alert('评论发布失败: ' + data.error);
                }
            } catch (error) {
                alert('评论请求失败: ' + error.message);
            }
        }
    </script>
</body>
</html>
EOF
```

#### 5.10 系统部署和验证

**步骤9: 一键部署脚本**
```bash
# 创建部署脚本
cat > deploy-microservices.sh << 'EOF'
#!/bin/bash

echo "🚀 启动微服务博客系统..."

# 检查必要的文件
if [[ ! -f "docker-compose.microservices.yml" ]]; then
    echo "❌ 未找到 docker-compose.microservices.yml 文件"
    exit 1
fi

# 停止可能运行的容器
echo "📦 清理现有容器..."
docker-compose -f docker-compose.microservices.yml down

# 构建和启动所有服务
echo "🔨 构建并启动微服务..."
docker-compose -f docker-compose.microservices.yml up --build -d

# 等待服务启动
echo "⏳ 等待服务启动完成..."
sleep 15

# 健康检查
echo "🔍 检查服务状态..."
docker-compose -f docker-compose.microservices.yml ps

echo ""
echo "✅ 微服务博客系统部署完成！"
echo ""
echo "📋 访问地址:"
echo "   🌐 博客主页: http://192.168.14.201:8086"
echo "   💾 数据库管理: http://192.168.14.201:8083"
echo "   📊 服务监控: http://192.168.14.201:8086"
echo ""
echo "🧪 测试命令:"
echo "   curl http://192.168.14.201:8086/api/health"
echo "   curl http://192.168.14.201:8086/api/users/health" 
echo "   curl http://192.168.14.201:8086/api/posts/"
echo ""
EOF

chmod +x deploy-microservices.sh
```

**步骤10: 系统验证**
```bash
# 运行部署脚本
./deploy-microservices.sh

# 等待服务完全启动
sleep 20

# 验证各个微服务
echo "🔍 验证微服务健康状态..."

curl -s http://localhost:8086/api/users/health | jq '.'
curl -s http://localhost:8086/api/posts/health | jq '.'  
curl -s http://localhost:8086/api/comments/health | jq '.'

# 测试用户注册和登录
echo "🧪 测试用户功能..."
curl -X POST http://localhost:8086/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@blog.com","password":"test123","display_name":"测试用户"}'

# 测试文章发布
echo "📝 测试文章发布..."
curl -X POST http://localhost:8086/api/posts/ \
  -H "Content-Type: application/json" \
  -d '{"title":"微服务架构测试文章","content":"这是一篇通过微服务架构发布的文章。","author":"测试用户","author_id":1}'

# 获取文章列表
echo "📚 获取文章列表..."
curl -s http://localhost:8086/api/posts/ | jq '.'
```

### 🎯 Module 5 项目验收与成果总结

#### 学习成果验收

**✅ 核心技术掌握**
1. **微服务架构设计** - 成功将单体应用拆分为3个独立微服务
2. **API网关模式** - 实现统一入口和服务路由转发  
3. **渐进式重构** - 在不破坏现有功能基础上升级架构
4. **容器编排进阶** - 掌握复杂场景下的Docker Compose配置

**✅ 功能验收清单**

**基础功能保持兼容** (复用Module 4)：
- [ ] 文章发布和列表查看
- [ ] 数据库数据持久化  
- [ ] 缓存系统正常工作
- [ ] 管理界面访问正常
- [ ] 服务状态监控面板

**新增微服务功能**：
- [ ] 用户注册和登录系统
- [ ] JWT认证和会话管理
- [ ] 文章作者关联功能
- [ ] 评论发布和显示系统
- [ ] API网关路由和负载分发

**架构升级验证**：
- [ ] 3个微服务独立运行
- [ ] 服务间HTTP通信正常
- [ ] 数据库表结构正确扩展
- [ ] 服务健康检查机制
- [ ] 容错和故障隔离

#### 💼 用户体验验证

**访问地址测试**：
```bash
# 主应用界面
curl http://192.168.14.201:8086

# 微服务健康检查
curl http://192.168.14.201:8086/api/users/health
curl http://192.168.14.201:8086/api/posts/health  
curl http://192.168.14.201:8086/api/comments/health

# 数据库管理
curl http://192.168.14.201:8083
```

**功能完整性测试**：
1. **用户系统测试**
   - 注册新用户账号
   - 用户登录获取Token
   - 查看用户个人资料

2. **文章系统测试**
   - 选择作者发布文章
   - 文章列表正确显示
   - 作者信息正确关联

3. **评论系统测试**
   - 登录用户发布评论
   - 评论列表实时更新
   - 评论时间正确显示

4. **API网关测试**
   - 不同服务路由正确
   - CORS跨域正常处理
   - 错误处理和响应

#### 📊 性能和可靠性指标

**服务性能**：
- API响应时间 < 200ms
- 页面加载时间 < 3秒
- 并发用户支持 > 10个
- 内存使用 < 1GB总计

**可靠性指标**：
- 服务可用性 > 99%
- 数据一致性 100%
- 故障恢复时间 < 30秒
- 零数据丢失

#### 🔧 故障排除指南

**常见问题和解决方案**：

1. **服务无法启动**
   ```bash
   # 查看服务日志
   docker-compose -f docker-compose.microservices.yml logs user-service
   
   # 检查端口冲突
   netstat -tlnp | grep 8086
   ```

2. **数据库连接失败**
   ```bash
   # 检查数据库状态
   docker-compose -f docker-compose.microservices.yml exec database mysql -u bloguser -p
   
   # 验证数据库初始化
   docker-compose -f docker-compose.microservices.yml logs database
   ```

3. **API网关路由问题**
   ```bash
   # 检查nginx配置
   docker-compose -f docker-compose.microservices.yml exec api-gateway nginx -t
   
   # 查看代理日志
   docker-compose -f docker-compose.microservices.yml logs api-gateway
   ```

4. **服务间通信异常**
   ```bash
   # 网络连通性测试
   docker-compose -f docker-compose.microservices.yml exec user-service ping post-service
   
   # 服务发现验证
   docker-compose -f docker-compose.microservices.yml exec user-service nslookup post-service
   ```

#### 🚀 扩展学习建议

**完成Module 5后的进阶方向**：

1. **服务治理优化**
   - 实现服务注册与发现
   - 添加断路器模式
   - 配置重试和超时策略

2. **监控和可观测性**
   - 集成应用性能监控
   - 实现分布式链路追踪
   - 添加业务指标收集

3. **安全性增强**
   - OAuth2.0认证集成
   - API访问速率限制
   - 数据加密和脱敏

4. **DevOps实践**
   - CI/CD流水线搭建
   - 自动化测试集成
   - 蓝绿部署策略

#### 🎯 与Module 4的对比总结

| 方面 | Module 4 (单体架构) | Module 5 (微服务架构) |
|------|-------------------|---------------------|
| **服务数量** | 1个后端服务 | 3个微服务 + API网关 |
| **功能复杂度** | 基础博客功能 | 用户认证 + 评论系统 |
| **代码复用率** | N/A | >70%复用现有代码 |
| **扩展性** | 整体扩展 | 单服务独立扩展 |
| **故障隔离** | 单点故障 | 服务级故障隔离 |
| **开发复杂度** | 简单直接 | 中等复杂度 |
| **运维复杂度** | 低 | 中等 |
| **学习价值** | 容器基础 | 微服务架构设计 |

**🤖 AI辅助提示**: 使用GitHub Copilot可以快速生成微服务API接口、数据库查询语句和前端交互代码，显著提升开发效率。

---

## 📖 Module 6: 生产级优化与项目整合

### 🎯 学习目标
- 基于Module 5微服务系统进行生产级优化
- 实现完整的监控、日志和运维体系
- 掌握高可用部署和性能调优技术
- 完成从开发到生产的完整交付链路

### 📚 理论学习 (2小时)

#### 6.1 生产环境架构演进

**基于Module 5的架构升级路径**:
```
Module 5: 微服务基础架构
┌─────────────────────────────────────────────────────────────┐
│ Frontend → API Gateway → [User Service]   → Shared Database │
│ (React)   (Nginx路由)    [Post Service]   → + Redis Cache   │
│                         [Comment Service] → (MySQL)         │
└─────────────────────────────────────────────────────────────┘

Module 6: 生产级架构升级
┌─────────────────────────────────────────────────────────────────────────┐
│ Load Balancer → API Gateway → [User Service × 2]   → Database Cluster   │
│ (Nginx/HAProxy) (Enhanced)    [Post Service × 3]   → (Master/Slave)     │
│       ↓                       [Comment Service × 2] → Redis Cluster     │
│  Monitoring Stack             [Media Service]       → File Storage      │
│  (Prometheus/Grafana)         └── Health Checks ────┘  (Minio/S3)       │
│       ↓                                                                 │
│  Logging & Alerting                                                     │
│  (ELK Stack / Loki)                                                     │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 6.2 生产环境核心要素

**✅ 可靠性保障**:
```yaml
生产级要求清单:
  服务可用性: 99.9% (年停机时间 < 8.76小时)
  故障恢复: RTO < 15分钟, RPO < 5分钟
  数据备份: 自动化日备份 + 异地容灾
  监控覆盖: 系统指标 + 应用指标 + 业务指标

技术实现框架:
  高可用架构: 负载均衡 + 服务冗余 + 故障转移
  数据层优化: 主从分离 + 连接池 + 缓存策略
  监控体系: Prometheus + Grafana + 告警规则
  日志管理: 集中化收集 + 结构化存储 + 智能分析
  
最佳实践原则:
  - 无状态服务设计，支持水平扩展
  - 优雅降级和熔断机制
  - 自动化运维和自愈能力
  - 完整的可观测性覆盖
  日志管理: 集中收集 + 结构化存储 + 实时告警
  安全防护: 认证授权 + 网络隔离 + 数据加密
```

**✅ 性能优化目标**:
```yaml
响应时间:
  API平均响应: < 100ms
  页面加载时间: < 2秒
  数据库查询: < 50ms
  
并发能力:
  单服务QPS: > 1000
  系统总QPS: > 5000
  并发用户: > 500
  
资源利用:
  CPU使用率: 60-80%
  内存使用率: < 80%
  磁盘I/O: < 80%
```

#### 6.3 微服务生产化改造策略

**基于现有代码的渐进式升级**:
```javascript
// 复用Module 5的三个微服务，添加生产级特性
blog-microservices-system/
├── services/                   # 现有微服务增强
│   ├── user-service/           # ✅ 已有基础
│   │   ├── app.js             # 增加: 性能监控、限流、缓存
│   │   ├── health.js          # 新增: 深度健康检查
│   │   └── metrics.js         # 新增: Prometheus指标
│   │
│   ├── post-service/           # ✅ 已有基础  
│   │   ├── app.js             # 增加: 搜索优化、缓存策略
│   │   ├── search.js          # 新增: Elasticsearch集成
│   │   └── cache.js           # 新增: 多级缓存
│   │
│   ├── comment-service/        # ✅ 已有基础
│   │   ├── app.js             # 增加: 反垃圾、通知
│   │   ├── moderation.js      # 新增: 智能审核
│   │   └── notification.js    # 新增: 邮件通知
│   │
│   └── media-service/          # 🆕 新增服务
│       ├── app.js             # 文件上传、处理、CDN
│       ├── upload.js          # 多种存储后端支持
│       └── image.js           # 图片压缩、格式转换
│
├── infrastructure/             # 🆕 基础设施配置
│   ├── monitoring/            # Prometheus + Grafana
│   ├── logging/               # ELK Stack / Loki
│   ├── secrets/               # 密钥管理
│   └── backup/                # 备份恢复脚本
│
└── deployment/                 # 🆕 部署配置
    ├── docker-compose.prod.yml    # 生产环境配置
    ├── docker-compose.staging.yml # 测试环境配置
    ├── nginx.prod.conf            # 负载均衡配置
    └── ci-cd/                     # 自动化部署
```

### 🛠️ 实践操作 (8小时)

#### 6.4 第一阶段: 现有系统生产化配置 (2小时)

**实践框架概览**:

**步骤1: 生产环境目录结构设计**
```
项目结构优化思路:
└── blog-production-system/
    ├── deployment/           # 部署配置分离
    │   ├── production/      # 生产环境配置
    │   └── staging/         # 测试环境配置
    ├── infrastructure/      # 基础设施配置
    │   ├── monitoring/      # 监控配置
    │   ├── logging/        # 日志配置
    │   └── networking/     # 网络配置
    └── scripts/            # 运维脚本
        ├── deployment/     # 部署脚本
        ├── maintenance/    # 维护脚本
        └── monitoring/     # 监控脚本
```

**步骤2: 生产级Docker Compose架构设计**
```yaml
生产环境配置要点:
  服务配置优化:
    - 资源限制: CPU/内存配置
    - 健康检查: 服务可用性监控
    - 重启策略: 故障自愈机制
    - 日志管理: 集中化日志配置
  
  网络架构设计:
    - 前端网络: 对外服务暴露
    - 后端网络: 内部服务通信
    - 监控网络: 监控数据收集
  
  存储方案:
    - 数据持久化: 数据库和缓存存储
    - 日志持久化: 应用日志存储
    - 配置持久化: 配置文件管理
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - frontend-network
      - backend-network

  # 用户服务 - 高可用配置
  user-service:
    build:
      context: ./services/user-service
      dockerfile: Dockerfile.prod
    environment:
      - NODE_ENV=production
      - DB_HOST=database-master
      - DB_NAME=blog_system
      - DB_USER=bloguser
      - DB_PASSWORD=${DB_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_HOST=redis-cluster
      - LOG_LEVEL=info
      - METRICS_PORT=9090
    depends_on:
      - database-master
      - redis-cluster
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    networks:
      - backend-network

  # 文章服务 - 搜索优化
  post-service:
    build:
      context: ./services/post-service
      dockerfile: Dockerfile.prod
    environment:
      - NODE_ENV=production
      - DB_HOST=database-master
      - DB_SLAVE_HOST=database-slave
      - DB_NAME=blog_system
      - DB_USER=bloguser
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=redis-cluster
      - ELASTICSEARCH_HOST=elasticsearch
      - CACHE_TTL=3600
      - LOG_LEVEL=info
    depends_on:
      - database-master
      - database-slave
      - redis-cluster
      - elasticsearch
    restart: unless-stopped
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.5'
          memory: 1.5G
        reservations:
          cpus: '0.75'
          memory: 768M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3002/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    networks:
      - backend-network

  # 评论服务 - 反垃圾增强
  comment-service:
    build:
      context: ./services/comment-service
      dockerfile: Dockerfile.prod
    environment:
      - NODE_ENV=production
      - DB_HOST=database-master
      - DB_NAME=blog_system
      - DB_USER=bloguser
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=redis-cluster
      - SMTP_HOST=${SMTP_HOST}
      - SMTP_USER=${SMTP_USER}
      - SMTP_PASS=${SMTP_PASS}
      - LOG_LEVEL=info
    depends_on:
      - database-master
      - redis-cluster
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3003/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    networks:
      - backend-network

  # 新增媒体服务
  media-service:
    build:
      context: ./services/media-service
      dockerfile: Dockerfile
    environment:
      - NODE_ENV=production
      - MINIO_ENDPOINT=minio
      - MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
      - MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
      - REDIS_HOST=redis-cluster
      - MAX_FILE_SIZE=50MB
      - ALLOWED_TYPES=image/jpeg,image/png,image/gif,image/webp
    depends_on:
      - minio
      - redis-cluster
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    volumes:
      - media_temp:/tmp/uploads
    networks:
      - backend-network

  # 数据库主节点
  database-master:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=blog_system
      - MYSQL_USER=bloguser
      - MYSQL_PASSWORD=${DB_PASSWORD}
      - MYSQL_BINLOG_FORMAT=ROW
      - MYSQL_SERVER_ID=1
    volumes:
      - mysql_master_data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
      - ./infrastructure/mysql/master.cnf:/etc/mysql/conf.d/mysql.cnf
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
    networks:
      - backend-network

  # 数据库从节点
  database-slave:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=blog_system
      - MYSQL_USER=bloguser
      - MYSQL_PASSWORD=${DB_PASSWORD}
      - MYSQL_MASTER_HOST=database-master
      - MYSQL_SERVER_ID=2
    volumes:
      - mysql_slave_data:/var/lib/mysql
      - ./infrastructure/mysql/slave.cnf:/etc/mysql/conf.d/mysql.cnf
    depends_on:
      - database-master
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 1.5G
        reservations:
          cpus: '0.75'
          memory: 768M
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - backend-network

  # Redis集群
  redis-cluster:
    image: redis:7-alpine
    command: redis-server /etc/redis/redis.conf
    volumes:
      - redis_data:/data
      - ./infrastructure/redis/redis.conf:/etc/redis/redis.conf
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - backend-network

  # Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9200/_cluster/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - backend-network

  # Minio对象存储
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - backend-network

volumes:
  mysql_master_data:
  mysql_slave_data:
  redis_data:
  elasticsearch_data:
  minio_data:
  media_temp:
  nginx_logs:

networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge
    internal: true

secrets:
  db_password:
    external: true
  jwt_secret:
    external: true
EOF
```

**步骤3: 生产级Nginx配置**
```bash
# 创建生产级nginx配置
mkdir -p infrastructure/nginx
cat > infrastructure/nginx/nginx.prod.conf << 'EOF'
# 生产级Nginx配置
events {
    worker_connections 2048;
    use epoll;
    multi_accept on;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'rt=$request_time uct="$upstream_connect_time" '
                    'uht="$upstream_header_time" urt="$upstream_response_time" '
                    'service="$upstream_addr"';
    
    access_log /var/log/nginx/access.log main;
    error_log  /var/log/nginx/error.log warn;
    
    # 性能优化
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 50M;
    
    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/atom+xml image/svg+xml;
    
    # 安全头
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # 限流配置
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;
    
    # 上游服务定义 - 负载均衡
    upstream user_service {
        least_conn;
        server user-service:3001 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream post_service {
        least_conn;
        server post-service:3002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream comment_service {
        least_conn;
        server comment-service:3003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream media_service {
        least_conn;
        server media-service:3004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # 主服务器配置
    server {
        listen 80;
        server_name localhost;
        
        # 静态文件缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            root /usr/share/nginx/html;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # 静态文件服务
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
            
            # 缓存配置
            location ~* \.html$ {
                expires 1h;
                add_header Cache-Control "public";
            }
        }
        
        # 健康检查端点
        location /health {
            access_log off;
            return 200 '{"status":"healthy","timestamp":"$time_iso8601"}';
            add_header Content-Type application/json;
        }
        
        # API路由 - 用户认证服务
        location /api/users/ {
            limit_req zone=auth burst=20 nodelay;
            
            proxy_pass http://user_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 超时配置
            proxy_connect_timeout 5s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # 错误处理
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            proxy_next_upstream_timeout 10s;
        }
        
        # API路由 - 文章服务
        location /api/posts/ {
            limit_req zone=api burst=50 nodelay;
            
            proxy_pass http://post_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 缓存配置 (GET请求)
            proxy_cache_methods GET HEAD;
            proxy_cache_valid 200 302 5m;
            proxy_cache_valid 404 1m;
            
            proxy_connect_timeout 5s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        }
        
        # API路由 - 评论服务
        location /api/comments/ {
            limit_req zone=api burst=30 nodelay;
            
            proxy_pass http://comment_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 5s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        }
        
        # API路由 - 媒体服务
        location /api/media/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://media_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 文件上传超时
            proxy_connect_timeout 10s;
            proxy_send_timeout 300s;
            proxy_read_timeout 300s;
            
            client_max_body_size 50M;
        }
        
        # Nginx状态监控
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;
        }
    }
    
    # HTTPS配置 (生产环境)
    # server {
    #     listen 443 ssl http2;
    #     server_name your-domain.com;
    #     
    #     ssl_certificate /etc/nginx/ssl/cert.pem;
    #     ssl_certificate_key /etc/nginx/ssl/key.pem;
    #     ssl_protocols TLSv1.2 TLSv1.3;
    #     ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    #     ssl_prefer_server_ciphers off;
    #     
    #     # 其他配置同上...
    # }
}
EOF
```

#### 6.5 第二阶段: 监控和运维工具集成 (4小时)

**监控体系设计思路**:

**步骤1: 监控架构规划**
```yaml
监控层级设计:
  基础设施监控:
    - 系统资源: CPU、内存、磁盘、网络
    - 容器状态: 运行状态、资源使用、重启次数
    - 网络连通性: 服务间通信质量
  
  应用监控:
    - 服务可用性: 健康检查、响应时间
    - 业务指标: 用户访问、数据处理量
    - 错误统计: 异常率、失败请求数
  
  数据存储监控:
    - 数据库性能: 连接数、查询时间、锁等待
    - 缓存效率: 命中率、内存使用、网络IO
    - 存储健康: 磁盘使用、备份状态
```

**步骤2: Prometheus配置策略**
```yaml
数据收集配置原则:
  采集频率优化:
    - 关键指标: 5-15秒间隔
    - 一般指标: 30-60秒间隔
    - 系统指标: 1-5分钟间隔
  
  数据源分类:
    - 应用指标: 各微服务暴露的metrics端点
    - 系统指标: Node Exporter收集系统信息
    - 中间件指标: 专用Exporter收集数据库、缓存等指标
  
  存储策略:
    - 短期存储: 15天高频数据用于告警
    - 长期存储: 6个月聚合数据用于分析
    - 数据压缩: 定期清理和归档历史数据

  # Minio指标
  - job_name: 'minio'
    static_configs:
      - targets: ['minio:9000']
    metrics_path: /minio/prometheus/metrics
EOF

# 创建告警规则
mkdir -p infrastructure/prometheus/rules
cat > infrastructure/prometheus/rules/blog-system.yml << 'EOF'
groups:
  - name: blog-system-alerts
    rules:
      # 服务可用性告警
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "服务 {{ $labels.job }} 不可用"
          description: "服务 {{ $labels.job }} 已经宕机超过1分钟"

      # 高响应时间告警
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "{{ $labels.job }} 响应时间过高"
          description: "95%的请求响应时间超过500ms，当前值: {{ $value }}s"

      # CPU使用率告警
      - alert: HighCPUUsage
        expr: (100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU使用率过高"
          description: "实例 {{ $labels.instance }} CPU使用率已超过80%，当前值: {{ $value }}%"

      # 内存使用率告警
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "内存使用率过高"
          description: "实例 {{ $labels.instance }} 内存使用率已超过85%，当前值: {{ $value }}%"

      # 磁盘空间告警
      - alert: HighDiskUsage
        expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "磁盘空间不足"
          description: "实例 {{ $labels.instance }} 磁盘使用率已超过90%"

      # 数据库连接数告警
      - alert: MySQLHighConnections
        expr: mysql_global_status_threads_connected / mysql_global_variables_max_connections * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "MySQL连接数过高"
          description: "MySQL连接数使用率已超过80%"

      # Redis内存使用告警
      - alert: RedisHighMemoryUsage
        expr: redis_memory_used_bytes / redis_memory_max_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis内存使用率过高"
          description: "Redis内存使用率已超过80%"
EOF
```

**步骤3: Grafana可视化配置策略**
```yaml
可视化设计原则:
  仪表板分层设计:
    - 系统总览: 整体服务状态、关键指标汇总
    - 服务详情: 单个服务的详细指标和趋势
    - 基础设施: 系统资源、网络、存储状态
    - 业务指标: 用户活动、业务流程监控
  
  图表类型选择:
    - 实时状态: Stat面板显示当前值和状态
    - 趋势分析: Time Series展示历史变化
    - 分布统计: Histogram显示数据分布
    - 告警展示: Alert List集中显示告警信息
  
  数据源配置:
    - Prometheus: 指标数据主要来源
    - Loki: 日志查询和分析 
    - Jaeger: 分布式链路追踪
    - MySQL: 业务数据直接查询
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            },
            "mappings": [
              {"type": "value", "value": "0", "text": "DOWN"},
              {"type": "value", "value": "1", "text": "UP"}
            ]
          }
        }
      },
      {
        "id": 2,
        "title": "QPS (每秒请求数)",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (service)",
            "legendFormat": "{{ service }}"
          }
        ]
      },
      {
        "id": 3,
        "title": "响应时间",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          }
        ]
      },
      {
        "id": 4,
        "title": "系统资源使用率",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU使用率"
          },
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "内存使用率"
          }
        ]
      },
      {
        "id": 5,
        "title": "数据库性能",
        "type": "graph",
        "targets": [
          {
            "expr": "mysql_global_status_queries",
            "legendFormat": "总查询数"
          },
          {
            "expr": "mysql_global_status_slow_queries",
            "legendFormat": "慢查询数"
          }
        ]
      }
    ]
  }
}
EOF
```

**步骤6: 日志管理配置**
```bash
# 创建日志配置目录
mkdir -p infrastructure/logging

# ELK Stack配置 (简化版)
cat > infrastructure/logging/docker-compose.logging.yml << 'EOF'
version: '3.8'

services:
  # Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    volumes:
      - elasticsearch_logs:/usr/share/elasticsearch/data
    networks:
      - logging-network

  # Logstash
  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml
    environment:
      - "LS_JAVA_OPTS=-Xmx512m -Xms512m"
    depends_on:
      - elasticsearch
    networks:
      - logging-network

  # Kibana
  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    networks:
      - logging-network

  # Filebeat (日志收集)
  filebeat:
    image: docker.elastic.co/beats/filebeat:8.10.0
    user: root
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - ELASTICSEARCH_HOST=elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - logging-network

volumes:
  elasticsearch_logs:

networks:
  logging-network:
    driver: bridge
EOF

**日志收集策略设计:**
```yaml
日志架构设计:
  收集层: 
    - Filebeat: 容器日志自动发现和采集
    - 应用程序结构化日志输出
    - 系统指标和事件收集
  
  处理层:
    - Logstash: 日志解析、格式化、过滤
    - 数据增强和关联分析
    - 敏感信息脱敏处理
  
  存储层:
    - Elasticsearch: 日志索引和搜索
    - 按时间和服务分片存储
    - 生命周期管理策略
  
  分析层:
    - Kibana: 日志查询和可视化
    - 告警规则和异常检测
    - 业务指标分析面板
```

#### 6.6 第三阶段: 功能完善和用户体验优化 (4小时)

**步骤4: 媒体服务架构设计**
```yaml
媒体处理架构:
  上传处理:
    - 文件类型验证和安全检查
    - 多尺寸图片自动生成策略
    - 并发上传和限流控制
    - 上传进度和状态管理
  
  存储策略:
    - 对象存储(MinIO/S3)分层存储
    - CDN加速和缓存策略
    - 数据备份和冗余方案
    - 生命周期管理自动化
  
  处理流水线:
    - 图片压缩和格式转换
    - 视频转码和流式处理 
    - 文档预览和缩略图生成
    - 异步任务队列管理
  
  服务集成:
    - Redis缓存热点资源
    - 数据库存储元数据信息
    - 消息队列处理异步任务
    - 监控和告警系统集成

// Redis客户端配置
let redisClient;
(async () => {
  try {
    redisClient = redis.createClient({
      socket: {
        host: process.env.REDIS_HOST || 'redis-cluster',
        port: 6379
      }
    });
    
    redisClient.on('error', (err) => console.log('Redis Client Error', err));
    await redisClient.connect();
    console.log('✅ Media Service: Redis connected successfully');
  } catch (error) {
    console.log('❌ Media Service: Redis connection failed:', error.message);
  }
})();

// 确保存储桶存在
const BUCKET_NAME = 'blog-media';
(async () => {
  try {
    const exists = await minioClient.bucketExists(BUCKET_NAME);
    if (!exists) {
      await minioClient.makeBucket(BUCKET_NAME, 'us-east-1');
      console.log(`✅ Created bucket: ${BUCKET_NAME}`);
    }
  } catch (error) {
    console.error('❌ Bucket creation error:', error);
  }
})();

// Multer配置 - 内存存储
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE || '50') * 1024 * 1024, // 默认50MB
    files: 5 // 最多5个文件
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = (process.env.ALLOWED_TYPES || 'image/jpeg,image/png,image/gif,image/webp').split(',');
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`不支持的文件类型: ${file.mimetype}`), false);
    }
  }
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    service: 'media-service',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    minio: 'connected',
    redis: redisClient?.isOpen ? 'connected' : 'disconnected'
  });
});

// 图片上传接口
app.post('/upload', uploadLimiter, upload.array('files', 5), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: '请选择要上传的文件' });
    }

    const uploadPromises = req.files.map(async (file) => {
      // 生成唯一文件名
      const timestamp = Date.now();
      const randomStr = Math.random().toString(36).substring(2, 15);
      const fileExtension = path.extname(file.originalname);
      const fileName = `${timestamp}_${randomStr}${fileExtension}`;

      // 图片压缩和优化
      let processedBuffer;
      if (file.mimetype.startsWith('image/')) {
        processedBuffer = await sharp(file.buffer)
          .resize(1920, 1080, { 
            fit: 'inside', 
            withoutEnlargement: true 
          })
          .jpeg({ 
            quality: 85, 
            progressive: true 
          })
          .toBuffer();
      } else {
        processedBuffer = file.buffer;
      }

      // 上传到Minio
      const objectName = `uploads/${new Date().getFullYear()}/${new Date().getMonth() + 1}/${fileName}`;
      await minioClient.putObject(BUCKET_NAME, objectName, processedBuffer, {
        'Content-Type': file.mimetype,
        'Content-Length': processedBuffer.length,
        'X-Original-Name': file.originalname
      });

      // 生成访问URL
      const fileUrl = `/api/media/file/${objectName}`;

      // 缓存文件信息
      const fileInfo = {
        originalName: file.originalname,
        fileName: fileName,
        objectName: objectName,
        size: processedBuffer.length,
        mimetype: file.mimetype,
        uploadTime: new Date().toISOString(),
        url: fileUrl
      };

      if (redisClient?.isOpen) {
        await redisClient.setEx(`file:${fileName}`, 86400, JSON.stringify(fileInfo)); // 缓存24小时
      }

      return fileInfo;
    });

    const uploadResults = await Promise.all(uploadPromises);

    res.json({
      message: '文件上传成功',
      files: uploadResults
    });

  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ 
      error: '文件上传失败', 
      details: error.message 
    });
  }
});

// 文件访问接口
app.get('/file/*', async (req, res) => {
  try {
    const objectName = req.params[0];
    
    // 检查缓存
    if (redisClient?.isOpen) {
      const cached = await redisClient.get(`file_content:${objectName}`);
      if (cached) {
        const { buffer, contentType } = JSON.parse(cached);
        res.set('Content-Type', contentType);
        res.set('Cache-Control', 'public, max-age=86400'); // 缓存1天
        return res.send(Buffer.from(buffer, 'base64'));
      }
    }

    // 从Minio获取文件
    const stream = await minioClient.getObject(BUCKET_NAME, objectName);
    const chunks = [];
    
    stream.on('data', (chunk) => chunks.push(chunk));
    stream.on('end', async () => {
      const buffer = Buffer.concat(chunks);
      
      // 获取文件信息
      const stat = await minioClient.statObject(BUCKET_NAME, objectName);
      const contentType = stat.metaData['content-type'] || 'application/octet-stream';
      
      // 缓存文件内容
      if (redisClient?.isOpen && buffer.length < 1024 * 1024) { // 只缓存小于1MB的文件
        await redisClient.setEx(`file_content:${objectName}`, 3600, JSON.stringify({
          buffer: buffer.toString('base64'),
          contentType
        }));
      }
      
      res.set('Content-Type', contentType);
      res.set('Cache-Control', 'public, max-age=86400');
      res.send(buffer);
    });
    
    stream.on('error', (error) => {
      console.error('Stream error:', error);
      res.status(404).json({ error: '文件不存在' });
    });

  } catch (error) {
    console.error('File access error:', error);
    res.status(404).json({ error: '文件不存在' });
  }
});

// 文件删除接口
app.delete('/file/:fileName', async (req, res) => {
  try {
    const { fileName } = req.params;
    
    // 从缓存获取文件信息
    let fileInfo;
    if (redisClient?.isOpen) {
      const cached = await redisClient.get(`file:${fileName}`);
      if (cached) {
        fileInfo = JSON.parse(cached);
      }
    }
    
    if (!fileInfo) {
      return res.status(404).json({ error: '文件不存在' });
    }
    
    // 从Minio删除文件
    await minioClient.removeObject(BUCKET_NAME, fileInfo.objectName);
    
    // 清除缓存
    if (redisClient?.isOpen) {
      await redisClient.del(`file:${fileName}`);
      await redisClient.del(`file_content:${fileInfo.objectName}`);
    }
    
    res.json({ message: '文件删除成功' });
    
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({ error: '文件删除失败' });
  }
});

// 文件列表接口
app.get('/files', async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    
    // 这里简化实现，实际生产中应该用数据库存储文件元信息
    const objects = [];
    const stream = minioClient.listObjects(BUCKET_NAME, 'uploads/', true);
    
    stream.on('data', (obj) => objects.push(obj));
    stream.on('end', () => {
      const startIndex = (page - 1) * limit;
      const endIndex = page * limit;
      const paginatedObjects = objects.slice(startIndex, endIndex);
      
      res.json({
        files: paginatedObjects.map(obj => ({
          name: obj.name,
          size: obj.size,
          lastModified: obj.lastModified,
          url: `/api/media/file/${obj.name}`
        })),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: objects.length,
          totalPages: Math.ceil(objects.length / limit)
        }
      });
    });
    
    stream.on('error', (error) => {
      console.error('List error:', error);
      res.status(500).json({ error: '获取文件列表失败' });
    });
    
  } catch (error) {
    console.error('Files list error:', error);
    res.status(500).json({ error: '获取文件列表失败' });
  }
});

// 错误处理中间件
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: '文件大小超出限制' });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: '文件数量超出限制' });
    }
  }
  
  console.error('Unhandled error:', error);
  res.status(500).json({ error: '服务器内部错误' });
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Media Service running on port ${port}`);
});
EOF

# 媒体服务Dockerfile
cat > services/media-service/Dockerfile << 'EOF'
FROM node:18-alpine

# 安装系统依赖 (Sharp需要)
RUN apk add --no-cache \
    libc6-compat \
    vips-dev \
    build-base \
    curl

WORKDIR /app

# 复制package文件
COPY package*.json ./
RUN npm install --production

# 复制应用代码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 创建临时目录
RUN mkdir -p /tmp/uploads && \
    chown -R nodejs:nodejs /app /tmp/uploads

USER nodejs

EXPOSE 3004

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3004/health || exit 1

CMD ["npm", "start"]
EOF
```

**步骤8: 前端功能增强**
```bash
# 基于现有前端界面，添加文件上传功能
# 备份现有前端
cp frontend/index.html frontend/index.html.module5-backup

# 创建增强版前端 (在现有基础上添加媒体上传功能)
cat >> frontend/index.html << 'EOF'

        <!-- 媒体管理面板 -->
        <div id="media-section" class="auth-section">
            <div class="panel">
                <div class="panel-header">
                    <span>🖼️ 媒体文件管理</span>
                </div>
                <div class="panel-content">
                    <div class="form-group">
                        <label>选择文件上传:</label>
                        <input type="file" id="file-input" multiple accept="image/*" 
                               style="margin-bottom: 15px;">
                        <button onclick="uploadFiles()" id="upload-btn">上传文件</button>
                    </div>
                    
                    <div id="upload-progress" class="hidden">
                        <div class="progress-bar">
                            <div class="progress-fill" id="progress-fill"></div>
                        </div>
                        <div class="progress-text" id="progress-text">上传中...</div>
                    </div>
                    
                    <div id="upload-results"></div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <span>📁 文件列表</span>
                    <button class="refresh-btn" onclick="loadMediaFiles()">刷新列表</button>
                </div>
                <div class="panel-content">
                    <div id="media-container">正在加载文件...</div>
                </div>
            </div>
        </div>

    <!-- 在现有JavaScript代码后添加 -->
    <script>
        // 媒体文件管理功能
        async function uploadFiles() {
            const fileInput = document.getElementById('file-input');
            const files = fileInput.files;
            
            if (files.length === 0) {
                alert('请选择要上传的文件');
                return;
            }
            
            const formData = new FormData();
            for (let i = 0; i < files.length; i++) {
                formData.append('files', files[i]);
            }
            
            try {
                document.getElementById('upload-progress').classList.remove('hidden');
                document.getElementById('upload-btn').disabled = true;
                
                const xhr = new XMLHttpRequest();
                
                // 上传进度
                xhr.upload.onprogress = function(e) {
                    if (e.lengthComputable) {
                        const percentComplete = (e.loaded / e.total) * 100;
                        document.getElementById('progress-fill').style.width = percentComplete + '%';
                        document.getElementById('progress-text').textContent = `上传中... ${Math.round(percentComplete)}%`;
                    }
                };
                
                xhr.onload = function() {
                    document.getElementById('upload-progress').classList.add('hidden');
                    document.getElementById('upload-btn').disabled = false;
                    
                    if (xhr.status === 200) {
                        const result = JSON.parse(xhr.responseText);
                        displayUploadResults(result.files);
                        loadMediaFiles(); // 刷新文件列表
                        fileInput.value = ''; // 清空文件选择
                    } else {
                        const error = JSON.parse(xhr.responseText);
                        alert('上传失败: ' + error.error);
                    }
                };
                
                xhr.onerror = function() {
                    document.getElementById('upload-progress').classList.add('hidden');
                    document.getElementById('upload-btn').disabled = false;
                    alert('上传失败: 网络错误');
                };
                
                xhr.open('POST', '/api/media/upload');
                xhr.send(formData);
                
            } catch (error) {
                document.getElementById('upload-progress').classList.add('hidden');
                document.getElementById('upload-btn').disabled = false;
                alert('上传失败: ' + error.message);
            }
        }
        
        function displayUploadResults(files) {
            const container = document.getElementById('upload-results');
            container.innerHTML = `
                <h4>✅ 上传成功 (${files.length}个文件)</h4>
                ${files.map(file => `
                    <div class="upload-result-item">
                        <strong>${file.originalName}</strong>
                        <div>大小: ${(file.size / 1024 / 1024).toFixed(2)} MB</div>
                        <div>访问地址: <a href="${file.url}" target="_blank">${file.url}</a></div>
                    </div>
                `).join('')}
            `;
        }
        
        async function loadMediaFiles() {
            try {
                const response = await fetch('/api/media/files?limit=10');
                const data = await response.json();
                
                const container = document.getElementById('media-container');
                
                if (data.files.length === 0) {
                    container.innerHTML = '<p>暂无文件</p>';
                    return;
                }
                
                container.innerHTML = `
                    <div class="media-grid">
                        ${data.files.map(file => `
                            <div class="media-item">
                                ${file.name.match(/\.(jpg|jpeg|png|gif|webp)$/i) ? 
                                    `<img src="${file.url}" alt="${file.name}" class="media-preview">` :
                                    `<div class="media-file-icon">📄</div>`
                                }
                                <div class="media-info">
                                    <div class="media-name" title="${file.name}">${file.name.substring(0, 20)}...</div>
                                    <div class="media-size">${(file.size / 1024).toFixed(1)} KB</div>
                                    <div class="media-actions">
                                        <button onclick="copyUrl('${file.url}')" class="btn-small">复制链接</button>
                                        <button onclick="deleteFile('${file.name}')" class="btn-small btn-danger">删除</button>
                                    </div>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                    
                    <div class="pagination">
                        <div>共 ${data.pagination.total} 个文件</div>
                        <div>第 ${data.pagination.page} / ${data.pagination.totalPages} 页</div>
                    </div>
                `;
                
            } catch (error) {
                document.getElementById('media-container').innerHTML = '<p>加载文件列表失败: ' + error.message + '</p>';
            }
        }
        
        function copyUrl(url) {
            navigator.clipboard.writeText(window.location.origin + url).then(() => {
                alert('链接已复制到剪贴板');
            }).catch(() => {
                alert('复制失败，请手动复制: ' + window.location.origin + url);
            });
        }
        
        async function deleteFile(fileName) {
            if (!confirm('确定要删除这个文件吗？')) {
                return;
            }
            
            try {
                const response = await fetch(`/api/media/file/${fileName}`, {
                    method: 'DELETE'
                });
                
                if (response.ok) {
                    alert('文件删除成功');
                    loadMediaFiles(); // 刷新列表
                } else {
                    const error = await response.json();
                    alert('删除失败: ' + error.error);
                }
            } catch (error) {
                alert('删除失败: ' + error.message);
            }
        }
        
        // 在页面初始化时加载媒体文件
        document.addEventListener('DOMContentLoaded', function() {
            // ... 现有初始化代码 ...
            if (currentSection === 'media') {
                loadMediaFiles();
            }
        });
    </script>

    <!-- 添加媒体管理相关样式 -->
    <style>
        .progress-bar {
            width: 100%;
            height: 20px;
            background-color: #f0f0f0;
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 10px;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            width: 0%;
            transition: width 0.3s ease;
        }
        
        .progress-text {
            text-align: center;
            font-size: 0.9em;
            color: #666;
        }
        
        .upload-result-item {
            background: #f8f9fa;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 6px;
            border-left: 4px solid #28a745;
        }
        
        .media-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .media-item {
            background: #f8f9fa;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
        }
        
        .media-item:hover {
            transform: translateY(-2px);
        }
        
        .media-preview {
            width: 100%;
            height: 120px;
            object-fit: cover;
        }
        
        .media-file-icon {
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3em;
            background: #e9ecef;
        }
        
        .media-info {
            padding: 10px;
        }
        
        .media-name {
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 0.9em;
        }
        
        .media-size {
            color: #666;
            font-size: 0.8em;
            margin-bottom: 10px;
        }
        
        .media-actions {
            display: flex;
            gap: 5px;
        }
        
        .pagination {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 6px;
            font-size: 0.9em;
            color: #666;
        }
    </style>
EOF

# 在header-nav中添加媒体管理按钮
sed -i '/<button class="nav-btn" onclick="showSection('"'"'comments'"'"')">评论系统<\/button>/a\                <button class="nav-btn" onclick="showSection('"'"'media'"'"')">媒体管理</button>' frontend/index.html
```

#### 6.7 第四阶段: 生产运维与项目总结 (2小时)

**步骤5: 生产运维最佳实践框架**
```yaml
CI/CD流水线设计:
  代码质量保障:
    - 自动化测试套件执行
    - 代码质量扫描和安全检查
    - 依赖漏洞扫描和更新
    - 多环境测试数据库集成
  
  构建与发布流程:
    - 多阶段容器镜像构建
    - 镜像安全扫描和签名验证
    - 镜像仓库管理和版本控制
    - 自动化标签和元数据管理
  
  部署策略实施:
    - 环境隔离和配置管理
    - 蓝绿部署和金丝雀发布
    - 自动回滚和故障恢复
    - 部署审计和合规检查
  
  运维监控体系:
    - 服务健康检查和告警
    - 性能指标收集和分析
    - 日志聚合和异常检测
    - 容量规划和扩缩容策略

    steps:
    - name: Checkout代码
      uses: actions/checkout@v4

    - name: 设置Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: |
          services/user-service/package-lock.json
          services/post-service/package-lock.json
          services/comment-service/package-lock.json

    - name: 安装依赖并测试用户服务
      run: |
        cd services/user-service
        npm ci
        npm run test
      env:
        NODE_ENV: test
        DB_HOST: localhost
        DB_NAME: blog_test
        DB_USER: root
        DB_PASSWORD: test123
        REDIS_HOST: localhost

    - name: 安装依赖并测试文章服务
      run: |
        cd services/post-service
        npm ci
        npm run test
      env:
        NODE_ENV: test
        DB_HOST: localhost
        DB_NAME: blog_test
        DB_USER: root
        DB_PASSWORD: test123
        REDIS_HOST: localhost

    - name: 安装依赖并测试评论服务
      run: |
        cd services/comment-service
        npm ci
        npm run test
      env:
        NODE_ENV: test
        DB_HOST: localhost
        DB_NAME: blog_test
        DB_USER: root
        DB_PASSWORD: test123

    - name: 代码质量检查
      run: |
        # 安装ESLint
        npm install -g eslint
        
        # 检查所有服务的代码质量
        for service in user-service post-service comment-service; do
          echo "检查 $service 代码质量..."
          cd services/$service
          npx eslint . --ext .js --fix-dry-run
          cd ../..
        done

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    
    strategy:
      matrix:
        service: [user-service, post-service, comment-service, media-service]

    steps:
    - name: Checkout代码
      uses: actions/checkout@v4

    - name: 设置Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: 登录GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.DOCKER_REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: 提取元数据
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_PREFIX }}/${{ matrix.service }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}

    - name: 构建并推送Docker镜像
      uses: docker/build-push-action@v5
      with:
        context: ./services/${{ matrix.service }}
        file: ./services/${{ matrix.service }}/Dockerfile.prod
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        platforms: linux/amd64,linux/arm64

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging

    steps:
    - name: Checkout代码
      uses: actions/checkout@v4

    - name: 部署到测试环境
      run: |
        echo "部署到测试环境..."
        # 这里可以添加具体的部署脚本
        ./scripts/ci-cd/deploy-staging.sh
      env:
        DEPLOY_HOST: ${{ secrets.STAGING_HOST }}
        DEPLOY_USER: ${{ secrets.STAGING_USER }}
        DEPLOY_KEY: ${{ secrets.STAGING_SSH_KEY }}

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production

    steps:
    - name: Checkout代码
      uses: actions/checkout@v4

    - name: 生产环境健康检查
      run: |
        echo "检查生产环境状态..."
        ./scripts/ci-cd/health-check.sh
      env:
        PROD_HOST: ${{ secrets.PRODUCTION_HOST }}

    - name: 蓝绿部署到生产环境
      run: |
        echo "执行蓝绿部署..."
        ./scripts/ci-cd/deploy-production.sh
      env:
        DEPLOY_HOST: ${{ secrets.PRODUCTION_HOST }}
        DEPLOY_USER: ${{ secrets.PRODUCTION_USER }}
        DEPLOY_KEY: ${{ secrets.PRODUCTION_SSH_KEY }}
        DOCKER_REGISTRY: ${{ env.DOCKER_REGISTRY }}
        IMAGE_PREFIX: ${{ env.IMAGE_PREFIX }}

    - name: 部署后验证
      run: |
        echo "验证部署结果..."
        ./scripts/ci-cd/post-deploy-test.sh
      env:
        PROD_URL: ${{ secrets.PRODUCTION_URL }}

  cleanup:
    needs: [deploy-staging, deploy-production]
    runs-on: ubuntu-latest
    if: always()

    steps:
    - name: 清理旧镜像
      run: |
        echo "清理旧的Docker镜像..."
        # 保留最近的5个版本
        for service in user-service post-service comment-service media-service; do
          echo "清理 $service 旧镜像..."
        done
EOF

**自动化部署策略框架:**
```yaml
部署流水线设计:
  测试环境部署:
    - 自动化构建和镜像推送
    - 滚动更新策略实现
    - 健康检查和回滚机制
    - 数据备份和恢复流程
  
  生产环境部署:
    - 蓝绿部署策略实现
    - 金丝雀发布控制
    - 多环境配置管理
    - 零宕机更新保障
  
  部署安全控制:
    - 审批流程和权限管理
    - 部署窗口时间控制
    - 自动回滚触发条件
    - 监控告警集成策略

# 配置变量
BLUE_COMPOSE="deployment/production/docker-compose.blue.yml"
GREEN_COMPOSE="deployment/production/docker-compose.green.yml"
CURRENT_ENV_FILE="/opt/deployment/current_environment"
BACKUP_DIR="/opt/backups/production/$(date +%Y%m%d_%H%M%S)"

# 检查当前活跃环境
if [ -f "$CURRENT_ENV_FILE" ]; then
    CURRENT_ENV=$(cat "$CURRENT_ENV_FILE")
else
    CURRENT_ENV="blue"
fi

# 确定部署目标环境
if [ "$CURRENT_ENV" = "blue" ]; then
    TARGET_ENV="green"
    TARGET_COMPOSE="$GREEN_COMPOSE"
    INACTIVE_COMPOSE="$BLUE_COMPOSE"
else
    TARGET_ENV="blue"
    TARGET_COMPOSE="$BLUE_COMPOSE"
    INACTIVE_COMPOSE="$GREEN_COMPOSE"
fi

echo "📊 当前环境: $CURRENT_ENV, 部署目标: $TARGET_ENV"

# 创建完整备份
echo "📦 创建生产数据备份..."
mkdir -p "$BACKUP_DIR"
docker exec mysql-production mysqldump -u root -p$MYSQL_ROOT_PASSWORD --single-transaction blog_system > "$BACKUP_DIR/database.sql"
docker exec redis-production redis-cli --rdb "$BACKUP_DIR/redis.rdb"

# 部署到目标环境
echo "🔄 部署到 $TARGET_ENV 环境..."
docker-compose -f "$TARGET_COMPOSE" pull
docker-compose -f "$TARGET_COMPOSE" up -d

# 等待服务完全启动
echo "⏳ 等待服务启动..."
sleep 30

# 健康检查
echo "🏥 执行健康检查..."
HEALTH_CHECK_PASSED=true

for service in user-service post-service comment-service media-service; do
    echo "检查 $service..."
    for i in {1..5}; do
        if docker-compose -f "$TARGET_COMPOSE" exec "$service" curl -f http://localhost:3001/health; then
            echo "✅ $service 健康检查通过"
            break
        else
            echo "⚠️ $service 健康检查失败，重试 $i/5..."
            if [ $i -eq 5 ]; then
                HEALTH_CHECK_PASSED=false
                echo "❌ $service 健康检查最终失败"
            fi
            sleep 10
        fi
    done
done

if [ "$HEALTH_CHECK_PASSED" = "false" ]; then
    echo "❌ 健康检查失败，取消部署"
    docker-compose -f "$TARGET_COMPOSE" down
    exit 1
fi

# 切换流量
echo "🔄 切换生产流量到 $TARGET_ENV..."
# 更新负载均衡器配置
sed -i "s/upstream backend {/upstream backend {\n    # $TARGET_ENV environment/" /etc/nginx/nginx.conf

# 重新加载nginx配置
nginx -s reload

# 验证流量切换
echo "🔍 验证流量切换..."
sleep 10

# 检查新环境是否正常响应
if curl -f "http://localhost/api/health"; then
    echo "✅ 流量切换成功"
    
    # 停止旧环境
    echo "🛑 停止旧环境 $CURRENT_ENV..."
    docker-compose -f "$INACTIVE_COMPOSE" down
    
    # 更新当前环境标记
    echo "$TARGET_ENV" > "$CURRENT_ENV_FILE"
    
    echo "🎉 生产环境部署完成！当前活跃环境: $TARGET_ENV"
else
    echo "❌ 流量切换验证失败，回滚..."
    
    # 回滚nginx配置
    nginx -s reload
    
    # 停止新环境
    docker-compose -f "$TARGET_COMPOSE" down
    
    exit 1
fi
EOF

cat > scripts/ci-cd/health-check.sh << 'EOF'
#!/bin/bash

set -e

echo "🏥 执行生产环境健康检查..."

# 检查服务状态
SERVICES=("user-service" "post-service" "comment-service" "media-service")
FAILED_SERVICES=()

for service in "${SERVICES[@]}"; do
    echo "检查 $service..."
    
    if curl -f --max-time 10 "http://$PROD_HOST/api/health/$service"; then
        echo "✅ $service 健康"
    else
        echo "❌ $service 不健康"
        FAILED_SERVICES+=("$service")
    fi
done

# 检查数据库连接
echo "检查数据库连接..."
if curl -f --max-time 10 "http://$PROD_HOST/api/health/database"; then
    echo "✅ 数据库连接正常"
else
    echo "❌ 数据库连接异常"
    FAILED_SERVICES+=("database")
fi

# 检查Redis连接
echo "检查Redis连接..."
if curl -f --max-time 10 "http://$PROD_HOST/api/health/redis"; then
    echo "✅ Redis连接正常"
else
    echo "❌ Redis连接异常"
    FAILED_SERVICES+=("redis")
fi

# 总结结果
if [ ${#FAILED_SERVICES[@]} -eq 0 ]; then
    echo "🎉 所有健康检查通过！"
    exit 0
else
    echo "❌ 以下服务健康检查失败: ${FAILED_SERVICES[*]}"
    exit 1
fi
EOF

cat > scripts/ci-cd/post-deploy-test.sh << 'EOF'
#!/bin/bash

set -e

echo "🧪 执行部署后验证测试..."

BASE_URL="$PROD_URL"

# 测试用户注册和登录
echo "测试用户功能..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/users/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","email":"test@example.com","password":"test123"}')

if echo "$REGISTER_RESPONSE" | grep -q "success"; then
    echo "✅ 用户注册测试通过"
else
    echo "❌ 用户注册测试失败"
    exit 1
fi

# 测试文章功能
echo "测试文章功能..."
POST_RESPONSE=$(curl -s -X POST "$BASE_URL/api/posts" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TEST_TOKEN" \
    -d '{"title":"测试文章","content":"这是一篇测试文章"}')

if echo "$POST_RESPONSE" | grep -q "success"; then
    echo "✅ 文章发布测试通过"
else
    echo "❌ 文章发布测试失败"
    exit 1
fi

# 测试评论功能
echo "测试评论功能..."
COMMENT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/comments" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TEST_TOKEN" \
    -d '{"postId":1,"content":"这是一条测试评论"}')

if echo "$COMMENT_RESPONSE" | grep -q "success"; then
    echo "✅ 评论功能测试通过"
else
    echo "❌ 评论功能测试失败"
    exit 1
fi

# 测试媒体上传
echo "测试媒体上传..."
# 创建测试图片
echo -e "\x89PNG\r\n\x1a\n" > test.png
MEDIA_RESPONSE=$(curl -s -X POST "$BASE_URL/api/media/upload" \
    -H "Authorization: Bearer $TEST_TOKEN" \
    -F "file=@test.png")

if echo "$MEDIA_RESPONSE" | grep -q "url"; then
    echo "✅ 媒体上传测试通过"
    rm test.png
else
    echo "❌ 媒体上传测试失败"
    rm test.png
    exit 1
fi

echo "🎉 所有部署后验证测试通过！"
EOF

# 为脚本添加执行权限
chmod +x scripts/ci-cd/*.sh
```

**步骤6: 蓝绿部署架构实施**
```yaml
蓝绿部署策略:
  环境隔离设计:
    - 蓝绿环境完全独立运行
    - 负载均衡器流量切换机制
    - 数据库连接池分离管理
    - 缓存层数据同步策略
  
  切换流程控制:
    - 新版本蓝环境预热准备
    - 健康检查和烟雾测试
    - 流量逐步迁移和监控
    - 快速回滚机制和触发条件
  
  部署安全保障:
    - 数据一致性保护机制
    - 事务处理和状态管理
    - 用户会话保持策略
    - 服务依赖关系处理
  
  监控和验证:
    - 部署过程实时监控
    - 关键业务指标对比
    - 用户体验质量评估
    - 性能基准测试验证
    image: ${DOCKER_REGISTRY}/${IMAGE_PREFIX}/media-service:${IMAGE_TAG}
    environment:
      - NODE_ENV=production
      - PORT=3004
      - MINIO_ENDPOINT=minio-production
      - MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
      - MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
      - SERVICE_ENV=blue
    networks:
      - blue-network
    deploy:
      replicas: 2
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3004/health"]

networks:
  blue-network:
    external: true
EOF

# 绿环境配置（类似蓝环境，但使用不同的网络和标识）
cp deployment/production/docker-compose.blue.yml deployment/production/docker-compose.green.yml
sed -i 's/blue/green/g' deployment/production/docker-compose.green.yml
```

**步骤3: 配置监控和告警**
```bash
# 创建Prometheus告警规则
cat > infrastructure/prometheus/alert-rules.yml << 'EOF'
groups:
- name: blog-microservices
  rules:
  - alert: ServiceDown
    expr: up{job=~"user-service|post-service|comment-service|media-service"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "服务 {{ $labels.job }} 已下线"
      description: "{{ $labels.job }} 在 {{ $labels.instance }} 上已下线超过1分钟"

  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "{{ $labels.service }} 错误率过高"
      description: "{{ $labels.service }} 的错误率在过去5分钟内超过10%"

  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "{{ $labels.name }} 内存使用率过高"
      description: "容器 {{ $labels.name }} 内存使用率超过80%"

  - alert: DatabaseConnectionFail
    expr: mysql_up == 0
    for: 30s
    labels:
      severity: critical
    annotations:
      summary: "数据库连接失败"
      description: "MySQL数据库连接不可用"

- name: business-metrics
  rules:
  - alert: HighUserRegistration
    expr: increase(user_registrations_total[1h]) > 100
    labels:
      severity: info
    annotations:
      summary: "用户注册量激增"
      description: "过去1小时用户注册量超过100个"

  - alert: LowPostCreation
    expr: increase(posts_created_total[24h]) < 5
    labels:
      severity: warning
    annotations:
      summary: "文章发布量过低"
      description: "过去24小时文章发布量少于5篇"
EOF

# 创建Grafana告警通知配置
cat > infrastructure/grafana/notification-channels.yml << 'EOF'
apiVersion: 1

notifiers:
  - name: slack-alerts
    type: slack
    uid: slack001
    settings:
      url: ${SLACK_WEBHOOK_URL}
      username: Grafana
      channel: '#devops-alerts'
      iconEmoji: ':exclamation:'
      title: 'Blog System Alert'
      text: |
        {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          Status: {{ .Status }}
        {{ end }}

  - name: email-alerts
    type: email
    uid: email001
    settings:
      addresses: ${ALERT_EMAIL_LIST}
      subject: 'Blog System Alert - {{ .GroupLabels.alertname }}'

delete_notifiers:
  - name: slack-alerts
    uid: slack001
  - name: email-alerts
    uid: email001
EOF
```

**步骤4: 创建自动化部署管道**
```bash
# 创建完整的部署管道脚本
cat > scripts/ci-cd/full-pipeline.sh << 'EOF'
#!/bin/bash

set -e

echo "🚀 启动完整部署管道..."

# 配置变量
ENVIRONMENT=${1:-staging}
BRANCH=${2:-develop}
SKIP_TESTS=${3:-false}

case $ENVIRONMENT in
    staging)
        echo "📦 部署到测试环境..."
        COMPOSE_FILE="deployment/staging/docker-compose.staging.yml"
        ;;
    production)
        echo "🏭 部署到生产环境..."
        COMPOSE_FILE="deployment/production/docker-compose.prod.yml"
        ;;
    *)
        echo "❌ 不支持的环境: $ENVIRONMENT"
        exit 1
        ;;
esac

# 阶段1: 代码检查
echo "🔍 阶段1: 代码质量检查..."
if [ "$SKIP_TESTS" != "true" ]; then
    ./scripts/ci-cd/run-tests.sh
    ./scripts/ci-cd/code-quality-check.sh
fi

# 阶段2: 构建镜像
echo "🔨 阶段2: 构建Docker镜像..."
./scripts/ci-cd/build-images.sh $ENVIRONMENT

# 阶段3: 安全扫描
echo "🛡️ 阶段3: 安全扫描..."
./scripts/ci-cd/security-scan.sh

# 阶段4: 部署
echo "🚀 阶段4: 执行部署..."
if [ "$ENVIRONMENT" = "production" ]; then
    ./scripts/ci-cd/deploy-production.sh
else
    ./scripts/ci-cd/deploy-staging.sh
fi

# 阶段5: 部署后验证
echo "✅ 阶段5: 部署后验证..."
./scripts/ci-cd/post-deploy-test.sh

# 阶段6: 通知
echo "📧 阶段6: 发送部署通知..."
./scripts/ci-cd/send-notification.sh "success" "$ENVIRONMENT" "$BRANCH"

echo "🎉 部署管道执行完成！"
EOF

# 创建代码质量检查脚本
cat > scripts/ci-cd/code-quality-check.sh << 'EOF'
#!/bin/bash

set -e

echo "🔍 执行代码质量检查..."

# ESLint检查
echo "运行ESLint..."
for service in user-service post-service comment-service media-service; do
    if [ -d "services/$service" ]; then
        echo "检查 $service..."
        cd services/$service
        npx eslint . --ext .js --format json --output-file ../../reports/eslint-$service.json || true
        cd ../..
    fi
done

# 代码复杂度检查
echo "运行代码复杂度分析..."
npm install -g complexity-report
for service in user-service post-service comment-service media-service; do
    if [ -d "services/$service" ]; then
        echo "分析 $service 复杂度..."
        cr services/$service/**/*.js --format json --output reports/complexity-$service.json || true
    fi
done

# 依赖安全检查
echo "运行依赖安全检查..."
for service in user-service post-service comment-service media-service; do
    if [ -d "services/$service" ]; then
        echo "检查 $service 依赖安全..."
        cd services/$service
        npm audit --audit-level moderate --json > ../../reports/audit-$service.json || true
        cd ../..
    fi
done

echo "✅ 代码质量检查完成！"
EOF

# 创建安全扫描脚本
cat > scripts/ci-cd/security-scan.sh << 'EOF'
#!/bin/bash

set -e

echo "🛡️ 执行安全扫描..."

# 创建报告目录
mkdir -p reports/security

# Docker镜像安全扫描
echo "扫描Docker镜像安全性..."
for service in user-service post-service comment-service media-service; do
    echo "扫描 $service 镜像..."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$(pwd)/reports/security:/tmp/reports" \
        aquasec/trivy:latest image \
        --format json --output /tmp/reports/trivy-$service.json \
        blog-microservices/$service:latest || true
done

# 容器配置安全检查
echo "检查容器配置安全性..."
docker run --rm -v "$(pwd):/workspace" \
    -v "$(pwd)/reports/security:/tmp/reports" \
    hadolint/hadolint:latest \
    hadolint --format json /workspace/services/*/Dockerfile* > reports/security/hadolint.json || true

# 网络安全扫描
echo "执行网络安全扫描..."
if command -v nmap &> /dev/null; then
    nmap -sV -T4 localhost -p 80,443,3001-3004 > reports/security/nmap.txt || true
fi

echo "✅ 安全扫描完成！"
EOF

# 为所有脚本添加执行权限
chmod +x scripts/ci-cd/*.sh
```

**🤖 AI辅助提示**: 关注生产环境的实际运维需求和系统稳定性

#### 6.8 Module 6 学习总结与成果展示

**🎯 Module 6 核心成果**:

1. **生产级微服务系统**
   - 在Module 5基础上实现了完整的生产环境配置
   - 集成了监控、日志、媒体服务等关键组件
   - 实现了高可用、可扩展的系统架构

2. **DevOps自动化流水线**
   - GitHub Actions CI/CD管道
   - 蓝绿部署策略
   - 自动化测试和质量检查
   - 安全扫描和合规性检查

3. **完整的运维监控体系**
   - Prometheus + Grafana监控仪表板
   - 集中式日志管理
   - 实时告警和通知机制
   - 性能指标收集和分析

**📊 与前续模块的技术演进对比**:

| 能力维度 | Module 4 | Module 5 | Module 6 (本模块) |
|----------|----------|----------|-------------------|
| **架构复杂度** | 单体容器化 | 微服务化 | 生产级微服务 |
| **服务数量** | 1个后端 | 3个微服务 | 7个服务组件 |
| **监控能力** | 基础健康检查 | 简单监控 | 全方位可观测性 |
| **部署策略** | 手动部署 | 半自动化 | 全自动CI/CD |
| **可用性** | 单点故障 | 服务隔离 | 高可用容错 |
| **运维复杂度** | 低 | 中等 | 高 (但自动化) |
| **生产就绪度** | 开发环境 | 测试环境 | 生产环境 |

**🚀 技能掌握验证清单**:

- [ ] 能够设计和实现生产级Docker容器化系统
- [ ] 熟练掌握微服务架构的监控和运维
- [ ] 能够搭建完整的CI/CD自动化流水线  
- [ ] 理解蓝绿部署、滚动更新等部署策略
- [ ] 具备生产环境故障排查和性能优化能力
- [ ] 能够设计和实现可观测性系统
- [ ] 掌握容器化应用的安全最佳实践

**💡 Module 6 学习心得模板**:
```markdown
## Module 6 学习总结

### 技术收获
1. **生产化改造经验**: 
   - 从开发环境到生产环境的完整改造过程
   - 性能优化和资源配置的实践经验

2. **DevOps实践能力**:
   - CI/CD流水线设计和实现
   - 自动化测试和部署的完整流程

3. **运维监控技能**:
   - 监控系统设计和告警配置
   - 日志管理和问题排查方法

### 项目亮点
- 成功将Module 5的微服务系统升级为生产级系统
- 实现了完整的自动化部署和运维流程
- 建立了comprehensive的监控和告警体系

### 后续改进方向
- [ ] 实现更细粒度的监控指标
- [ ] 添加自动扩缩容功能
- [ ] 集成更多安全扫描工具
- [ ] 实现多环境配置管理
```

**🎉 Module 6 完成标志**:
至此，您已经完成了从基础Docker容器化到生产级微服务系统的完整学习路径：
- ✅ Module 4: 掌握了单容器应用的Docker化
- ✅ Module 5: 实现了微服务架构设计和开发
- ✅ Module 6: 完成了生产级系统的运维和自动化

这个完整的项目展示了现代容器化应用从开发到生产的全生命周期管理能力！

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