# Simple Kanban App — Phase-wise Tasks

## Phase 1: Project Setup & Database

- [ ] Initialize Node.js project (`npm init -y`)
- [ ] Install dependencies (`npm install express pg`)
- [ ] Create PostgreSQL database `kanban_practice`
- [ ] Create `tasks` table (id SERIAL PRIMARY KEY, title VARCHAR(255), status VARCHAR(20) DEFAULT 'todo', created_at TIMESTAMP DEFAULT NOW())
- [ ] Seed database with 3 sample tasks (one per status: todo, in_progress, done)
- [ ] Verify table exists with `SELECT * FROM tasks;`

## Phase 2: Backend API (server.js)

- [ ] Create `server.js` with Express app setup (port 3000)
- [ ] Configure PostgreSQL connection (host=localhost, port=5432, user=postgres, password=postgres, database=kanban_practice)
- [ ] Add CORS middleware (allow all origins)
- [ ] Serve static files (`app.use(express.static(__dirname))`)
- [ ] Implement `GET /tasks` — query all tasks, return JSON
- [ ] Implement `POST /tasks` — insert new task with title, default status 'todo'
- [ ] Implement `PUT /tasks/:id` — update task status
- [ ] Implement `DELETE /tasks/:id` — delete task by id
- [ ] Test all 4 endpoints with browser or curl

## Phase 3: Frontend (index.html)

- [ ] Create `index.html` with HTML structure (header, 3 columns, input area)
- [ ] Add inline CSS for 3-column layout and task card styling
- [ ] Fetch tasks on page load (`GET /tasks`) and render into columns
- [ ] Add "Add Task" input + button at top, wired to `POST /tasks`
- [ ] Render each task card with: title text, status `<select>` dropdown, "Delete" button
- [ ] Wire status dropdown change to `PUT /tasks/:id`
- [ ] Wire delete button to `DELETE /tasks/:id`
- [ ] After every add/update/delete, refetch all tasks and re-render

## Phase 4: End-to-End Verification

- [ ] Run `node server.js` and open `http://localhost:3000`
- [ ] Verify 3 sample tasks appear in correct columns
- [ ] Add a new task — confirm it appears in "To Do" column
- [ ] Change task status to "In Progress" — confirm it moves column
- [ ] Change task status to "Done" — confirm it moves column
- [ ] Delete a task — confirm it disappears
- [ ] Refresh page — confirm all changes persisted in database

---

## Quick Start Commands

```sql
-- (a) Create the table
CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'todo',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Seed sample data
INSERT INTO tasks (title, status) VALUES
  ('Set up project', 'done'),
  ('Build the API', 'in_progress'),
  ('Create the frontend', 'todo');
```

```bash
# (b) Install dependencies
npm install express pg

# (c) Start the app
node server.js
```
