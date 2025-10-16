const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
const port = process.env.PORT || 3002;

// JWT密钥 (应该与user服务保持一致)
const JWT_SECRET = process.env.JWT_SECRET || 'user-service-microservices-secret-key-2024';

// 验证JWT令牌的中间件
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

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
let redisClient;

// 初始化数据库连接
(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ Post Service: Database connected successfully');
    console.log(`📊 Database: ${dbConfig.database} at ${dbConfig.host}`);
    connection.release();
  } catch (error) {
    console.error('❌ Post Service: Database connection failed:', error.message);
    process.exit(1);
  }
})();

// 初始化Redis连接
(async () => {
  try {
    redisClient = redis.createClient({
      socket: {
        host: process.env.REDIS_HOST || 'cache',
        port: 6379
      }
    });
    
    redisClient.on('error', (err) => console.log('Redis Client Error', err));
    redisClient.on('connect', () => console.log('✅ Post Service: Redis connected successfully'));
    
    await redisClient.connect();
  } catch (error) {
    console.warn('⚠️  Post Service: Redis connection failed:', error.message);
    console.log('📝 Post Service will continue without caching');
  }
})();

// 健康检查
app.get('/health', async (req, res) => {
  try {
    // 测试数据库连接
    const connection = await pool.getConnection();
    connection.release();
    
    // 测试Redis连接
    let redisStatus = 'disconnected';
    if (redisClient && redisClient.isOpen) {
      redisStatus = 'connected';
    }
    
    res.json({ 
      service: 'post-service',
      status: 'healthy', 
      timestamp: new Date().toISOString(),
      database: 'connected',
      redis: redisStatus,
      version: '1.0.0'
    });
  } catch (error) {
    res.status(503).json({
      service: 'post-service',
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 获取所有文章 (扩展为包含作者信息)
app.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    
    console.log(`📖 Fetching posts: page=${page}, limit=${limit}, offset=${offset}`);
    
    // 缓存键
    const cacheKey = `posts:list:page:${page}:limit:${limit}`;
    
    // 尝试从缓存获取
    if (redisClient && redisClient.isOpen) {
      try {
        const cached = await redisClient.get(cacheKey);
        if (cached) {
          console.log(`📥 Cache hit for posts list page ${page}`);
          return res.json(JSON.parse(cached));
        }
      } catch (cacheError) {
        console.warn('Cache read error:', cacheError.message);
      }
    }
    
    // 从数据库获取 - 使用字符串模板避免参数问题  
    console.log('Executing query with params:', [parseInt(limit), parseInt(offset)]);
    const [rows] = await pool.query(`
      SELECT p.id, p.title, p.content, p.author, p.created_at, p.status
      FROM posts p 
      WHERE p.status = 'published'
      ORDER BY p.created_at DESC
      LIMIT ${parseInt(limit)} OFFSET ${parseInt(offset)}
    `);
    
    // 获取总数
    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM posts WHERE status = "published"'
    );
    const total = countResult[0].total;
    
    const result = {
      posts: rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: offset + limit < total,
        hasPrev: page > 1
      },
      timestamp: new Date().toISOString()
    };
    
    // 缓存结果 (5分钟)
    if (redisClient && redisClient.isOpen) {
      try {
        await redisClient.setEx(cacheKey, 300, JSON.stringify(result));
        console.log(`📤 Cached posts list page ${page}`);
      } catch (cacheError) {
        console.warn('Cache write error:', cacheError.message);
      }
    }
    
    res.json(result);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ 
      error: 'Failed to fetch posts',
      details: 'Internal server error occurred'
    });
  }
});

