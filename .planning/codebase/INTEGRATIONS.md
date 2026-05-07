# External Integrations
> Generated: 2026-05-07
> Focus: tech
> Project: Simple Kanban Practice App

**Analysis Date:** 2026-05-07

## APIs & External Services

**None.** The application has zero third-party API integrations. No payment providers, no email services, no analytics, no social login. The entire app is self-contained: browser talks to Express, Express talks to local PostgreSQL.

## Data Storage

**Databases:**
- PostgreSQL (local instance)
  - Client library: `pg` ^8.x (`node-postgres`)
  - Connection: Hardcoded in `server.js` — `host: 'localhost'`, `port: 5432`, `user: 'postgres'`, `password: 'postgres'`, `database: 'kanban_practice'`
  - Schema: Single `tasks` table (4 columns: `id`, `title`, `status`, `created_at`)
  - No connection pooling (uses `pg.Client` directly)
  - No migrations system — table created manually via `psql` or SQL command

**File Storage:**
- Local filesystem only — Express serves `index.html` via `express.static(__dirname)`

**Caching:**
- None — every frontend mutation triggers a fresh `GET /tasks` round-trip (DEC-004)

## Authentication & Identity

**Auth Provider:**
- None — explicitly excluded per CONST-005
- No login, no sessions, no tokens, no user accounts
- The app is accessible to anyone at `http://localhost:3000`

## Monitoring & Observability

**Error Tracking:**
- None — no error handling of any kind (CONST-005)

**Logs:**
- None — no logging library, no `morgan`, no `console.log` in production code

## CI/CD & Deployment

**Hosting:**
- Local only — `node server.js` on `http://localhost:3000` (CONST-008)
- No Docker, no cloud hosting, no reverse proxy

**CI Pipeline:**
- None — no automated testing, no linting, no build checks

## Environment Configuration

**Required env vars:**
- None — all configuration is hardcoded

**Secrets location:**
- Database credentials are hardcoded directly in `server.js` source code
  - `user: 'postgres'`, `password: 'postgres'`
  - Acceptable only because this is a throwaway local practice app (DEC-005)

**Database setup:**
- PostgreSQL must be running locally with a `kanban_practice` database
- Table creation command (manual):
  ```sql
  CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'todo',
    created_at TIMESTAMP DEFAULT NOW()
  );
  ```

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## CORS

**Policy:** Allow all origins — no `cors` package, no CORS configuration. For a local practice app this works because `express.static` serves the frontend from the same origin as the API. If the frontend were served from a different port, a CORS middleware would be needed, but the spec explicitly excludes this (CONST-005).

---

*Integration audit: 2026-05-07*
