const express = require('express');
const { Pool } = require('pg');

const app = express();
const pool = new Pool({
  host: 'db',
  port: 5432,
  database: 'testdb',
  user: 'user',
  password: 'password'
});

app.get('/users/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'Invalid ID' });

    try {
        const result = await pool.query('SELECT id, name, age FROM users WHERE id = $1', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'User not found' });

        const user = result.rows[0];
        res.json({
            id: user.id,
            name: user.name,
            age: user.age,
            extra_info: `${user.name} is ${user.age} years old`
        });
    } catch (err) {
        res.status(500).json({ error: 'Database error' });
    }
});

app.listen(8080, () => {
    console.log(`Node.js Express running on http://localhost:8080`);
});
