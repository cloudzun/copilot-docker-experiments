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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 为现有posts表添加作者关联
ALTER TABLE posts ADD COLUMN IF NOT EXISTS author_id INT DEFAULT 1;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS status ENUM('draft', 'published') DEFAULT 'published';

-- 添加外键约束
-- ALTER TABLE posts ADD CONSTRAINT fk_posts_author FOREIGN KEY (author_id) REFERENCES users(id);

-- 插入示例用户
INSERT IGNORE INTO users (id, username, email, password_hash, display_name) VALUES 
(1, 'admin', 'admin@blog.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '系统管理员'),
(2, 'author1', 'author1@blog.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '技术作者'),
(3, 'reader1', 'reader1@blog.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '普通读者');

-- 更新现有文章的作者信息
UPDATE posts SET author_id = 1 WHERE author_id IS NULL AND (author IS NULL OR author = '系统管理员');
UPDATE posts SET author_id = 2 WHERE author_id IS NULL AND author = 'Docker专家';
UPDATE posts SET author_id = 1 WHERE author_id IS NULL;