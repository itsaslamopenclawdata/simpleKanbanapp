# Coding Conventions

> Generated: 2026-05-07
> Focus: quality
> Project: Simple Kanban Practice App

**Analysis Date:** 2026-05-07

## General Philosophy

This is a minimal practice application with ~150 lines total across three files. The conventions are defined by what the spec mandates and what it explicitly excludes. There is no existing code to pattern-match -- every convention below is prescriptive for new code.

**Spec source:** `Docs/Spec.md`
**Constraints source:** `.planning/intel/constraints.md`
**Decisions source:** `.planning/intel/decisions.md`

## Naming Patterns

**Files:**
- Use flat file names in the project root. No directories, no nesting.
- `server.js` -- Express backend
- `index.html` -- Single frontend file (HTML + inline CSS + vanilla JS)
- `package.json` -- Dependencies only

**Functions (server.js):**
- Use `camelCase` for function names and variable names.
- Handler functions can be inline arrow functions passed directly to Express route definitions.

**Variables (server.js and index.html):**
- Use `camelCase` for all JavaScript variables.
- SQL column names use `snake_case` (`id`, `title`, `status`, `created_at`) -- this is dictated by PostgreSQL convention, not JS convention.

**Types:**
- No TypeScript. No JSDoc. No type annotations. Pure JavaScript.

## Code Style

**Formatting:**
- No formatter configured. No `.prettierrc`, no `.eslintrc`.
- Keep code compact but readable. The entire app targets ~150 lines.

**Linting:**
- No linter. No linting rules enforced.
- Rely on the spec's exclusion list instead: if the spec says "no X", do not write X.

## Import Organization

**Server (`server.js`):**
- Only two imports: `express` and `pg` (specifically `Pool` from `pg`).
- Order: built-in/Node modules first, then npm packages. In practice this is just:
  ```js
  const express = require('express');
  const { Pool } = require('pg');
  ```

**Frontend (`index.html`):**
- No imports. No `<script src="...">` tags. All JS is inline in a `<script>` tag within `index.html`.
- Use browser-native `fetch()` for API calls.

**Path Aliases:**
- None. No build tools, no bundler, no alias resolution.

## Error Handling

**Explicitly excluded.** The spec states under STRICTLY EXCLUDE: "error handling."

Do not write:
- `try/catch` blocks around database queries
- `.catch()` handlers on fetch calls
- Error middleware in Express
- HTTP error status codes (500, 400, etc.)
- Input validation or sanitization

The only acceptable response pattern is sending query results directly:
```js
// Acceptable
app.get('/tasks', async (req, res) => {
  const result = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC');
  res.json(result.rows);
});
```

## Logging

**Explicitly excluded.** No `console.log`, no logging libraries, no request logging middleware.

## Comments

**Explicitly excluded.** The spec states: "No excessive comments or explanations."

Do not write:
- Block comments explaining what a function does
- Inline comments explaining SQL queries
- JSDoc/TSDoc annotations
- TODO/FIXME markers

The code should be self-documenting by virtue of being simple and short.

## Function Design

**Size:** Keep functions short. The entire server is ~50-60 lines. Individual route handlers should be 2-5 lines each.

**Parameters:**
- Express route handlers receive `(req, res)`.
- No middleware, no parameter destructuring beyond `req.body` and `req.params`.

**Return Values:**
- Express routes: always `res.json(...)` for API endpoints.
- Frontend functions: no return value pattern mandated. Functions re-render the DOM directly after each mutation.

## Module Design

**No modules.** The entire backend is one file (`server.js`). The entire frontend is one file (`index.html`). No `require()` of local files, no `module.exports`, no ES module `import/export`.

**Exports:** Not applicable. No modules to export from.

**Barrel Files:** Not applicable.

## CSS Conventions

**Inline only.** All CSS lives in a `<style>` tag within `index.html`. No external stylesheets, no CSS frameworks, no CSS-in-JS.

- No class naming convention (BEM, utility classes, etc.) required.
- Use simple element selectors or minimal class names.
- Basic layout only: three-column Kanban board, task cards, input area.

## JavaScript Conventions (Frontend)

**Vanilla only.** No frameworks, no libraries, no CDN imports.

- Use `document.getElementById()` or `document.querySelector()` for DOM access.
- Use `fetch()` for API calls.
- Use `innerHTML` or `createElement()`/`appendChild()` for rendering.
- After every add/update/delete: call `fetch('/tasks')` and re-render the entire board.

**State management pattern:**
- No client-side state store.
- Refetch all tasks from the server after every mutation (DEC-004).
- This is the single most important frontend convention: always re-fetch, never cache.

```js
// The pattern for every mutation:
async function addTask() {
  await fetch('/tasks', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({title: input.value}) });
  loadTasks(); // re-fetch everything
}
```

## API Conventions

**RESTful, JSON-only.** Four endpoints, full stop.

| Method | Path | Request Body | Response |
|--------|------|-------------|----------|
| GET | `/tasks` | None | JSON array of task objects |
| POST | `/tasks` | `{ "title": "string" }` | JSON task object |
| PUT | `/tasks/:id` | `{ "status": "string" }` | JSON task object |
| DELETE | `/tasks/:id` | None | JSON or 200 OK |

**Status values (hardcoded enum):**
- `'todo'`
- `'in_progress'`
- `'done'`

These are the only valid values for the `status` column. Do not add more, do not make them configurable.

## Database Conventions

**Raw SQL only.** No ORM, no query builder. Write SQL strings directly.

**Connection:**
- Hardcoded in `server.js`:
  ```js
  const pool = new Pool({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'postgres',
    database: 'kanban_practice'
  });
  ```
- No environment variables (CONST-004).
- No connection string abstraction.

**Query style:**
- Use `pool.query(sql)` for all operations.
- Use parameterized queries (`$1`, `$2`) for INSERT and UPDATE to prevent SQL injection even though validation is excluded:
  ```js
  pool.query('INSERT INTO tasks (title) VALUES ($1)', [title]);
  ```

## CORS

- Allow all origins. Use `app.use(require('cors')())` -- but note `cors` is not in the allowed dependencies list (CONST-006: only `express` and `pg`).
- Instead, set CORS header manually:
  ```js
  app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
  });
  ```
- Or simply serve `index.html` via `express.static(__dirname)` from the same origin, avoiding CORS entirely.

## Explicitly Excluded (Do Not Add)

The following are explicitly out of scope per the spec. Do not add them even if they seem like good practice:

- Authentication or authorization
- Input validation or sanitization
- Error handling (try/catch, error middleware, status codes)
- Logging (console.log, morgan, winston)
- Pagination
- Environment variables or config files
- Docker or containerization
- Testing framework or test files
- CI/CD pipeline
- Drag-and-drop interactions
- Animations or transitions
- External dependencies beyond `express` and `pg`
- Additional database tables
- Additional API endpoints beyond the four specified

---

*Convention analysis: 2026-05-07*
