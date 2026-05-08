# Build Prompts: Simple Kanban Practice App

> Session prompts for building the Kanban app from spec to working product.
> Each session is self-contained — copy the prompt text into a fresh Claude session.

> **Prerequisites:** None — SQLite is embedded, no external service needed.

## Session checklist

**Format:** `- [x|s|/| ] **Session N** — title — deps`
**Legend:** `[x]` done · `[s]` skipped (human-gated) · `[/]` in progress · `[ ]` pending

- [ ] **Session 1** — Project scaffolding + database setup — deps: none
- [ ] **Session 2** — Backend API (4 CRUD endpoints) — deps: Session 1
- [ ] **Session 3** — Frontend UI (3-column Kanban board) — deps: Session 2
- [s] **Session 4** — End-to-end smoke test — deps: Session 3

---

### Session 1 — Project scaffolding + database setup

**Type:** execute  **Worktree:** `.worktrees/session-1`  **Branch:** `loop/session-1`  **Depends on:** none

```text
Skills: superpowers:using-superpowers, superpowers:incremental-implementation,
        superpowers:verification-before-completion

Working directory: <inherit>

Pre-flight (Gate -1):
- Verify Node.js is available:
  node --version
- If check fails → STOP and emit:
  HUMAN GATE TRIPPED: Node.js not installed — install it before continuing

This session creates the project skeleton and SQLite database (INF-03, INF-02, DB-01, DB-02).

Reference docs (read before Task 1):
1. .planning/REQUIREMENTS.md (full requirements)
2. Docs/Spec.md (original specification)

Scope (4 tasks, strict order):
- Task 1: Run `npm init -y` and install dependencies (express, better-sqlite3)
- Task 2: In server.js, create SQLite database initialization that:
  - Opens/creates kanban.db in the project root
  - Creates `tasks` table if not exists:
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    status TEXT DEFAULT 'todo',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
- Task 3: Seed database with 3 sample tasks if table is empty — one per status ('todo', 'in_progress', 'done')
- Task 4: Create minimal server.js with Express on port 3000, database init on startup,
  and static file serving (app.use(express.static(__dirname)))

Execution rules:
- Each task: implement → verify → commit. One commit per task.
- No linting or testing (spec excludes both).
- Keep code minimal — no comments, no error handling, no env vars.
- Use better-sqlite3 (synchronous API) — no async needed.

After all tasks close:
- Verify: `node server.js` starts without errors on port 3000.
- Verify: kanban.db file exists in project root after first run.
- Final commit: `chore(loop): Session 1 done — project scaffolding + database`.
- STOP.
```

---

### Session 2 — Backend API (4 CRUD endpoints)

**Type:** execute  **Worktree:** `.worktrees/session-2`  **Branch:** `loop/session-2`  **Depends on:** Session 1

```text
Skills: superpowers:using-superpowers, superpowers:incremental-implementation,
        superpowers:api-and-interface-design, superpowers:verification-before-completion

Working directory: <inherit>

Pre-flight (Gate -1):
- ls package.json
- ls server.js
- grep -q "better-sqlite3" package.json || grep -q "better-sqlite3" server.js
- If any check fails → STOP and emit:
  HUMAN GATE TRIPPED: Session 1 outputs missing — complete scaffolding first

This session builds the 4 REST API endpoints (INF-01, API-01, API-02, API-03, API-04).

Reference docs (read before Task 1):
1. .planning/REQUIREMENTS.md (API-01 through API-04, INF-01)
2. Docs/Spec.md (endpoint contracts)

Scope (5 tasks, strict order):
- Task 1: Add JSON body parser middleware (app.use(express.json())) to server.js
- Task 2: Implement GET /tasks — db.prepare('SELECT * FROM tasks ORDER BY created_at').all(),
  return JSON array
- Task 3: Implement POST /tasks — db.prepare('INSERT INTO tasks (title) VALUES (?)').run(title),
  return the new row (use RETURNING clause or lastInsertRowid + SELECT)
- Task 4: Implement PUT /tasks/:id — db.prepare('UPDATE tasks SET status = ? WHERE id = ?').run(status, id),
  return updated row
- Task 5: Implement DELETE /tasks/:id — db.prepare('DELETE FROM tasks WHERE id = ?').run(id),
  return { success: true }

Execution rules:
- Each task: implement → verify with curl → commit. One commit per task.
- Use better-sqlite3's synchronous .prepare().run() / .prepare().all() / .prepare().get() API.
- No error handling, no validation, no logging (spec excludes all).

After all tasks close:
- Verify each endpoint with curl:
  curl http://localhost:3000/tasks
  curl -X POST http://localhost:3000/tasks -H "Content-Type: application/json" -d '{"title":"Test task"}'
  curl -X PUT http://localhost:3000/tasks/1 -H "Content-Type: application/json" -d '{"status":"done"}'
  curl -X DELETE http://localhost:3000/tasks/1
- Final commit: `chore(loop): Session 2 done — backend API`.
- STOP.
```

