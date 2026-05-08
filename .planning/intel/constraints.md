# Constraints

Source: Docs/Spec.md (SPEC)

## CONST-001: Stack locked

- **Type:** protocol
- **Title:** Node.js + Express + pg, vanilla HTML/CSS/JS
- **Content:** The stack is fixed: Node.js with Express and the `pg` library on the backend. Single `index.html` with inline CSS and vanilla JavaScript on the frontend. No React, no Next.js, no frameworks of any kind.
- **source:** Docs/Spec.md

## CONST-002: Single table schema

- **Type:** schema
- **Title:** One PostgreSQL table with 4 columns
- **Content:** Database is limited to a single `tasks` table with columns: `id SERIAL PRIMARY KEY`, `title VARCHAR(255) NOT NULL`, `status VARCHAR(20) DEFAULT 'todo'`, `created_at TIMESTAMP DEFAULT NOW()`. Allowed status values: `'todo'`, `'in_progress'`, `'done'`. No additional tables, no joins, no foreign keys.
- **source:** Docs/Spec.md

## CONST-003: Four endpoints max

- **Type:** api-contract
- **Title:** CRUD endpoints fixed at four
- **Content:** API surface is exactly: `GET /tasks`, `POST /tasks`, `PUT /tasks/:id`, `DELETE /tasks/:id`. All endpoints return JSON. No additional endpoints, no query parameters, no filtering, no pagination.
- **source:** Docs/Spec.md

## CONST-004: Hardcoded DB credentials

- **Type:** schema
- **Title:** localhost:5432, postgres/postgres, database kanban_practice
- **Content:** Database connection uses hardcoded values: host `localhost`, port `5432`, user `postgres`, password `postgres`, database `kanban_practice`. No environment variables, no config files, no connection string abstraction.
- **source:** Docs/Spec.md

## CONST-005: Zero production features

- **Type:** nfr
- **Title:** No auth, validation, error handling, logging, CORS config
- **Content:** Explicitly excluded: authentication, input validation, error handling, logging, pagination, CORS configuration (allow all origins). No drag-and-drop, no animations. This is a learning app, not a production service.
- **source:** Docs/Spec.md

## CONST-006: Minimal dependencies

- **Type:** protocol
- **Title:** Only express and pg
- **Content:** The only npm dependencies allowed are `express` (^4.x) and `pg` (^8.x). No middleware libraries, no ORM, no template engines, no testing frameworks, no linters.
- **source:** Docs/Spec.md

## CONST-007: Three files total

- **Type:** nfr
- **Title:** server.js, index.html, package.json (~150 lines)
- **Content:** The entire application is three files: `server.js`, `index.html`, `package.json`. Total approximately 150 lines of code across all files. No additional files, no directories, no modules.
- **source:** Docs/Spec.md

## CONST-008: Local only, no distribution

- **Type:** nfr
- **Title:** Run locally with node server.js
- **Content:** No deployment, no Docker, no CI/CD, no hosting. The app runs via `node server.js` and is accessed at `http://localhost:3000`.
- **source:** Docs/Spec.md
