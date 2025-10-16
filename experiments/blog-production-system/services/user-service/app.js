const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3001;

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

// 初始化数据库连接
(async () => {
  try {
    pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    console.log('✅ User Service: Database connected successfully');
    console.log(`📊 Database: ${dbConfig.database} at ${dbConfig.host}`);
    connection.release();
  } catch (error) {
    console.error('❌ User Service: Database connection failed:', error.message);
    process.exit(1);
  }
})();

// JWT密钥
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

// 健康检查
app.get('/health', async (req, res) => {
  try {
    // 测试数据库连接
    const connection = await pool.getConnection();
    connection.release();
    
    res.json({ 
      service: 'user-service',
      status: 'healthy', 
      timestamp: new Date().toISOString(),
      database: 'connected',
      version: '1.0.0'
    });
  } catch (error) {
    res.status(503).json({
      service: 'user-service',
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 用户注册
app.post('/register', async (req, res) => {
  try {
    const { username, email, password, display_name } = req.body;
    
    // 输入验证
    if (!username || !email || !password) {
      return res.status(400).json({ 
        error: 'Username, email, and password are required',
        details: 'All fields marked with * are mandatory'
      });
    }
    
    // 验证邮箱格式
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }
    
    // 验证密码强度
    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters long' });
    }
    
    // 检查用户是否已存在
    const [existing] = await pool.execute(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [username, email]
    );
    
    if (existing.length > 0) {
      return res.status(409).json({ 
        error: 'Username or email already exists',
        details: 'Please choose a different username or email'
      });
    }
    
    // 密码加密
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);
    
    // 创建用户
    const [result] = await pool.execute(
      'INSERT INTO users (username, email, password_hash, display_name, created_at) VALUES (?, ?, ?, ?, NOW())',
      [username, email, password_hash, display_name || username]
    );
    
    console.log(`👤 New user registered: ${username} (ID: ${result.insertId})`);
    
    res.status(201).json({ 
      id: result.insertId,
      username,
      email,
      display_name: display_name || username,
      message: 'User registered successfully',
      created_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ 
      error: 'Failed to register user',
      details: 'Internal server error occurred'
    });
  }
});

// 用户登录
app.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({ 
        error: 'Username and password are required' 
      });
    }
    
    // 查找用户 (支持用户名或邮箱登录)
    const [users] = await pool.execute(
      'SELECT id, username, email, password_hash, display_name, created_at FROM users WHERE username = ? OR email = ?',
      [username, username]
    );
    
    if (users.length === 0) {
      return res.status(401).json({ 
        error: 'Invalid credentials',
        details: 'Username or password is incorrect'
      });
    }
    
    const user = users[0];
    
    // 验证密码
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({ 
        error: 'Invalid credentials',
        details: 'Username or password is incorrect'
      });
    }
    
    // 生成JWT token
    const tokenPayload = { 
      id: user.id, 
      username: user.username,
      email: user.email,
      display_name: user.display_name
    };
    
    const token = jwt.sign(tokenPayload, JWT_SECRET, { expiresIn: '24h' });
    
    console.log(`🔐 User login: ${user.username} (ID: ${user.id})`);
    
    res.json({
      token,
      expires_in: '24h',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        display_name: user.display_name,
        created_at: user.created_at
      },
      message: 'Login successful'
    });
  } catch (error) {
    console.error('Error logging in user:', error);
    res.status(500).json({ 
      error: 'Failed to login',
      details: 'Internal server error occurred'
    });
  }
});

// 获取用户信息
app.get('/profile/:id', async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    
    if (!userId || userId <= 0) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }
    
    const [users] = await pool.execute(
      'SELECT id, username, email, display_name, avatar_url, created_at FROM users WHERE id = ?',
      [userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ 
        error: 'User not found',
        details: 'The requested user does not exist'
      });
    }
    
    res.json(users[0]);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ 
      error: 'Failed to fetch user profile',
      details: 'Internal server error occurred'
    });
  }
});

// 获取所有用户列表 (用于作者选择)
app.get('/list', async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT id, username, display_name, created_at FROM users ORDER BY display_name'
    );
    
    res.json(users);
  } catch (error) {
    console.error('Error fetching users list:', error);
    res.status(500).json({ 
      error: 'Failed to fetch users list',
      details: 'Internal server error occurred'
    });
  }
});

// 更新用户资料 (需要认证)
app.put('/profile/:id', verifyToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    const { display_name, avatar_url } = req.body;
    
    // 检查权限 (只能修改自己的资料)
    if (req.user.id !== userId) {
      return res.status(403).json({ 
        error: 'Access denied',
        details: 'You can only modify your own profile'
      });
    }
    
    const [result] = await pool.execute(
      'UPDATE users SET display_name = ?, avatar_url = ?, updated_at = NOW() WHERE id = ?',
      [display_name, avatar_url, userId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({ 
      message: 'Profile updated successfully',
      updated_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ 
      error: 'Failed to update profile',
      details: 'Internal server error occurred'
    });
  }
});

// 验证Token有效性
app.get('/verify-token', verifyToken, (req, res) => {
  res.json({
    valid: true,
    user: req.user,
    message: 'Token is valid'
  });
});

// 获取用户统计信息
app.get('/stats', async (req, res) => {
  try {
    const [userCount] = await pool.execute('SELECT COUNT(*) as total FROM users');
    const [recentUsers] = await pool.execute(
      'SELECT COUNT(*) as recent FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)'
    );
    
    res.json({
      totalUsers: userCount[0].total,
      recentUsers: recentUsers[0].recent,
      service: 'user-service',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({ 
      error: 'Failed to fetch user stats',
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
    service: 'user-service'
  });
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log('🚀 User Service starting...');
  console.log(`📡 Listening on port ${port}`);
  console.log(`🌐 Health check: http://localhost:${port}/health`);
  console.log(`📋 Available endpoints:`);
  console.log(`   POST /register     - User registration`);
  console.log(`   POST /login        - User authentication`);
  console.log(`   GET  /profile/:id  - Get user profile`);
  console.log(`   GET  /list         - List all users`);
  console.log(`   GET  /stats        - User statistics`);
  console.log('🎉 User Service ready for requests!');
});

// 优雅关闭
process.on('SIGTERM', async () => {
  console.log('⏹️  User Service shutting down...');
  if (pool) {
    await pool.end();
  }
  process.exit(0);
});