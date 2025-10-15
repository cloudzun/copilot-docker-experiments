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

// 初始化数据库连接（带重试）
async function initDatabase() {
  const maxRetries = 10;
  const retryDelay = 3000; // 3秒
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      pool = mysql.createPool(dbConfig);
      const connection = await pool.getConnection();
      console.log('✅ Database connected successfully');
      connection.release();
      return;
    } catch (error) {
      console.log(`❌ Database connection failed (attempt ${i + 1}/${maxRetries}): ${error.message}`);
      if (i < maxRetries - 1) {
        console.log(`⏳ Retrying in ${retryDelay/1000} seconds...`);
        await new Promise(resolve => setTimeout(resolve, retryDelay));
      }
    }
  }
  console.log('❌ Failed to connect to database after all retries');
}

initDatabase();

// 健康检查端点
app.get('/health', async (req, res) => {
  let dbStatus = 'disconnected';
  
  // 检查数据库连接
  if (pool) {
    try {
      const connection = await pool.getConnection();
      connection.release();
      dbStatus = 'connected';
    } catch (error) {
      dbStatus = 'error';
    }
  }
  
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    services: {
      database: dbStatus,
      redis: redisClient?.isOpen ? 'connected' : 'disconnected'
    }
  });
});

// 获取所有文章
app.get('/api/posts', async (req, res) => {
  try {
    // 先尝试从缓存获取
    if (redisClient?.isOpen) {
      const cached = await redisClient.get('posts');
      if (cached) {
        console.log('📝 Posts from cache');
        return res.json(JSON.parse(cached));
      }
    }

    // 从数据库获取
    const [rows] = await pool.execute(
      'SELECT id, title, content, created_at FROM posts ORDER BY created_at DESC'
    );
    
    // 缓存结果
    if (redisClient?.isOpen) {
      await redisClient.setEx('posts', 300, JSON.stringify(rows)); // 缓存5分钟
    }
    
    console.log('📝 Posts from database');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
});

// 创建新文章
app.post('/api/posts', async (req, res) => {
  try {
    const { title, content } = req.body;
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO posts (title, content, created_at) VALUES (?, ?, NOW())',
      [title, content]
    );
    
    // 清除缓存
    if (redisClient?.isOpen) {
      await redisClient.del('posts');
    }
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Post created successfully' 
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
});

// 获取特定文章
app.get('/api/posts/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const [rows] = await pool.execute(
      'SELECT id, title, content, author, created_at FROM posts WHERE id = ?',
      [id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching post:', error);
    res.status(500).json({ error: 'Failed to fetch post' });
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

// 404处理
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// 错误处理中间件
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Blog API server running on port ${port}`);
  console.log(`📊 Health check: http://localhost:${port}/health`);
  console.log(`📝 Posts API: http://localhost:${port}/api/posts`);
});

// 优雅关闭
process.on('SIGTERM', async () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully');
  
  if (redisClient?.isOpen) {
    await redisClient.quit();
  }
  
  if (pool) {
    await pool.end();
  }
  
  process.exit(0);
});