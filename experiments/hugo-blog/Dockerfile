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
