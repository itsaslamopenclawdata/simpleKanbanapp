const express = require('express');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
const PORT = 3000;

const db = new Database(path.join(__dirname, 'kanban.db'));

db.exec(`
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    status TEXT DEFAULT 'todo',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )
`);

const count = db.prepare('SELECT COUNT(*) as c FROM tasks').get();
if (count.c === 0) {
  const insert = db.prepare('INSERT INTO tasks (title, status) VALUES (?, ?)');
  insert.run('Set up project', 'done');
  insert.run('Build the API', 'in_progress');
  insert.run('Create the frontend', 'todo');
}

app.use(express.json());
app.use(express.static(__dirname));

app.get('/tasks', (req, res) => {
  const tasks = db.prepare('SELECT * FROM tasks ORDER BY created_at').all();
  res.json(tasks);
});

app.post('/tasks', (req, res) => {
  const { title } = req.body;
  const result = db.prepare('INSERT INTO tasks (title) VALUES (?)').run(title);
  const task = db.prepare('SELECT * FROM tasks WHERE id = ?').get(result.lastInsertRowid);
  res.json(task);
});

app.put('/tasks/:id', (req, res) => {
  const { status } = req.body;
  db.prepare('UPDATE tasks SET status = ? WHERE id = ?').run(status, req.params.id);
  const task = db.prepare('SELECT * FROM tasks WHERE id = ?').get(req.params.id);
  res.json(task);
});

app.delete('/tasks/:id', (req, res) => {
  db.prepare('DELETE FROM tasks WHERE id = ?').run(req.params.id);
  res.json({ success: true });
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
