# Simple Kanban App 📋

A minimal, learning-focused Kanban board built with Node.js, Express, and SQLite. Perfect for understanding how web applications work — HTTP verbs, SQL queries, and frontend-backend communication.

## 🎯 What It Does

A 3-column Kanban board where you can:
- **Add tasks** to the "To Do" column
- **Move tasks** between columns (To Do → In Progress → Done)
- **Delete tasks** instantly

No frameworks, no build tools, no complexity. Just Express, SQLite, and vanilla JavaScript.

## 🚀 Quick Start

### Prerequisites
- **Node.js** (v14 or higher)
- **npm**

### Installation & Running

```bash
# Install dependencies
npm install

# Start the server
node server.js
```

Server starts on **http://localhost:3000**

Open your browser and start using the Kanban board immediately.

## 📁 Project Structure

```
simple-kanban-app/
├── server.js          # Express backend + SQLite database
├── index.html         # Frontend UI (inline CSS + vanilla JS)
├── package.json       # Dependencies
├── kanban.db          # SQLite database (auto-created)
└── README.md          # This file
```

## 🏗️ Architecture

### Backend: `server.js`

**Express server** that:
- Creates/opens `kanban.db` (SQLite) on startup
- Initializes `tasks` table with 3 sample rows (if empty)
- Serves static files (index.html)
- Provides 4 CRUD REST endpoints

**Database Schema:**
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  status TEXT DEFAULT 'todo',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Status values:** `'todo'`, `'in_progress'`, `'done'`

### Frontend: `index.html`

Single HTML file with:
- **3-column flexbox layout** (To Do | In Progress | Done)
- **Inline CSS** for styling
- **Vanilla JavaScript** using Fetch API
- Loads tasks on page load
- Updates board after any add/edit/delete

## 📡 API Endpoints

| Method | Endpoint | Body | Response | Purpose |
|--------|----------|------|----------|---------|
| **GET** | `/tasks` | — | `[{...}, ...]` | Fetch all tasks |
| **POST** | `/tasks` | `{ "title": "Task name" }` | `{ id, title, status, created_at }` | Create new task |
| **PUT** | `/tasks/:id` | `{ "status": "in_progress" }` | `{ id, title, status, created_at }` | Update task status |
| **DELETE** | `/tasks/:id` | — | `{ success: true }` | Delete task |

## 🔄 User Flow

1. **Browser opens** → `index.html` loaded
2. **Page initializes** → Fetches all tasks from `/tasks` (GET)
3. **Tasks display** → Grouped into 3 columns by status
4. **Add task** → POST to `/tasks` → Refetch all tasks
5. **Change status** → PUT to `/tasks/:id` → Refetch all tasks
6. **Delete task** → DELETE `/tasks/:id` → Refetch all tasks

## 💡 Design Principles

- **Learning-first:** Every line teaches something (HTTP verbs, SQL, DOM manipulation)
- **Zero complexity:** No frameworks, no build steps, no abstractions
- **Localhost only:** Hardcoded credentials, no error handling (intentional)
- **Refetch pattern:** Every mutation triggers a fresh GET (simple but effective)
- **Minimal dependencies:** Only Express and better-sqlite3

## 📝 Example Usage

```javascript
// Add a task
fetch('/tasks', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ title: 'Learn HTTP verbs' })
})

// Move task to In Progress
fetch('/tasks/1', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'in_progress' })
})

// Delete task
fetch('/tasks/1', { method: 'DELETE' })
```

## 🛠️ Development

### No build step required
Changes to `server.js` require a restart. Changes to `index.html` auto-reflect on browser refresh.

### Sample data
On first run, the database seeds 3 sample tasks:
- "Create the frontend" (todo)
- "Build the API" (in_progress)
- "Set up project" (done)

### Clear the database
Delete `kanban.db` and restart `node server.js` to reseed with sample data.

## 📚 What You'll Learn

This project demonstrates:

- ✅ **HTTP Methods:** GET, POST, PUT, DELETE
- ✅ **REST API design:** Routing and status codes
- ✅ **SQL basics:** CREATE TABLE, SELECT, INSERT, UPDATE, DELETE
- ✅ **Fetch API:** Making requests from the frontend
- ✅ **DOM manipulation:** Creating, updating, removing elements
- ✅ **Event listeners:** Handling clicks and form submissions
- ✅ **JSON serialization:** Sending and receiving data
- ✅ **Database persistence:** SQLite fundamentals

## 🚫 What's NOT Included

Intentionally minimal to keep focus on fundamentals:
- ❌ Drag-and-drop
- ❌ Animations
- ❌ Authentication
- ❌ Input validation
- ❌ Error handling
- ❌ Real-time sync
- ❌ Tests
- ❌ Logging

## 📄 License

ISC

## 🤝 Contributing

This is a learning project. Feel free to fork, modify, and experiment!

---

**Happy learning! 🎓**
