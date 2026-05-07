# CONCERNS
> Generated: 2026-05-07
> Focus: concerns
> Project: Simple Kanban Practice App

---

## Security Concerns

### SEC-001: Hardcoded Database Credentials in Source Code

- **Severity**: HIGH
- **Category**: Security
- **Status**: INTENTIONAL (spec-mandated via `CONST-004`, `DEC-005`)
- **Description**: Database connection parameters (`host=localhost`, `port=5432`, `user=postgres`, `password=postgres`, `database=kanban_practice`) are hardcoded directly in `server.js`. No environment variables or config files are used. The password `postgres` is committed to version control in plain text.
- **Files**: `server.js` (to be created)
- **Impact**: Anyone with repo access has database credentials. If this repo is ever pushed to a public remote, credentials are exposed.
- **Spec rationale**: "Throwaway practice app running on localhost. Production patterns would obscure the fundamentals being learned." (`DEC-005`)
- **If extending beyond practice**: Extract to `.env` using `dotenv`. Add `.env` to `.gitignore`. Never commit credentials.

### SEC-002: SQL Injection via Unsanitized User Input

- **Severity**: HIGH
- **Category**: Security
- **Status**: INTENTIONAL (spec-mandated via `CONST-005`)
- **Description**: The `POST /tasks` endpoint accepts a `title` string from the request body. The `PUT /tasks/:id` endpoint accepts a `status` string. With no input validation or sanitization, raw user input flows into SQL queries. If string concatenation or template literals are used instead of parameterized queries, this creates a direct SQL injection vector.
- **Files**: `server.js` (to be created)
- **Impact**: An attacker could execute arbitrary SQL, drop tables, or read all data.
- **Mitigation available within spec constraints**: The `pg` library supports parameterized queries (`$1`, `$2` placeholders) without any additional dependencies. This is not "validation" -- it is the standard `pg` query pattern. The builder MUST use parameterized queries to avoid SQL injection even in this practice context.
- **Priority**: Enforce during build. Parameterized queries are the idiomatic `pg` usage, not an added abstraction.

### SEC-003: CORS Allows All Origins

- **Severity**: MEDIUM
- **Category**: Security
- **Status**: INTENTIONAL (spec-mandated via `CONST-005`)
- **Description**: No CORS configuration is specified. By default, `express.static` and the API endpoints serve all origins. Any website could make requests to the local server if the user visits a malicious page while the app is running.
- **Files**: `server.js` (to be created)
- **Impact**: CSRF-like attacks from malicious sites while the dev server is running.
- **Acceptable because**: Local-only practice app, no sensitive data, server is ephemeral.

### SEC-004: No Authentication or Authorization

- **Severity**: MEDIUM
- **Category**: Security
- **Status**: INTENTIONAL (spec-mandated via `CONST-005`)
- **Description**: All four endpoints (`GET`, `POST`, `PUT`, `DELETE` on `/tasks`) are fully open. Anyone who can reach `localhost:3000` can read, create, modify, and delete all tasks.
- **Files**: `server.js` (to be created)
- **Impact**: No user isolation, no audit trail, no protection against destructive operations.
- **Acceptable because**: Single-user local practice tool, no multi-user requirement.

---

## Architecture Concerns

### ARCH-001: No Error Handling -- Server Crashes on Database Failure

- **Severity**: MEDIUM
- **Category**: Architecture
- **Status**: INTENTIONAL (spec-mandated via `CONST-005`)
- **Description**: The spec explicitly excludes error handling. If PostgreSQL is not running, the connection fails, or a query returns an unexpected result, the Express server will throw an unhandled exception and crash. No `try/catch`, no `.catch()` on promises, no Express error middleware.
- **Files**: `server.js` (to be created)
- **Impact**: Any transient DB issue requires a manual server restart. Users see raw error stacks or connection refused errors in the browser.
- **Practical note**: Even for a practice app, the developer experience degrades when the server silently crashes. Consider adding a `.catch()` that at least logs to console -- this is not "error handling infrastructure", it is visibility into what failed.

### ARCH-002: Refetch-All Pattern Does Not Scale