// 获取单篇文章
app.get('/:id', async (req, res) => {
  try {
    const postId = parseInt(req.params.id);
    
    if (!postId || postId <= 0) {
      return res.status(400).json({ error: 'Invalid post ID' });
    }
    
    // 缓存键
    const cacheKey = `post:${postId}`;
    
    // 尝试从缓存获取
    if (redisClient && redisClient.isOpen) {
      try {
        const cached = await redisClient.get(cacheKey);
        if (cached) {
          console.log(`📥 Cache hit for post ${postId}`);
          return res.json(JSON.parse(cached));
        }
      } catch (cacheError) {
        console.warn('Cache read error:', cacheError.message);
      }
    }
    
    const [rows] = await pool.execute(`
      SELECT p.id, p.title, p.content, p.author, p.created_at, p.status,
             p.author_id, u.username as author_username, 
             u.display_name as author_display_name,
             u.email as author_email
      FROM posts p 
      LEFT JOIN users u ON p.author_id = u.id
      WHERE p.id = ? AND p.status = 'published'
    `, [postId]);
    
    if (rows.length === 0) {
      return res.status(404).json({ 
        error: 'Post not found',
        details: 'The requested post does not exist or is not published'
      });
    }
    
    const post = rows[0];
    
    // 缓存结果 (10分钟)
    if (redisClient && redisClient.isOpen) {
      try {
        await redisClient.setEx(cacheKey, 600, JSON.stringify(post));
        console.log(`📤 Cached post ${postId}`);
      } catch (cacheError) {
        console.warn('Cache write error:', cacheError.message);
      }
    }
    
    res.json(post);
  } catch (error) {
    console.error('Error fetching post:', error);
    res.status(500).json({ 
      error: 'Failed to fetch post',
      details: 'Internal server error occurred'
    });
  }
});

// 创建新文章 (支持作者选择)
app.post('/', verifyToken, async (req, res) => {
  try {
    const { title, content, status = 'published' } = req.body;
    
    // 从JWT token中获取用户信息
    const author_id = req.user.id;
    const author = req.user.username || req.user.display_name || 'Anonymous';
    
    // 输入验证
    if (!title || !content) {
      return res.status(400).json({ 
        error: 'Title and content are required',
        details: 'Both title and content fields must be provided'
      });
    }
    
    if (title.length > 255) {
      return res.status(400).json({ error: 'Title must be less than 255 characters' });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO posts (title, content, author, author_id, created_at, status) VALUES (?, ?, ?, ?, NOW(), ?)',
      [title, content, author, author_id, status]
    );
    
    console.log(`📝 New post created: "${title}" by ${author} (ID: ${author_id}, Post ID: ${result.insertId})`);
    
    // 清理相关缓存
    if (redisClient && redisClient.isOpen) {
      try {
        // 清理列表缓存
        const keys = await redisClient.keys('posts:list:*');
        if (keys.length > 0) {
          await redisClient.del(keys);
          console.log('🗑️  Cleared posts list cache');
        }
      } catch (cacheError) {
        console.warn('Cache clear error:', cacheError.message);
      }
    }
    
    res.status(201).json({ 
      id: result.insertId,
      title,
      author: author,
      author_id: author_id,
      status,
      message: 'Post created successfully',
      created_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ 
      error: 'Failed to create post',
      details: 'Internal server error occurred'
    });
  }
});

