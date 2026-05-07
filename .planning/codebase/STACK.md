# Technology Stack
> Generated: 2026-05-07
> Focus: tech
> Project: Simple Kanban Practice App

**Analysis Date:** 2026-05-07

## Languages

**Primary:**
- JavaScript (ES6+) — Backend (`server.js`) and frontend (`index.html` inline `<script>`)

**Secondary:**
- SQL — Direct queries against PostgreSQL via `pg` library
- HTML/CSS — Single `index.html` with inline styles

## Runtime

**Environment:**
- Node.js (version TBD — any LTS version supporting ES6+)

**Package Manager:**
- npm
- Lockfile: Not yet present (will be generated on `npm install`)

## Frameworks

**Core:**
- Express ^4.x — HTTP server, static file serving, JSON body parsing, 4 CRUD route handlers

**Testing:**
- None — explicitly excluded per spec

**Build/Dev:**
- None — no bundler, no transpiler, no build step. Run directly with `node server.js`

## Key Dependencies

**Production (only two allowed per CONST-006):**
- `express` ^4.x — Web server framework. Handles routing (`GET /tasks`, `POST /tasks`, `PUT /tasks/:id`, `DELETE /tasks/:id`), `express.json()` middleware for parsing request bodies, and `express.static(__dirname)` for serving `index.html`
- `pg` ^8.x — PostgreSQL client (`node-postgres`). Direct connection with raw SQL queries. No ORM, no query builder, no connection pooling beyond pg defaults

**Dev Dependencies:**
- None — no testing frameworks, no linters, no formatters

## Key *Excluded* Dependencies

Per `simple.md` and CONST-006, these are explicitly forbidden:
- No ORM (no Sequelize, Prisma, Knex)
- No middleware libraries (no helmet, morgan, cors)
- No template engines (no EJS, Pug)
- No frontend frameworks (no React, Vue, Angular)
- No build tools (no Webpack, Vite, Babel)
- No testing tools (no Jest, Mocha, Vitest)
- No linting/formatting (no ESLint, Prettier)

## Configuration

**Environment:**
- Hardcoded — no `.env`, no config files, no environment variables
- DB connection constants live directly in `server.js`
- Host: `localhost`, Port: `5432`, User: `postgres`, Password: `postgres`, Database: `kanban_practice`

**Build:**
- No build configuration — zero build step
- `package.json` contains only `name`, `version`, and `dependencies`

## Platform Requirements

**Development:**
- Node.js installed locally
- PostgreSQL running locally on port 5432
- A database named `kanban_practice` must exist
- A `tasks` table must be created before running the app

**Production:**
- Not applicable — local-only practice app (CONST-008)
- No deployment, no Docker, no CI/CD, no hosting

## Database

**Engine:**
- PostgreSQL (local instance)

**Schema:**
- Single table: `tasks`
  - `id SERIAL PRIMARY KEY`
  - `title VARCHAR(255) NOT NULL`
  - `status VARCHAR(20) DEFAULT 'todo'`
  - `created_at TIMESTAMP DEFAULT NOW()`
- Allowed `status` values: `'todo'`, `'in_progress'`, `'done'`

**Connection:**
- Direct `pg.Client` connection (not a pool)
- Hardcoded credentials in `server.js`

---

*Stack analysis: 2026-05-07*