- **Severity**: LOW
- **Category**: Architecture
- **Status**: INTENTIONAL (spec-mandated via `DEC-004`)
- **Description**: After every add, update, or delete operation, the frontend refetches the entire task list via `GET /tasks` and re-renders all columns from scratch. No optimistic updates, no client-side state cache, no delta updates.
- **Files**: `index.html` (to be created)
- **Impact**: With hundreds of tasks, each mutation triggers a full re-fetch and full DOM rebuild. Causes visible flicker and unnecessary network traffic.
- **Acceptable because**: Practice app with expected data volume of tens of tasks. The round-trip is the learning objective (`DEC-004`).

### ARCH-003: No Connection Pooling Configuration

- **Severity**: LOW
- **Category**: Architecture
- **Status**: ADVISORY
- **Description**: The `pg` library defaults to a pool size of 10 connections. The spec does not mention configuring `Pool` vs `Client`. If the builder uses `pg.Client` (single connection), concurrent requests may serialize. If `pg.Pool` is used with defaults, the pool may hold idle connections.
- **Files**: `server.js` (to be created)
- **Impact**: Minimal for a single-user local app. A learning opportunity to understand `pg.Pool` vs `pg.Client`.
- **Recommendation**: Use `pg.Pool` with defaults. It is the standard `pg` pattern and handles the request-per-endpoint model correctly.

### ARCH-004: Single-File Frontend Will Grow Unwieldy

- **Severity**: LOW
- **Category**: Architecture
- **Status**: INTENTIONAL (spec-mandated via `CONST-007`)
- **Description**: All HTML structure, inline CSS (~50+ lines), and vanilla JavaScript (fetch logic, DOM manipulation, event handlers, rendering) live in a single `index.html` file. The spec targets ~150 total lines across all files, meaning `index.html` likely contains 80-100 lines of mixed HTML/CSS/JS.
- **Files**: `index.html` (to be created)
- **Impact**: Difficult to navigate as a learning reference. HTML structure, styling, and behavior are interleaved.
- **Acceptable because**: The three-file constraint (`CONST-007`) is intentional to minimize file count. Adding features beyond spec scope would make this file unmaintainable.

### ARCH-005: No Input Validation on API Endpoints

- **Severity**: MEDIUM
- **Category**: Architecture
- **Status**: INTENTIONAL (spec-mandated via `CONST-005`)
- **Description**: `POST /tasks` accepts any JSON body without validating that `title` exists, is a string, or is within length limits. `PUT /tasks/:id` accepts any `status` value without checking it is one of `todo`, `in_progress`, `done`. `DELETE /tasks/:id` does not verify the task exists.
- **Files**: `server.js` (to be created)
- **Impact**: Sending `{}` to `POST /tasks` inserts a task with `title=NULL` (violates `NOT NULL` constraint -- DB error, server crash). Sending `{ "status": "banana" }` to `PUT /tasks/:id` stores an invalid status. Sending `DELETE /tasks/9999` to a non-existent task returns success regardless.
- **Practical note**: The `NOT NULL` constraint on `title` will cause a database error if `title` is missing, but this surfaces as an unhandled crash, not a helpful error message.

---

## Data Concerns

### DATA-001: No Database-Level CHECK Constraint on Status Enum

- **Severity**: MEDIUM
- **Category**: Data
- **Status**: ADVISORY
- **Description**: The `status` column is `VARCHAR(20)` with no `CHECK` constraint. The allowed values (`todo`, `in_progress`, `done`) are defined in the spec but not enforced at the database level. Any string up to 20 characters can be stored.
- **Files**: Database schema (created via `CREATE TABLE` statement)
- **Impact**: Invalid status values can be persisted, causing tasks to disappear from the frontend (they would not match any column filter). Data integrity relies entirely on frontend cooperation.
- **Recommendation**: Consider adding `CHECK (status IN ('todo', 'in_progress', 'done'))` to the `CREATE TABLE` statement. This is a single-line addition to the DDL, requires no extra dependencies, and prevents data corruption regardless of what the API accepts. However, the spec's `CONST-005` excludes validation, so this is advisory only.
- **Alternative**: Use a PostgreSQL `ENUM` type instead of `VARCHAR(20)`. Same single-line change, stronger enforcement.

### DATA-002: No Data Migration Strategy

