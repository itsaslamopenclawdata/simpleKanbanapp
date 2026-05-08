Generate a complete, minimal Kanban board app strictly for local practice. Follow these exact constraints:

🎯 SCOPE: Very simple frontend, very simple backend, local PostgreSQL only. Zero production features.

📦 STACK:
- Backend: Node.js + Express + `pg` library (OR Python + FastAPI + `psycopg2` – pick ONE and stick to it)
- Frontend: Single `index.html` file with vanilla HTML, inline CSS, and vanilla JS
- Database: Local PostgreSQL

🗄️ DATABASE:
- Single table: `tasks`
- Columns: `id SERIAL PRIMARY KEY`, `title VARCHAR(255) NOT NULL`, `status VARCHAR(20) DEFAULT 'todo'`, `created_at TIMESTAMP DEFAULT NOW()`
- Allowed statuses: `'todo'`, `'in_progress'`, `'done'`

🔌 BACKEND API (4 endpoints max):
- `GET /tasks` → returns all tasks as JSON array
- `POST /tasks` → creates task (expects `{ "title": "string" }`)
- `PUT /tasks/:id` → updates status (expects `{ "status": "string" }`)
- `DELETE /tasks/:id` → deletes task

🖥️ FRONTEND:
- Fetches tasks on page load
- Renders 3 columns: "To Do", "In Progress", "Done"
- Each task card shows: title, a `<select>` dropdown to change status, and a "Delete" button
- Top of page: simple text input + "Add Task" button
- After any add/update/delete, refetch and re-render (no complex state management)
- Basic inline CSS only. No frameworks, no build tools.

🚫 STRICTLY EXCLUDE:
- Authentication, validation, error handling, logging, pagination
- Environment variables (hardcode `host=localhost`, `port=5432`, `user=postgres`, `password=postgres`, `database=kanban_practice`)
- Docker, testing, CI/CD, CORS configuration (just allow all origins)
- Drag-and-drop, animations, or external dependencies
- Excessive comments or explanations

📤 OUTPUT FORMAT:
1. Exact file/folder structure
2. Complete code for every file
3. 3 simple terminal commands to: (a) create the PostgreSQL table, (b) install dependencies, (c) start the app
Keep it minimal. Code only.