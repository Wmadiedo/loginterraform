// File: server.js
const express = require('express');
const session = require('express-session');
const bcrypt = require('bcrypt');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const db = new sqlite3.Database('./users.db');

app.use(express.static('.'));
app.use(express.json());
app.use(session({
  secret: 'secret',
  resave: false,
  saveUninitialized: false
}));

db.run(`CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  passwordHash TEXT NOT NULL
)`);

app.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  const hash = await bcrypt.hash(password, 10);
  db.run(`INSERT INTO users (username, email, passwordHash) VALUES (?, ?, ?)`,
    [username, email, hash],
    function (err) {
      if (err) return res.status(500).json({ message: 'Email already registered' });
      res.json({ message: 'Registration successful' });
    });
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, user) => {
    if (err || !user) return res.status(400).json({ message: 'Invalid email or password' });
    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) return res.status(400).json({ message: 'Invalid email or password' });

    req.session.userId = user.id;
    res.json({ message: 'Login successful' });
  });
});

app.get('/dashboard', (req, res) => {
  if (!req.session.userId) return res.status(401).send('Unauthorized');
  res.send(`<h1>Welcome, you are logged in!</h1><a href='/index.html'>Logout</a>`);
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