- **Severity**: LOW
- **Category**: Data
- **Status**: ADVISORY
- **Description**: The database is created manually via `createdb kanban_practice` and a `CREATE TABLE tasks` statement. There is no migration tool, no version tracking, and no `ALTER TABLE` path. Any schema change requires dropping and recreating the table, losing all data.
- **Files**: None (manual terminal commands)
- **Impact**: If the schema evolves, existing data is lost. Acceptable for a practice app.
- **If extending**: Introduce a simple migration script or use `db-migrate` / `knex` migrations.

### DATA-003: No Backup Mechanism

- **Severity**: LOW
- **Category**: Data
- **Status**: ADVISORY
- **Description**: No `pg_dump`, no automated backups, no replication. Data exists only in the local PostgreSQL instance.
- **Impact**: Accidental `DROP TABLE` or database corruption loses all tasks permanently.
- **Acceptable because**: Practice data is disposable by definition.

### DATA-004: Serial IDs Create Gaps on Delete

- **Severity**: LOW
- **Category**: Data
- **Status**: ADVISORY
- **Description**: `SERIAL` generates monotonically increasing IDs. Deleting tasks creates gaps (1, 2, 5, 8...). The frontend displays these IDs nowhere, so gaps are invisible to the user.
- **Impact**: None for the practice app. Gaps are normal PostgreSQL behavior and not a real concern.

---

## Development Concerns

### DEV-001: No .gitignore File

- **Severity**: HIGH
- **Category**: Development
- **Status**: ADVISORY
- **Description**: No `.gitignore` exists in the repository. Without one, `node_modules/` (created by `npm install`) will be committed to git. The `node_modules` directory typically contains tens of thousands of files and hundreds of megabytes.
- **Files**: `.gitignore` (missing)
- **Impact**: Bloats the git repository, slows clone/push/pull operations, and may expose dependency vulnerabilities.
- **Recommendation**: Add a `.gitignore` with at minimum:
  ```
  node_modules/
  ```
  This is a development hygiene concern, not a spec violation. The spec does not prohibit a `.gitignore`.

### DEV-002: No Hot Reload or Auto-Restart for Development

- **Severity**: LOW
- **Category**: Development
- **Status**: INTENTIONAL (spec-mandated via `CONST-006`)
- **Description**: Running `node server.js` is a one-shot execution. Any code change requires manually stopping the server (Ctrl+C) and restarting. Tools like `nodemon` would provide auto-restart but are excluded by the minimal dependency constraint.
- **Impact**: Slower development feedback loop. Each iteration requires manual restart.
- **Acceptable because**: Only `express` and `pg` are allowed as dependencies (`CONST-006`). Adding `nodemon` as a devDependency would be reasonable but violates the strict reading of the constraint.

### DEV-003: No Linting or Formatting Configuration

- **Severity**: LOW
- **Category**: Development
- **Status**: INTENTIONAL (spec-mandated via `CONST-006`)
- **Description**: No ESLint, no Prettier, no Biome. Code style consistency relies entirely on the builder.
- **Impact**: Inconsistent formatting across the three files. Minor for ~150 lines.
- **Acceptable because**: Adding linting tools would add configuration files, violating the three-file constraint (`CONST-007`).

### DEV-004: No Test Infrastructure

- **Severity**: MEDIUM
- **Category**: Development
- **Status**: INTENTIONAL (spec-mandated via `CONST-005`)
- **Description**: No test framework, no test files, no test commands. Verification is entirely manual (open browser, try the operations).
- **Impact**: Regressions during development are caught only by manual testing. For a ~150 line app, this is acceptable.
- **Acceptable because**: The spec explicitly excludes testing.

### DEV-005: No package-lock.json Mentioned

- **Severity**: LOW
- **Category**: Development
- **Status**: ADVISORY
- **Description**: The spec mentions `npm install` to install dependencies but does not mention committing `package-lock.json`. This file is generated by `npm install` and pins exact dependency versions.
- **Files**: `package-lock.json` (to be generated)
- **Impact**: Without `package-lock.json`, different `npm install` runs may resolve different sub-dependency versions.
- **Recommendation**: Commit `package-lock.json` alongside `package.json`. It is not an extra source file -- it is a lockfile generated by npm.

---

## Spec Ambiguities

### SPEC-001: Missing DDL Statement Location

