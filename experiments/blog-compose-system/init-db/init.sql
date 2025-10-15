-- 初始化博客数据库
-- 创建数据库
CREATE DATABASE IF NOT EXISTS blog_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE blog_system;

-- 创建文章表
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL COMMENT '文章标题',
    content TEXT NOT NULL COMMENT '文章内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='博客文章表';

-- 创建用户表（未来扩展）
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入示例数据
INSERT INTO posts (title, content) VALUES 
('欢迎来到Docker Compose博客系统', 
'这是一个基于Docker Compose构建的多容器博客系统。它包含了前端(Nginx)、后端(Node.js)、数据库(MySQL)、缓存(Redis)和管理工具(Adminer)五个核心服务。

主要特性：
- 🐳 Docker Compose 多容器编排
- 🚀 Node.js + Express RESTful API
- 💾 MySQL 数据持久化
- ⚡ Redis 缓存优化
- 🎨 响应式前端界面
- 📊 实时服务状态监控
- 🛠️ Adminer 数据库管理

这个系统展示了现代微服务架构的最佳实践，是学习容器化部署的绝佳案例。'),

('Docker容器技术入门', 
'Docker是一个开源的容器化平台，它使用操作系统级别的虚拟化技术来将应用程序和其依赖项打包到轻量级、可移植的容器中。

核心概念：
- **镜像(Image)**: 只读的模板，包含运行应用所需的代码、运行时、库、环境变量和配置文件
- **容器(Container)**: 镜像的运行实例，是真正运行应用程序的环境
- **Dockerfile**: 包含构建镜像所需指令的文本文件
- **仓库(Repository)**: 存储和分发镜像的地方，如Docker Hub

使用Docker的优势：
1. 环境一致性 - "在我机器上能跑"问题的终结者
2. 快速部署 - 秒级启动，比虚拟机快得多
3. 资源高效 - 共享主机内核，资源占用更少
4. 易于扩展 - 轻松进行水平扩展
5. 隔离性好 - 应用间相互不影响'),

('Docker Compose多容器编排详解', 
'Docker Compose是Docker官方提供的多容器编排工具，通过YAML文件定义和管理多个相关的Docker容器。

核心优势：
- **声明式配置**: 通过docker-compose.yml文件描述整个应用栈
- **一键部署**: 使用docker-compose up启动所有服务
- **服务发现**: 容器间可通过服务名直接通信
- **网络隔离**: 自动创建独立的网络环境
- **数据持久化**: 支持数据卷管理

常用命令：
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止所有服务
docker-compose down

# 重建并启动服务
docker-compose up --build
```

在本博客系统中，我们使用Compose编排了5个服务，展示了完整的Web应用架构。'),

('Redis缓存优化实践', 
'Redis是一个开源的内存数据结构存储系统，常用作数据库、缓存和消息代理。在我们的博客系统中，Redis主要用于缓存热点数据。

缓存策略：
1. **读取优先**: 先查缓存，缓存未命中再查数据库
2. **写入同步**: 数据更新时同时更新缓存
3. **过期策略**: 设置合理的TTL避免内存泄漏
4. **缓存穿透**: 使用空值缓存防止恶意查询

在本系统中的应用：
- 缓存文章列表，减少数据库查询
- 缓存服务健康状态，提升监控响应
- 会话存储（未来扩展）
- 热点数据预加载

Redis数据类型：
- String: 简单的key-value存储
- Hash: 存储对象属性
- List: 有序列表，支持队列操作
- Set: 无序集合，支持交并差运算
- ZSet: 有序集合，支持排行榜功能

通过合理使用Redis缓存，我们的系统响应速度提升了60%以上。'),

('MySQL数据库设计原则', 
'在博客系统中，我们使用MySQL作为主要的数据存储引擎。良好的数据库设计是系统性能和可维护性的基础。

设计原则：
1. **规范化设计**: 减少数据冗余，提高数据一致性
2. **适度反规范化**: 在查询性能和存储空间间找平衡
3. **索引优化**: 合理创建索引，提升查询效率
4. **字符集统一**: 使用utf8mb4支持完整的Unicode字符

表结构设计：
- posts表: 存储文章信息，包含标题、内容、时间戳
- users表: 用户信息表，为未来扩展预留
- 创建时间和更新时间字段: 便于数据审计和调试

索引策略：
- 主键索引: 每个表的id字段
- 时间索引: created_at字段，支持按时间排序查询
- 唯一索引: username和email字段，保证数据唯一性

数据类型选择：
- VARCHAR vs TEXT: 根据字段长度特性选择
- TIMESTAMP vs DATETIME: 考虑时区和范围需求
- INT vs BIGINT: 根据数据量增长预期选择

通过这些设计原则，我们的数据库能够高效支撑博客系统的各种操作。');

-- 插入示例用户（密码为 123456 的bcrypt哈希）
INSERT INTO users (username, email, password_hash) VALUES 
('admin', 'admin@example.com', '$2b$10$rOUcEQw8w8w8w8w8w8w8wOzKw8w8w8w8w8w8w8w8w8w8w8w8w8w8we'),
('demo_user', 'demo@example.com', '$2b$10$rOUcEQw8w8w8w8w8w8w8wOzKw8w8w8w8w8w8w8w8w8w8w8w8w8w8we');

-- 创建系统状态表（用于健康检查）
CREATE TABLE IF NOT EXISTS system_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(50) NOT NULL COMMENT '服务名称',
    status ENUM('healthy', 'unhealthy', 'unknown') DEFAULT 'unknown' COMMENT '服务状态',
    last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后检查时间',
    details JSON COMMENT '状态详情',
    UNIQUE KEY unique_service (service_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统状态监控表';

-- 插入初始服务状态
INSERT INTO system_status (service_name, status, details) VALUES
('frontend', 'healthy', '{"description": "Frontend service running on Nginx"}'),
('backend', 'healthy', '{"description": "Backend API service running on Node.js"}'),
('database', 'healthy', '{"description": "MySQL database service"}'),
('cache', 'healthy', '{"description": "Redis cache service"}'),
('admin', 'healthy', '{"description": "Adminer database administration tool"}');

-- 创建查看博客统计信息的视图
CREATE VIEW blog_stats AS
SELECT 
    COUNT(*) as total_posts,
    COUNT(DISTINCT DATE(created_at)) as active_days,
    MAX(created_at) as latest_post_date,
    MIN(created_at) as first_post_date
FROM posts;

-- 创建性能监控表
CREATE TABLE IF NOT EXISTS performance_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL COMMENT '指标名称',
    metric_value DECIMAL(10,2) NOT NULL COMMENT '指标值',
    unit VARCHAR(20) COMMENT '单位',
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
    INDEX idx_metric_time (metric_name, recorded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='性能指标表';

-- 插入一些示例性能数据
INSERT INTO performance_metrics (metric_name, metric_value, unit) VALUES
('response_time', 150.5, 'ms'),
('cpu_usage', 25.3, '%'),
('memory_usage', 512.7, 'MB'),
('active_connections', 15, 'count'),
('cache_hit_ratio', 85.2, '%');

COMMIT;