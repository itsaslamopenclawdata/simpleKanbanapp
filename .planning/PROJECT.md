# Simple Kanban Practice App

## What This Is

A minimal Kanban board for local practice — learn full-stack basics by building a working task board with Node.js, Express, and PostgreSQL. Three columns (To Do, In Progress, Done), CRUD operations, zero production complexity.

## Core Value

Working end-to-end Kanban board — add, move, and delete tasks across three columns in a browser.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] User can create a new task with a title
- [ ] Tasks render in three columns based on status (todo, in_progress, done)
- [ ] User can change task status via dropdown
- [ ] User can delete a task
- [ ] Tasks persist in PostgreSQL and reload on page refresh

### Out of Scope

- Authentication/authorization — local practice only
- Input validation/sanitization — not production
- Error handling — keep it minimal
- Logging — not needed for practice
- Pagination — small dataset expected
- Environment variables — hardcoded credentials acceptable
- Docker — local PostgreSQL only
- Testing — out of scope for practice
- CI/CD — no pipeline needed
- CORS configuration — allow all origins
- Drag-and-drop — dropdown-based status change only
- Animations or external CSS frameworks
- Mobile responsiveness

## Context

- **Purpose:** Learning practice — understand full-stack CRUD with Express + PostgreSQL
- **Prior work:** Spec (Docs/Spec.md) and codebase map (.planning/codebase/) are complete
- **Skill level:** Building to learn; every line should be understandable
- **Database:** Local PostgreSQL with hardcoded credentials (host=localhost, port=5432, user=postgres, password=postgres, database=kanban_practice)

## Constraints

- **Tech stack:** Node.js + Express + pg (node-postgres) — locked per spec
- **Frontend:** Single index.html with inline CSS and vanilla JS — no frameworks, no build tools
- **File count:** Three files total (server.js, index.html, package.json) — ~150 lines
- **API:** Exactly 4 REST endpoints (GET/POST/PUT/DELETE on /tasks)
- **Database:** Single `tasks` table with columns: id SERIAL, title VARCHAR(255), status VARCHAR(20), created_at TIMESTAMP
- **Status values:** 'todo', 'in_progress', 'done' only
- **Scope:** Local practice only — zero production features

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Node.js over Python | JavaScript throughout, simpler tooling | — Pending |
| Refetch-all-after-mutation | Simplest state management, fine for practice scale | — Pending |
| Hardcoded DB credentials | Local practice, no env var complexity | — Pending |
| Single-file frontend | Spec mandates — keeps it minimal | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-07 after initialization*
