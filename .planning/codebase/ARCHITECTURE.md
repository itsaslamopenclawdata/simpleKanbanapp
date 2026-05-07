# Architecture
> Generated: 2026-05-07
> Focus: arch
> Project: Simple Kanban Practice App

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    Browser (Single Page)                     │
│                   `index.html`                               │
│           inline CSS + vanilla JS + fetch()                  │
├──────────────────┬──────────────────┬───────────────────────┤
│   GET /tasks     │  POST/PUT/DELETE │   express.static()    │
│   (read all)     │  /tasks/:id      │   (serves HTML)       │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│               Express Server (`server.js`)                   │
│   4 CRUD endpoints — raw SQL via `pg` — no layers            │
│   Hardcoded DB connection: localhost:5432                     │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  PostgreSQL (`kanban_practice`)                              │
│  Single table: `tasks` (id, title, status, created_at)      │
│  Local only — no migrations, no ORM                          │
└─────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| Express Server | HTTP routing, SQL execution, static file serving | `server.js` |
| Frontend Page | DOM rendering, user interaction, API calls | `index.html` |
| Package Manifest | Dependency declarations (express, pg) | `package.json` |

## Pattern Overview

**Overall:** Monolithic server serving static HTML + REST API. Zero separation of concerns by design.

**Key Characteristics:**
- All server logic in a single file (`server.js`) — no services, no repositories, no middleware, no ORM
- All frontend logic in a single file (`index.html`) — no frameworks, no build tools, no modules
- Raw SQL queries inline in route handlers
- Hardcoded configuration — no environment variables, no config files
- Refetch-after-mutation — every write operation triggers a full `GET /tasks` re-read

## Layers

This project explicitly has **no layers**. The architecture is flat by design:

**Server (`server.js`):**
- Purpose: Express routes that directly execute SQL via `pg` client
- Location: `server.js`
- Contains: DB connection setup, 4 route handlers, `express.static()` mount
- Depends on: `express`, `pg`
- Used by: Browser via HTTP

**Frontend (`index.html`):**
- Purpose: Render Kanban board and handle user interactions
- Location: `index.html`
- Contains: HTML structure, inline `<style>` CSS, inline `<script>` vanilla JS
- Depends on: Fetch API (browser built-in)
- Used by: User directly

## Data Flow

### Primary Request Path (Page Load)

1. Browser requests `GET /` — Express serves `index.html` via `express.static(__dirname)` (`server.js`)
2. Inline JS runs `fetch('/tasks')` — Express queries `SELECT * FROM tasks ORDER BY id` via `pg` (`server.js`)
3. JS receives `{ tasks: [...] }` — renders cards into three status columns (`index.html`)

### Add Task Flow

1. User types title and clicks "Add Task" (`index.html`)
2. JS sends `POST /tasks` with `{ "title": "string" }` (`index.html`)
3. Server runs `INSERT INTO tasks (title) VALUES ($1) RETURNING *` (`server.js`)
4. JS refetches `GET /tasks` and re-renders all columns (`index.html`)

### Update Task Status Flow

1. User changes `<select>` dropdown on a task card (`index.html`)
2. JS sends `PUT /tasks/:id` with `{ "status": "new_status" }` (`index.html`)
3. Server runs `UPDATE tasks SET status = $1 WHERE id = $2 RETURNING *` (`server.js`)
4. JS refetches `GET /tasks` and re-renders all columns (`index.html`)

### Delete Task Flow

1. User clicks "Delete" button on a task card (`index.html`)
2. JS sends `DELETE /tasks/:id` (`index.html`)
3. Server runs `DELETE FROM tasks WHERE id = $1` (`server.js`)
4. JS refetches `GET /tasks` and re-renders all columns (`index.html`)

**State Management:**
- No client-side state cache. All data lives in PostgreSQL.
- Every mutation triggers a full re-fetch of all tasks.
- Frontend is purely a render layer — holds no persistent state between operations.

## Key Abstractions

**REST endpoint to SQL mapping:**
- Purpose: Each HTTP verb maps to exactly one SQL operation
- Pattern:
  - `GET /tasks` → `SELECT`
  - `POST /tasks` → `INSERT`
  - `PUT /tasks/:id` → `UPDATE`
  - `DELETE /tasks/:id` → `DELETE`
