# Requirements

Source: Docs/Spec.md (SPEC)

## REQ-database-setup

- **Source PRD:** Docs/Spec.md
- **Description:** A PostgreSQL database named `kanban_practice` must exist with a `tasks` table containing columns: `id` (SERIAL PRIMARY KEY), `title` (VARCHAR(255) NOT NULL), `status` (VARCHAR(20) DEFAULT 'todo'), `created_at` (TIMESTAMP DEFAULT NOW()).
- **Acceptance criteria:**
  - `createdb kanban_practice` succeeds
  - `CREATE TABLE tasks` succeeds
- **Scope:** database
- **source:** Docs/Spec.md

## REQ-server-startup

- **Source PRD:** Docs/Spec.md
- **Description:** Running `node server.js` starts an Express server without errors. The server connects to PostgreSQL on `localhost:5432` with user `postgres`, password `postgres`, database `kanban_practice`.
- **Acceptance criteria:**
  - `node server.js` starts without errors
  - Server serves `index.html` at `GET /` via `express.static(__dirname)`
- **Scope:** server
- **source:** Docs/Spec.md

## REQ-api-get-tasks

- **Source PRD:** Docs/Spec.md
- **Description:** `GET /tasks` returns all tasks from the database as JSON `{ tasks: [...] }`.
- **Acceptance criteria:**
  - Returns an empty array initially: `{ tasks: [] }`
- **Scope:** API
- **source:** Docs/Spec.md

## REQ-api-create-task

- **Source PRD:** Docs/Spec.md
- **Description:** `POST /tasks` with body `{ "title": "string" }` creates a new task with status defaulting to `'todo'`. Returns the created task as `{ task: {...} }`.
- **Acceptance criteria:**
  - `POST /tasks` with `{ "title": "Test" }` creates a task with status `'todo'`
  - Returns the created task object
- **Scope:** API
- **source:** Docs/Spec.md

## REQ-api-update-task

- **Source PRD:** Docs/Spec.md
- **Description:** `PUT /tasks/:id` with body `{ "status": "string" }` updates the task's status. Returns the updated task as `{ task: {...} }`.
- **Acceptance criteria:**
  - `PUT /tasks/1` with `{ "status": "done" }` updates the task status
  - Returns the updated task object
- **Scope:** API
- **source:** Docs/Spec.md

## REQ-api-delete-task

- **Source PRD:** Docs/Spec.md
- **Description:** `DELETE /tasks/:id` removes the task from the database. Returns `{ success: true }`.
- **Acceptance criteria:**
  - `DELETE /tasks/1` removes the task
  - Returns `{ success: true }`
- **Scope:** API
- **source:** Docs/Spec.md

## REQ-frontend-layout

- **Source PRD:** Docs/Spec.md
- **Description:** The frontend displays a text input with "Add Task" button at the top, and three columns below: "To Do", "In Progress", "Done". Each task card shows the title, a `<select>` dropdown with options `todo`, `in_progress`, `done`, and a "Delete" button.
- **Acceptance criteria:**
  - Frontend shows three columns: "To Do", "In Progress", "Done"
- **Scope:** frontend
- **source:** Docs/Spec.md

## REQ-frontend-add-task

- **Source PRD:** Docs/Spec.md
- **Description:** Clicking "Add Task" sends a POST request, then refetches all tasks and re-renders. The new task appears in the "To Do" column.
- **Acceptance criteria:**
  - Adding a task makes it appear in "To Do"
- **Scope:** frontend
- **source:** Docs/Spec.md

## REQ-frontend-move-task

- **Source PRD:** Docs/Spec.md
- **Description:** Changing the dropdown on a task card sends a PUT request with the new status, then refetches all tasks and re-renders. The task moves to the corresponding column.
- **Acceptance criteria:**
  - Changing the dropdown moves the task to the correct column
- **Scope:** frontend
- **source:** Docs/Spec.md

## REQ-frontend-delete-task

- **Source PRD:** Docs/Spec.md
- **Description:** Clicking "Delete" on a task card sends a DELETE request, then refetches all tasks and re-renders. The task disappears from the view.
- **Acceptance criteria:**
  - Deleting a task removes it from the view
- **Scope:** frontend
- **source:** Docs/Spec.md

## REQ-frontend-persist

- **Source PRD:** Docs/Spec.md
- **Description:** Data persists across page refreshes because it is stored in PostgreSQL.
- **Acceptance criteria:**
  - Page refresh preserves data (it is in PostgreSQL)
- **Scope:** frontend, database
- **source:** Docs/Spec.md

## REQ-page-load-render

- **Source PRD:** Docs/Spec.md
- **Description:** On page load, the frontend fetches all tasks via `GET /tasks` and renders cards into the correct columns based on status.
- **Acceptance criteria:**
  - All existing tasks appear in the correct columns on page load
- **Scope:** frontend
- **source:** Docs/Spec.md
