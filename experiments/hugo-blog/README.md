# Hugo博客Docker化实践项目

> **Module 2实战项目**: 使用Hugo构建静态博客并容器化

## 📊 项目成果

- ✅ **轻量级镜像**: 约53MB (相比传统方式减少95%)
- ✅ **多阶段构建**: Hugo构建 + Nginx运行
- ✅ **中文支持**: 完整的中文博客系统
- ✅ **SEO优化**: 合理的HTML结构和meta标签
- ✅ **响应式设计**: 支持移动端访问

## 🏗️ 技术架构

```
Hugo源码 → Docker构建阶段1(hugomods/hugo) → 静态文件生成
                                              ↓
最终镜像 ← Docker构建阶段2(nginx:alpine) ← 静态文件复制
```

## 🚀 快速开始

### 1. 构建镜像
```bash
docker build -t hugo-blog:latest .
```

### 2. 运行容器
```bash
docker run -d -p 8082:80 --name my-blog hugo-blog:latest
```

### 3. 访问博客
- 浏览器访问: http://localhost:8082
- 命令行测试: `curl http://localhost:8082`

## 📁 项目结构

```
hugo-blog/
├── config.yaml          # Hugo配置文件
├── Dockerfile           # 多阶段构建配置
├── nginx.conf           # Nginx服务器配置
├── content/            # 博客内容
│   └── posts/          # 文章目录
│       └── first-post.md
├── layouts/            # Hugo模板
│   ├── _default/       # 默认模板
│   │   ├── baseof.html
│   │   ├── list.html
│   │   └── single.html
│   └── index.html      # 首页模板
├── archetypes/         # 内容模板
├── static/            # 静态资源
└── themes/            # 主题目录
```

## 🔧 关键技术点

### 多阶段构建优化
- **第一阶段**: 使用hugomods/hugo构建静态文件
- **第二阶段**: 使用nginx:alpine提供Web服务
- **优化结果**: 最终镜像仅53MB

### Hugo配置要点
```yaml
baseURL: 'http://localhost'
languageCode: 'zh-cn'
title: '我的Docker博客'
defaultContentLanguage: 'zh-cn'
```

### Nginx性能优化
- 启用Gzip压缩
- 配置MIME类型
- 支持SPA路由

## 📚 学习要点

1. **Docker多阶段构建的实际应用**
2. **静态网站生成器的容器化**
3. **Nginx配置和性能优化**
4. **Hugo模板系统和中文支持**
5. **镜像大小优化技巧**

## 🎯 验证标准

- [ ] 镜像构建成功，大小控制在60MB以内
- [ ] 容器正常启动，端口映射正确
- [ ] 网站可正常访问，显示中文内容
- [ ] 文章列表和详细页面功能正常
- [ ] Gzip压缩和缓存配置生效

## 🔗 相关文档

- [Level 1 容器基础与Docker实践](../../docs/01-Level1-Container-Fundamentals.md)
- [Hugo官方文档](https://gohugo.io/documentation/)
- [Docker多阶段构建指南](https://docs.docker.com/develop/dev-best-practices/)