- **Severity**: LOW
- **Category**: Development
- **Status**: ADVISORY
- **Description**: The spec describes the table schema but does not specify whether the `CREATE TABLE` statement lives in a SQL file, a setup script, or is run manually via `psql`. The three-file constraint (`CONST-007`) leaves no room for a `setup.sql` file.
- **Recommendation**: Provide the DDL as a terminal command in the README or setup instructions (the spec's "3 simple terminal commands" requirement addresses this).

### SPEC-002: Response Shape for GET /tasks on Empty Database

- **Severity**: LOW
- **Category**: Architecture
- **Status**: ADVISORY
- **Description**: `REQ-api-get-tasks` specifies the response as `{ tasks: [...] }` and notes it returns an empty array initially. This is clear. However, the frontend must handle this case correctly -- an empty array still triggers column rendering with zero cards.
- **Impact**: Minimal if the frontend iterates over the array. An edge case to verify during manual testing.

### SPEC-003: PUT /tasks/:id for Non-Existent Task

- **Severity**: LOW
- **Category**: Architecture
- **Status**: ADVISORY
- **Description**: The spec does not define behavior when `PUT /tasks/:id` or `DELETE /tasks/:id` targets a non-existent ID. Without error handling, the SQL `UPDATE`/`DELETE` affects zero rows, and the endpoint returns a success-like response.
- **Impact**: Frontend silently succeeds. No user-visible error. Acceptable for practice.

---

## Summary Matrix

| ID | Severity | Category | Status | Short Description |
|----|----------|----------|--------|-------------------|
| SEC-001 | HIGH | Security | INTENTIONAL | Hardcoded DB credentials in source |
| SEC-002 | HIGH | Security | INTENTIONAL | SQL injection via unsanitized input |
| SEC-003 | MEDIUM | Security | INTENTIONAL | CORS allows all origins |
| SEC-004 | MEDIUM | Security | INTENTIONAL | No authentication/authorization |
| ARCH-001 | MEDIUM | Architecture | INTENTIONAL | No error handling, server crashes |
| ARCH-002 | LOW | Architecture | INTENTIONAL | Refetch-all pattern |
| ARCH-003 | LOW | Architecture | ADVISORY | No connection pooling config |
| ARCH-004 | LOW | Architecture | INTENTIONAL | Single-file frontend |
| ARCH-005 | MEDIUM | Architecture | INTENTIONAL | No input validation on endpoints |
| DATA-001 | MEDIUM | Data | ADVISORY | No CHECK constraint on status |
| DATA-002 | LOW | Data | ADVISORY | No migration strategy |
| DATA-003 | LOW | Data | ADVISORY | No backup mechanism |
| DATA-004 | LOW | Data | ADVISORY | Serial ID gaps on delete |
| DEV-001 | HIGH | Development | ADVISORY | No .gitignore (node_modules risk) |
| DEV-002 | LOW | Development | INTENTIONAL | No hot reload |
| DEV-003 | LOW | Development | INTENTIONAL | No linting/formatting |
| DEV-004 | MEDIUM | Development | INTENTIONAL | No test infrastructure |
| DEV-005 | LOW | Development | ADVISORY | No package-lock.json mention |
| SPEC-001 | LOW | Development | ADVISORY | DDL statement location unclear |
| SPEC-002 | LOW | Architecture | ADVISORY | Empty GET response edge case |
| SPEC-003 | LOW | Architecture | ADVISORY | PUT/DELETE on non-existent ID |

### Build-Time Action Items

These concerns should be addressed during the build phase, even for a practice app:

1. **DEV-001**: Create a `.gitignore` with `node_modules/` before running `npm install`. This is development hygiene, not a spec violation.
2. **SEC-002**: Use parameterized queries (`$1`, `$2` placeholders) in all `server.js` SQL statements. This is idiomatic `pg` usage, not added complexity.
3. **DATA-001**: Consider adding `CHECK (status IN ('todo', 'in_progress', 'done'))` to the `CREATE TABLE` DDL. Single line, no extra files.

### Not Action Items

These are intentionally excluded by spec and should NOT be added:

- Environment variables / config files (violates `CONST-004`)
- Express error middleware (violates `CONST-005`)
- CORS configuration (violates `CONST-005`)
- Input validation middleware (violates `CONST-005`)
- Authentication layer (violates `CONST-005`)
- Test framework (violates `CONST-005`)
- Additional npm dependencies (violates `CONST-006`)
- Additional files beyond three (violates `CONST-007`)

---

*Concerns audit: 2026-05-07*
