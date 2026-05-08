# Decisions

Source: Docs/Spec.md (SPEC)

## DEC-001: Stack — Node.js + Express + pg

- **Status:** proposed (not locked)
- **Scope:** full application
- **Decision:** Use Node.js with Express and the `pg` library for the server. Single `index.html` with inline CSS and vanilla JavaScript for the frontend. No frameworks, no build tools.
- **Rationale:** Express exposes every HTTP request/response directly. No decorators, no dependency injection, no magic. `pg` library forces writing raw SQL queries against PostgreSQL. Vanilla JS forces understanding of `fetch()`, DOM manipulation, and event listeners.
- **Alternatives rejected:** Python + FastAPI + psycopg2 (abstractions hide HTTP plumbing); Express with 4-file structure (adds separation of concerns that obscures the learning goal).
- **source:** Docs/Spec.md

## DEC-002: Single PostgreSQL table

- **Status:** proposed (not locked)
- **Scope:** database schema
- **Decision:** One table `tasks` with columns: `id SERIAL PRIMARY KEY`, `title VARCHAR(255) NOT NULL`, `status VARCHAR(20) DEFAULT 'todo'`, `created_at TIMESTAMP DEFAULT NOW()`. Allowed statuses: `'todo'`, `'in_progress'`, `'done'`.
- **Rationale:** Single-table CRUD teaches HTTP-to-SQL mapping directly. No ORM, no abstraction layer. Each HTTP verb maps to one SQL operation.
- **source:** Docs/Spec.md

## DEC-003: Four CRUD endpoints, no more

- **Status:** proposed (not locked)
- **Scope:** API surface
- **Decision:** Exactly four endpoints: `GET /tasks`, `POST /tasks`, `PUT /tasks/:id`, `DELETE /tasks/:id`. All return JSON. Server serves `index.html` via `express.static(__dirname)`.
- **Rationale:** Minimum viable CRUD. Each endpoint demonstrates one HTTP verb and one SQL operation.
- **source:** Docs/Spec.md

## DEC-004: Refetch-after-mutation pattern

- **Status:** proposed (not locked)
- **Scope:** frontend behavior
- **Decision:** Every add/update/delete triggers a fresh `GET /tasks`. No optimistic updates, no client-side state cache.
- **Rationale:** The round-trip IS the lesson. Each mutation demonstrates the full request-response cycle.
- **source:** Docs/Spec.md

## DEC-005: Hardcoded DB credentials, zero production features

- **Status:** proposed (not locked)
- **Scope:** configuration, security, error handling
- **Decision:** DB credentials hardcoded as `localhost:5432`, `postgres/postgres`, database `kanban_practice`. No auth, no validation, no error handling, no logging, no pagination, no CORS configuration (allow all origins). No external dependencies beyond `express` and `pg`.
- **Rationale:** Throwaway practice app running on localhost. Production patterns would obscure the fundamentals being learned.
- **source:** Docs/Spec.md

## DEC-006: Three-file structure (~150 lines total)

- **Status:** proposed (not locked)
- **Scope:** project layout
- **Decision:** Three files: `server.js` (Express server with pg connection and 4 CRUD endpoints), `index.html` (single HTML file with inline CSS + vanilla JS + 3-column layout), `package.json` (dependencies: `express` and `pg` only).
- **Rationale:** Minimum file count keeps every line of code visible and traceable to a concept.
- **source:** Docs/Spec.md
