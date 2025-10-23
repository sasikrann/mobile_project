const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const db = require('./db'); 
const app = express();
const port = 3000;

//------------------ Login + Register ---------------------------/
app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const JWT_SECRET = 'super_secret_key_change_this';


app.post('/api/register', async (req, res) => {
  const { name, username, password } = req.body;

  if (!name || !username || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const checkSql = 'SELECT * FROM users WHERE username = ?';
  db.query(checkSql, [username], async (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (result.length > 0)
      return res.status(400).json({ message: 'Username already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const insertSql = 'INSERT INTO users (name, username, password, role) VALUES (?, ?, ?, "student")';
    db.query(insertSql, [name, username, hashedPassword], (err, result) => {
      if (err) return res.status(500).json({ message: 'Registration failed' });

      res.status(201).json({
        message: 'Registration successful',
        user: {
          id: result.insertId,
          name,
          username,
          role: 'student',
        },
      });
    });
  });
});

app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ message: 'Username and password are required' });

  const sql = 'SELECT * FROM users WHERE username = ?';
  db.query(sql, [username], async (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (result.length === 0) return res.status(404).json({ message: 'User not found' });

    const user = result[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role, username: user.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        username: user.username,
        role: user.role,
      },
    });
  });
});

function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(403).json({ message: 'No token provided' });

  const token = authHeader.split(' ')[1];
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ message: 'Invalid token' });
    req.user = decoded;
    next();
  });
}
app.get('/api/me', verifyToken, (req, res) => {
  res.json({ message: 'Token valid', user: req.user });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`API running at http://localhost:${port}`);
});

//------------------  ---------------------------/







//------------------ ---------------------------/