# Docker Hello World 示例

## 基础容器运行
```bash
# 运行Hello World容器
docker run --rm hello-world

# 运行交互式Ubuntu容器
docker run -it ubuntu:20.04 bash

# 后台运行Nginx
docker run -d --name my-nginx -p 8080:80 nginx
```

## 简单Web应用
```dockerfile
# Dockerfile示例
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## Docker Compose示例
```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "80:80"
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
```