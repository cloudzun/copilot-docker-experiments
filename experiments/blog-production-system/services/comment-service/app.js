const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
const port = process.env.PORT || 3003;

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

// 初始化数据库连接
(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ Comment Service: Database connected successfully');
    console.log(`📊 Database: ${dbConfig.database} at ${dbConfig.host}`);
    connection.release();
  } catch (error) {
    console.error('❌ Comment Service: Database connection failed:', error.message);
    process.exit(1);
  }
})();

// 健康检查
app.get('/health', async (req, res) => {
  try {
    // 测试数据库连接
    const connection = await pool.getConnection();
    connection.release();
    
    res.json({ 
      service: 'comment-service',
      status: 'healthy', 
      timestamp: new Date().toISOString(),
      database: 'connected',
      version: '1.0.0'
    });
  } catch (error) {
    res.status(503).json({
      service: 'comment-service',
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 获取文章的所有评论
app.get('/post/:postId', async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    
    if (!postId || postId <= 0) {
      return res.status(400).json({ error: 'Invalid post ID' });
    }
    
    // 验证文章是否存在
    const [postCheck] = await pool.execute(
      'SELECT id FROM posts WHERE id = ? AND status = "published"',
      [postId]
    );
    
    if (postCheck.length === 0) {
      return res.status(404).json({ 
        error: 'Post not found',
        details: 'The specified post does not exist or is not published'
      });
    }
    
    // 获取评论 (包含嵌套回复) - 使用字符串模板避免参数问题
    const [comments] = await pool.query(`
      SELECT c.id, c.content, c.created_at, c.parent_id, c.status,
             u.id as user_id, u.username, u.display_name as author_name,
             u.email as author_email
      FROM comments c
      JOIN users u ON c.author_id = u.id
      WHERE c.post_id = ${parseInt(postId)} AND c.status = 'approved'
      ORDER BY c.parent_id ASC, c.created_at ASC
      LIMIT ${parseInt(limit)} OFFSET ${parseInt(offset)}
    `);
    
    // 获取评论总数
    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM comments WHERE post_id = ? AND status = "approved"',
      [parseInt(postId)]
    );
    const total = countResult[0].total;
    
    // 构建层级结构
    const commentMap = new Map();
    const rootComments = [];
    
    comments.forEach(comment => {
      comment.replies = [];
      commentMap.set(comment.id, comment);
      
      if (comment.parent_id === null) {
        rootComments.push(comment);
      }
    });
    
    // 添加回复到父评论
    comments.forEach(comment => {
      if (comment.parent_id !== null) {
        const parent = commentMap.get(comment.parent_id);
        if (parent) {
          parent.replies.push(comment);
        }
      }
    });
    
    res.json({
      comments: rootComments,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: offset + limit < total,
        hasPrev: page > 1
      },
      post_id: postId,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ 
      error: 'Failed to fetch comments',
      details: 'Internal server error occurred'
    });
  }
});

// 发布新评论
app.post('/post/:postId', verifyToken, async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const { content, parent_id } = req.body;
    
    // 从JWT token中获取用户信息
    const user_id = req.user.id;
    
    // 输入验证
    if (!postId || postId <= 0) {
      return res.status(400).json({ error: 'Invalid post ID' });
    }
    
    if (!content) {
      return res.status(400).json({ 
        error: 'Content is required',
        details: 'Comment content must be provided'
      });
    }
    
    if (content.trim().length < 2) {
      return res.status(400).json({ 
        error: 'Comment content must be at least 2 characters long'
      });
    }
    
    if (content.length > 1000) {
      return res.status(400).json({ 
        error: 'Comment content must be less than 1000 characters'
      });
    }
    
    // 检查文章是否存在
    const [posts] = await pool.execute(
      'SELECT id FROM posts WHERE id = ? AND status = "published"', 
      [postId]
    );
    
    if (posts.length === 0) {
      return res.status(404).json({ 
        error: 'Post not found',
        details: 'The specified post does not exist or is not published'
      });
    }
    
    // 检查用户是否存在
    const [users] = await pool.execute(
      'SELECT id, username, display_name FROM users WHERE id = ?', 
      [user_id]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ 
        error: 'User not found',
        details: 'The specified user does not exist'
      });
    }
    
    // 如果是回复，检查父评论是否存在
    if (parent_id) {
      const [parentComment] = await pool.execute(
        'SELECT id FROM comments WHERE id = ? AND post_id = ?',
        [parent_id, postId]
      );
      
      if (parentComment.length === 0) {
        return res.status(404).json({ 
          error: 'Parent comment not found',
          details: 'The specified parent comment does not exist for this post'
        });
      }
    }
    
    // 插入评论
    const [result] = await pool.execute(
      'INSERT INTO comments (post_id, author_id, content, parent_id, status, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
      [postId, user_id, content.trim(), parent_id || null, 'approved']
    );
    
    const user = users[0];
    console.log(`💬 New comment added: Post ${postId} by ${user.username} (Comment ID: ${result.insertId})`);
    
    res.status(201).json({ 
      id: result.insertId,
      post_id: postId,
      user_id: user_id,
      content: content.trim(),
      parent_id: parent_id || null,
      status: 'approved',
      author: {
        id: user.id,
        username: user.username,
        display_name: user.display_name
      },
      message: 'Comment created successfully',
      created_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({ 
      error: 'Failed to create comment',
      details: 'Internal server error occurred'
    });
  }
});