---

### Session 3 — Frontend UI (3-column Kanban board)

**Type:** execute  **Worktree:** `.worktrees/session-3`  **Branch:** `loop/session-3`  **Depends on:** Session 2

```text
Skills: superpowers:using-superpowers, superpowers:frontend-ui-engineering,
        superpowers:incremental-implementation, superpowers:verification-before-completion

Working directory: <inherit>

Pre-flight (Gate -1):
- ls server.js
- grep -q "/tasks" server.js
- grep -q "express.static" server.js
- If any check fails → STOP and emit:
  HUMAN GATE TRIPPED: Session 2 outputs missing — complete API first

This session builds the single-page Kanban frontend (FE-01 through FE-06).

Reference docs (read before Task 1):
1. .planning/REQUIREMENTS.md (FE-01 through FE-06)
2. Docs/Spec.md (frontend layout details)

Scope (6 tasks, strict order):
- Task 1: Create index.html with basic HTML structure — header with input + "Add Task"
  button, and a container div for the 3 columns
- Task 2: Add inline CSS — 3-column flexbox layout, task card styling, input/button styling
- Task 3: Write fetchTasks() — GET /tasks on page load, group tasks by status,
  render into "To Do", "In Progress", "Done" columns (FE-01, FE-06)
- Task 4: Wire "Add Task" button — POST /tasks with input value, then refetch (FE-02)
- Task 5: Each task card renders: title text, <select> dropdown (todo/in_progress/done),
  "Delete" button (FE-03). Wire <select> change to PUT /tasks/:id (FE-04).
  Wire delete button to DELETE /tasks/:id (FE-05). Both refetch after (FE-06).
- Task 6: Clear the text input after adding a task. Ensure refetch + re-render works
  after every add, update, and delete.

Execution rules:
- Each task: implement → verify in browser → commit. One commit per task.
- Single index.html file — HTML + inline CSS + vanilla JS only.
- No frameworks, no build tools, no external dependencies.
- Use fetch() for all API calls. No complex state management.
- Refetch-all-after-mutation pattern (call fetchTasks() after every mutation).

After all tasks close:
- Verify in browser at http://localhost:3000:
  1. Sample tasks appear in correct columns
  2. Can add a new task (appears in "To Do")
  3. Can change status (task moves to correct column)
  4. Can delete a task (disappears from board)
  5. Refresh persists all changes
- Final commit: `chore(loop): Session 3 done — frontend UI`.
- STOP.
```

---

### Session 4 — End-to-end smoke test

**Type:** human-gated  **Worktree:** N/A  **Branch:** N/A  **Depends on:** Session 3

```text
This session is human-gated ([s] in the checklist).

It is a manual end-to-end verification of all 15 requirements. The build loop
MUST NOT auto-execute it. The user runs this manually after sessions 1–3 complete.

Verification checklist:
1. Run `node server.js` — starts without errors on port 3000
2. Open http://localhost:3000 — page loads
3. 3 sample tasks render in correct columns (DB-02, FE-01)
4. "To Do" column shows tasks with status 'todo'
5. "In Progress" column shows tasks with status 'in_progress'
6. "Done" column shows tasks with status 'done'
7. Type title + click "Add Task" → new task appears in "To Do" (API-02, FE-02)
8. Change dropdown to "In Progress" → task moves column (API-03, FE-04)
9. Change dropdown to "Done" → task moves column (API-03, FE-04)
10. Click "Delete" → task disappears (API-04, FE-05)
11. Refresh page → all changes persisted (API-01, FE-06)
12. Each card shows title, dropdown, delete button (FE-03)

Sentinel: keep this as `[s]` in the checklist. The orchestrator skips it.
```
