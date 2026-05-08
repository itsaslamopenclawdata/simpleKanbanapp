# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm install          # Install dependencies (express, better-sqlite3)
node server.js       # Start server on http://localhost:3000
```

No build step, no tests, no linting. The app runs directly with Node.js.

## Architecture

Single-file full-stack app: **server.js** (backend + DB) + **index.html** (frontend).

**server.js** — Express server on port 3000 that:
- Opens/creates `kanban.db` (SQLite via better-sqlite3) on startup
- Creates `tasks` table if not exists, seeds 3 sample rows if empty
- Serves static files from project root (including index.html)
- 4 CRUD endpoints: `GET/POST /tasks`, `PUT/DELETE /tasks/:id`

**index.html** — Single-page Kanban board with inline CSS + vanilla JS:
- 3-column flexbox layout (To Do / In Progress / Done)
- `fetchTasks()` on load groups tasks by status into columns
- Refetch-all-after-mutation pattern: every add/update/delete calls `fetchTasks()`

## Key Details

- **Database:** SQLite via better-sqlite3 (synchronous API). File `kanban.db` auto-created on first run. Status values: `'todo'`, `'in_progress'`, `'done'`.
- **Frontend:** No frameworks, no build tools. All JS uses `fetch()` with `.then()` (no async/await).
- **Express 5** is used (not Express 4) — route syntax is the same but some middleware behavior differs.
- **Git branches:** `loop/session-1` (scaffolding), `loop/session-2` (API), `loop/session-3` (frontend), `main` (merged). Worktrees at `.worktrees/session-N/`.
- **Windows PATH issue:** Git Bash on this machine can't find `git`, `node`, etc. without: `export PATH="/c/Program Files/Git/bin:/c/Program Files/Git/cmd:/c/Program Files/Git/usr/bin:/c/Program Files/nodejs:$PATH"`

## Scope

This is a **learning practice app** — deliberately minimal. No auth, no validation, no error handling, no logging, no tests, no env vars. See `.planning/REQUIREMENTS.md` for the full spec and out-of-scope list.
