# Requirements: Simple Kanban Practice App

**Defined:** 2026-05-08
**Core Value:** Working end-to-end Kanban board — add, move, and delete tasks across three columns in a browser.

## v1 Requirements

### Database

- [ ] **DB-01**: Create `tasks` table with id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, status TEXT DEFAULT 'todo', created_at DATETIME DEFAULT CURRENT_TIMESTAMP
- [ ] **DB-02**: Seed database with sample tasks across all three statuses for testing

### API

- [ ] **API-01**: GET /tasks returns all tasks as JSON array
- [ ] **API-02**: POST /tasks creates task with title (expects {"title": "string"}), defaults status to 'todo'
- [ ] **API-03**: PUT /tasks/:id updates task status (expects {"status": "string"})
- [ ] **API-04**: DELETE /tasks/:id deletes task

### Frontend

- [ ] **FE-01**: Fetch all tasks on page load and render in three columns: "To Do", "In Progress", "Done"
- [ ] **FE-02**: Text input + "Add Task" button at top of page creates new task
- [ ] **FE-03**: Each task card shows title, status dropdown, and delete button
- [ ] **FE-04**: Changing status dropdown moves task to correct column
- [ ] **FE-05**: Delete button removes task from board
- [ ] **FE-06**: After any add/update/delete, refetch and re-render all tasks

### Infrastructure

- [ ] **INF-01**: Express server serves static index.html on startup
- [ ] **INF-02**: SQLite database file (kanban.db) created automatically on first run via better-sqlite3
- [ ] **INF-03**: package.json with express and better-sqlite3 dependencies

## v2 Requirements

(None — this is a practice app, no planned extensions)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Authentication | Local practice only, not production |
| Input validation | Spec explicitly excludes |
| Error handling | Spec explicitly excludes |
| Logging | Spec explicitly excludes |
| Pagination | Small dataset expected |
| Environment variables | Hardcoded values acceptable for practice |
| Docker | Local SQLite, no service needed |
| Testing | Practice project, not production |
| CI/CD | No pipeline needed |
| CORS config | Allow all origins |
| Drag-and-drop | Dropdown-based status change only |
| Animations | Spec explicitly excludes |
| CSS frameworks | Inline CSS only |
| PostgreSQL | Switched to SQLite — no service to install |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DB-01 | Phase 1 | Pending |
| DB-02 | Phase 1 | Pending |
| API-01 | Phase 1 | Pending |
| API-02 | Phase 1 | Pending |
| API-03 | Phase 1 | Pending |
| API-04 | Phase 1 | Pending |
| FE-01 | Phase 1 | Pending |
| FE-02 | Phase 1 | Pending |
| FE-03 | Phase 1 | Pending |
| FE-04 | Phase 1 | Pending |
| FE-05 | Phase 1 | Pending |
| FE-06 | Phase 1 | Pending |
| INF-01 | Phase 1 | Pending |
| INF-02 | Phase 1 | Pending |
| INF-03 | Phase 1 | Pending |

**Coverage:**
- v1 requirements: 15 total
- Mapped to phases: 15
- Unmapped: 0

---
*Requirements defined: 2026-05-08*
*Last updated: 2026-05-08 after switching from PostgreSQL to SQLite*