- Location: `server.js`

**Task status as column partition:**
- Purpose: The three statuses (`todo`, `in_progress`, `done`) determine which visual column a card renders in
- Pattern: Frontend filters the full task array by `status` field and appends cards to the matching DOM column
- Location: `index.html`

## Entry Points

**`server.js` — Application startup:**
- Location: `server.js`
- Triggers: `node server.js` from terminal
- Responsibilities:
  1. Create `pg.Pool` connection to `localhost:5432`, database `kanban_practice`, user `postgres`, password `postgres`
  2. Create Express app
  3. Mount `express.static(__dirname)` to serve `index.html`
  4. Register 4 CRUD route handlers on `/tasks`
  5. Listen on a port (likely 3000)

**`index.html` — Frontend entry:**
- Location: `index.html`
- Triggers: Browser navigation to `http://localhost:3000/`
- Responsibilities:
  1. Render page structure: input area + 3-column layout
  2. On `DOMContentLoaded`, fetch all tasks and render
  3. Wire up "Add Task" button, status `<select>` change handlers, "Delete" button handlers
  4. After any mutation, re-fetch and re-render

## API Contract

| Method | Path | Request Body | Response | SQL |
|--------|------|-------------|----------|-----|
| GET | `/tasks` | none | `{ tasks: [...] }` | `SELECT * FROM tasks` |
| POST | `/tasks` | `{ "title": "string" }` | `{ task: {...} }` | `INSERT INTO tasks (title) VALUES ($1) RETURNING *` |
| PUT | `/tasks/:id` | `{ "status": "string" }` | `{ task: {...} }` | `UPDATE tasks SET status = $1 WHERE id = $2 RETURNING *` |
| DELETE | `/tasks/:id` | none | `{ success: true }` | `DELETE FROM tasks WHERE id = $1` |

## Database Schema

```sql
CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'todo',
  created_at TIMESTAMP DEFAULT NOW()
);
```

- Allowed `status` values: `'todo'`, `'in_progress'`, `'done'`
- Database name: `kanban_practice`
- Connection: `localhost:5432`, user `postgres`, password `postgres`

## Architectural Constraints

- **Single-file server:** All route handlers, DB connection, and static serving in `server.js`. No splitting into modules.
- **Single-file frontend:** All HTML, CSS, and JS in `index.html`. No separate stylesheets or script files.
- **No ORM:** Raw SQL via `pg` library parameterized queries (`$1`, `$2`). No Sequelize, Prisma, Knex, or similar.
- **No middleware:** No body-parser (use `express.json()`), no CORS middleware, no auth middleware.
- **No client routing:** Single page, no hash routing, no pushState.
- **No build step:** `node server.js` is the only command needed to run.
- **Hardcoded config:** DB credentials inline in `server.js`. No `.env`, no config module.

## What Is Explicitly Excluded

Per spec, the following are **not part of this architecture** and must not be added:
- Authentication or authorization
- Input validation or sanitization
- Error handling (try/catch, error middleware)
- Logging (morgan, winston, console.log in production)
- Pagination
- Environment variables or configuration files
- Docker or containerization
- Testing infrastructure
- CI/CD pipeline
- CORS configuration (allow all origins)
- Drag-and-drop interaction
- CSS frameworks or preprocessors
- External frontend dependencies
- Optimistic UI updates
- WebSocket or real-time updates

## Error Handling

**Strategy:** None. The spec explicitly excludes error handling.

**Implication:**
- Unhandled promise rejections in route handlers will crash the process if `pg` queries fail.
- Frontend `fetch()` calls have no `.catch()` — network errors will be silently swallowed.
- This is intentional for a practice/learning project. Do not add error handling unless the spec is updated.

## Cross-Cutting Concerns

**Logging:** Not implemented. No request logging, no query logging.
**Validation:** Not implemented. `POST /tasks` accepts any JSON body; `PUT /tasks/:id` accepts any status string.
**Authentication:** Not implemented. All endpoints are publicly accessible on localhost.
**CORS:** Not configured. Express default (same-origin only) unless explicitly widened.

---

*Architecture analysis: 2026-05-07*