// 更新评论
app.put('/:commentId', async (req, res) => {
  try {
    const commentId = parseInt(req.params.commentId);
    const { content, status } = req.body;
    
    if (!commentId || commentId <= 0) {
      return res.status(400).json({ error: 'Invalid comment ID' });
    }
    
    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }
    
    if (content.trim().length < 2) {
      return res.status(400).json({ 
        error: 'Comment content must be at least 2 characters long'
      });
    }
    
    const [result] = await pool.execute(
      'UPDATE comments SET content = ?, status = ?, updated_at = NOW() WHERE id = ?',
      [content.trim(), status || 'approved', commentId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    
    res.json({ 
      message: 'Comment updated successfully',
      updated_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error updating comment:', error);
    res.status(500).json({ 
      error: 'Failed to update comment',
      details: 'Internal server error occurred'
    });
  }
});

// 删除评论 (软删除，更改状态)
app.delete('/:commentId', async (req, res) => {
  try {
    const commentId = parseInt(req.params.commentId);
    
    if (!commentId || commentId <= 0) {
      return res.status(400).json({ error: 'Invalid comment ID' });
    }
    
    // 检查评论是否存在
    const [commentCheck] = await pool.execute(
      'SELECT id, author_id FROM comments WHERE id = ?',
      [commentId]
    );
    
    if (commentCheck.length === 0) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    
    // 软删除 - 更改状态为rejected而不是物理删除
    const [result] = await pool.execute(
      'UPDATE comments SET status = "rejected", updated_at = NOW() WHERE id = ?',
      [commentId]
    );
    
    console.log(`🗑️  Comment ${commentId} marked as deleted`);
    
    res.json({ 
      message: 'Comment deleted successfully',
      deleted_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ 
      error: 'Failed to delete comment',
      details: 'Internal server error occurred'
    });
  }
});

// 获取用户的所有评论
app.get('/user/:userId', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    
    if (!userId || userId <= 0) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }
    
    const [comments] = await pool.execute(`
      SELECT c.id, c.content, c.created_at, c.status,
             c.post_id, p.title as post_title,
             u.username, u.display_name as author_name
      FROM comments c
      JOIN posts p ON c.post_id = p.id
      JOIN users u ON c.author_id = u.id
      WHERE c.author_id = ? AND c.status = 'approved'
      ORDER BY c.created_at DESC
      LIMIT ? OFFSET ?
    `, [userId, limit, offset]);
    
    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM comments WHERE author_id = ? AND status = "approved"',
      [userId]
    );
    const total = countResult[0].total;
    
    res.json({
      comments,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      },
      user_id: userId
    });
  } catch (error) {
    console.error('Error fetching user comments:', error);
    res.status(500).json({ 
      error: 'Failed to fetch user comments',
      details: 'Internal server error occurred'
    });
  }
});

// 获取评论统计信息
app.get('/stats/summary', async (req, res) => {
  try {
    const [commentCount] = await pool.execute('SELECT COUNT(*) as count FROM comments WHERE status = "approved"');
    const [postWithComments] = await pool.execute('SELECT COUNT(DISTINCT post_id) as count FROM comments WHERE status = "approved"');
    const [recentComments] = await pool.execute(
      'SELECT COUNT(*) as count FROM comments WHERE status = "approved" AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)'
    );
    const [activeUsers] = await pool.execute(
      'SELECT COUNT(DISTINCT author_id) as count FROM comments WHERE status = "approved" AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)'
    );
    
    res.json({
      totalComments: commentCount[0].count,
      postsWithComments: postWithComments[0].count,
      recentComments: recentComments[0].count,
      activeCommenters: activeUsers[0].count,
      service: 'comment-service',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching comment stats:', error);
    res.status(500).json({ 
      error: 'Failed to fetch comment stats',
      details: 'Internal server error occurred'
    });
  }
});

// 审核评论 (批量操作)
app.patch('/moderate', async (req, res) => {
  try {
    const { comment_ids, status } = req.body;
    
    if (!comment_ids || !Array.isArray(comment_ids) || comment_ids.length === 0) {
      return res.status(400).json({ error: 'comment_ids array is required' });
    }
    
    if (!['approved', 'rejected', 'pending'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status. Must be approved, rejected, or pending' });
    }
    
    const placeholders = comment_ids.map(() => '?').join(',');
    const [result] = await pool.execute(
      `UPDATE comments SET status = ?, updated_at = NOW() WHERE id IN (${placeholders})`,
      [status, ...comment_ids]
    );
    
    res.json({
      message: `${result.affectedRows} comments updated to ${status}`,
      affected_comments: result.affectedRows,
      updated_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error moderating comments:', error);
    res.status(500).json({ 
      error: 'Failed to moderate comments',
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
    service: 'comment-service'
  });
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log('🚀 Comment Service starting...');
  console.log(`📡 Listening on port ${port}`);
  console.log(`🌐 Health check: http://localhost:${port}/health`);
  console.log(`📋 Available endpoints:`);
  console.log(`   GET    /post/:id     - Get comments for post`);
  console.log(`   POST   /post/:id     - Add comment to post`);
  console.log(`   PUT    /:id          - Update comment`);
  console.log(`   DELETE /:id          - Delete comment`);
  console.log(`   GET    /user/:id     - Get user's comments`);
  console.log(`   PATCH  /moderate     - Moderate comments`);
  console.log(`   GET    /stats/summary - Comment statistics`);
  console.log('🎉 Comment Service ready for requests!');
});

// 优雅关闭
process.on('SIGTERM', async () => {
  console.log('⏹️  Comment Service shutting down...');
  if (pool) {
    await pool.end();
  }
  process.exit(0);
});