// 更新文章
app.put('/:id', async (req, res) => {
  try {
    const postId = parseInt(req.params.id);
    const { title, content, status } = req.body;
    
    if (!postId || postId <= 0) {
      return res.status(400).json({ error: 'Invalid post ID' });
    }
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }
    
    const [result] = await pool.execute(
      'UPDATE posts SET title = ?, content = ?, status = ?, updated_at = NOW() WHERE id = ?',
      [title, content, status || 'published', postId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // 清理缓存
    if (redisClient && redisClient.isOpen) {
      try {
        await redisClient.del(`post:${postId}`);
        const listKeys = await redisClient.keys('posts:list:*');
        if (listKeys.length > 0) {
          await redisClient.del(listKeys);
        }
        console.log(`🗑️  Cleared cache for post ${postId}`);
      } catch (cacheError) {
        console.warn('Cache clear error:', cacheError.message);
      }
    }
    
    res.json({ 
      message: 'Post updated successfully',
      updated_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error updating post:', error);
    res.status(500).json({ 
      error: 'Failed to update post',
      details: 'Internal server error occurred'
    });
  }
});

// 删除文章
app.delete('/:id', async (req, res) => {
  try {
    const postId = parseInt(req.params.id);
    
    if (!postId || postId <= 0) {
      return res.status(400).json({ error: 'Invalid post ID' });
    }
    
    const [result] = await pool.execute(
      'DELETE FROM posts WHERE id = ?',
      [postId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // 清理缓存
    if (redisClient && redisClient.isOpen) {
      try {
        await redisClient.del(`post:${postId}`);
        const listKeys = await redisClient.keys('posts:list:*');
        if (listKeys.length > 0) {
          await redisClient.del(listKeys);
        }
        console.log(`🗑️  Cleared cache for deleted post ${postId}`);
      } catch (cacheError) {
        console.warn('Cache clear error:', cacheError.message);
      }
    }
    
    res.json({ 
      message: 'Post deleted successfully',
      deleted_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({ 
      error: 'Failed to delete post',
      details: 'Internal server error occurred'
    });
  }
});

// 搜索文章
app.get('/search/:query', async (req, res) => {
  try {
    const searchQuery = req.params.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    
    if (!searchQuery || searchQuery.trim().length < 2) {
      return res.status(400).json({ 
        error: 'Search query must be at least 2 characters long'
      });
    }
    
    const searchTerm = `%${searchQuery.trim()}%`;
    
    const [rows] = await pool.execute(`
      SELECT p.id, p.title, p.content, p.author, p.created_at,
             p.author_id, u.username as author_username,
             u.display_name as author_display_name
      FROM posts p 
      LEFT JOIN users u ON p.author_id = u.id
      WHERE p.status = 'published' 
        AND (p.title LIKE ? OR p.content LIKE ?)
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    `, [searchTerm, searchTerm, limit, offset]);
    
    const [countResult] = await pool.execute(`
      SELECT COUNT(*) as total FROM posts 
      WHERE status = 'published' 
        AND (title LIKE ? OR content LIKE ?)
    `, [searchTerm, searchTerm]);
    
    const total = countResult[0].total;
    
    res.json({
      posts: rows,
      search: {
        query: searchQuery,
        results: total
      },
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error searching posts:', error);
    res.status(500).json({ 
      error: 'Failed to search posts',
      details: 'Internal server error occurred'
    });
  }
});

// 获取文章统计信息
app.get('/stats/summary', async (req, res) => {
  try {
    const [postCount] = await pool.execute('SELECT COUNT(*) as count FROM posts WHERE status = "published"');
    const [authorCount] = await pool.execute('SELECT COUNT(DISTINCT author_id) as count FROM posts WHERE status = "published"');
    const [recentPosts] = await pool.execute(
      'SELECT COUNT(*) as count FROM posts WHERE status = "published" AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)'
    );
    
    res.json({
      totalPosts: postCount[0].count,
      totalAuthors: authorCount[0].count,
      recentPosts: recentPosts[0].count,
      service: 'post-service',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching post stats:', error);
    res.status(500).json({ 
      error: 'Failed to fetch post stats',
      details: 'Internal server error occurred'
    });
  }
});

// 错误处理中间件
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    error: 'Internal server error',
    message: 'An unexpected error occurred'
  });
});

// 404处理
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `The requested endpoint ${req.method} ${req.originalUrl} does not exist`,
    service: 'post-service'
  });
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log('🚀 Post Service starting...');
  console.log(`📡 Listening on port ${port}`);
  console.log(`🌐 Health check: http://localhost:${port}/health`);
  console.log(`📋 Available endpoints:`);
  console.log(`   GET    /           - List posts (with pagination)`);
  console.log(`   GET    /:id        - Get single post`);
  console.log(`   POST   /           - Create new post`);
  console.log(`   PUT    /:id        - Update post`);
  console.log(`   DELETE /:id        - Delete post`);
  console.log(`   GET    /search/:q  - Search posts`);
  console.log(`   GET    /stats/summary - Post statistics`);
  console.log('🎉 Post Service ready for requests!');
});

// 优雅关闭
process.on('SIGTERM', async () => {
  console.log('⏹️  Post Service shutting down...');
  if (pool) {
    await pool.end();
  }
  if (redisClient) {
    await redisClient.quit();
  }
  process.exit(0);
});