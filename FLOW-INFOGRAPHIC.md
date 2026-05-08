# Simple Kanban App - Complete Flow Infographic

This document provides visual diagrams explaining how the Simple Kanban App works from start to end.

## 🎬 Application Startup Flow

```mermaid
flowchart TD
    Start([User Opens Browser])
    Start -->|Type localhost:3000| Express["Express Server<br/>(server.js)"]
    Express -->|Check| DBExists{"Does<br/>kanban.db exist?"}
    DBExists -->|No| CreateDB["Create kanban.db<br/>with tasks table"]
    DBExists -->|Yes| UseDB["Use existing<br/>kanban.db"]
    CreateDB --> Seed["Seed 3 sample<br/>tasks if empty"]
    Seed --> ServeHTML["Serve index.html<br/>to browser"]
    UseDB --> ServeHTML
    ServeHTML -->|HTML, CSS, JS| Browser["Browser loads<br/>Kanban board"]
    Browser -->|fetch/GET| API["/tasks endpoint"]
    API -->|SELECT all| DB["SQLite Database"]
    DB -->|Return tasks| Format["Format tasks<br/>as JSON"]
    Format -->|JavaScript| Render["Render 3 columns:<br/>To Do | In Progress | Done"]
    Render --> Ready["✓ Board ready<br/>to use!"]
```

## 💻 System Architecture

```mermaid
graph LR
    subgraph Frontend["🖥️ FRONTEND<br/>(index.html)"]
        UI["Kanban Board UI<br/>3 Columns"]
        JS["Vanilla JavaScript<br/>Fetch API"]
        DOM["DOM Manipulation<br/>Create/Update/Delete"]
        Events["Event Listeners<br/>Button Clicks"]
        UI --> JS
        JS --> DOM
        Events --> JS
    end
    
    subgraph Network["🌐 NETWORK"]
        HTTP["HTTP Requests/Responses<br/>REST API"]
    end
    
    subgraph Backend["🔧 BACKEND<br/>(server.js)"]
        Express["Express.js<br/>Web Server"]
        Routes["4 API Routes<br/>GET/POST/PUT/DELETE"]
        SQL["SQL Queries<br/>CRUD Operations"]
        Express --> Routes
        Routes --> SQL
    end
    
    subgraph Storage["💾 STORAGE"]
        DB["SQLite Database<br/>(kanban.db)"]
        Schema["tasks table<br/>id, title, status, created_at"]
        DB --> Schema
    end
    
    Frontend -->|fetch| Network
    Network -->|response| Backend
    Backend --> Storage
    Storage -->|query results| Backend
    Backend -->|JSON| Network
    Network -->|JSON data| Frontend
```

## 📌 Complete User Interaction Flow

```mermaid
flowchart TD
    Load["🟢 PAGE LOAD"]
    Load --> FetchAll["fetch GET /tasks"]
    FetchAll --> GetDB["SELECT * FROM tasks"]
    GetDB --> ParseJSON["Parse to JSON"]
    ParseJSON --> Display["Display tasks in columns"]
    Display --> Ready["Ready for user"]
    
    Ready --> UserAction{"User Action?"}
    
    UserAction -->|Add Task| Add["User enters title<br/>Click 'Add'"]
    Add --> PostTask["fetch POST /tasks<br/>{ title: ... }"]
    PostTask --> InsertDB["INSERT INTO tasks"]
    InsertDB --> RefreshAdd["Refetch all tasks"]
    RefreshAdd --> DisplayAdd["Update board"]
    DisplayAdd --> Ready
    
    UserAction -->|Change Status| Update["User clicks dropdown<br/>Select new status"]
    Update --> PutTask["fetch PUT /tasks/:id<br/>{ status: ... }"]
    PutTask --> UpdateDB["UPDATE tasks<br/>SET status = ..."]
    UpdateDB --> RefreshUpdate["Refetch all tasks"]
    RefreshUpdate --> DisplayUpdate["Update board"]
    DisplayUpdate --> Ready
    
    UserAction -->|Delete Task| Delete["User clicks<br/>Delete button"]
    Delete --> DeleteTask["fetch DELETE /tasks/:id"]
    DeleteTask --> DeleteDB["DELETE FROM tasks<br/>WHERE id = ..."]
    DeleteDB --> RefreshDelete["Refetch all tasks"]
    RefreshDelete --> DisplayDelete["Update board"]
    DisplayDelete --> Ready
    
    UserAction -->|Exit| End["🔴 User closes browser"]
```

## 🔗 API Call Sequence

```mermaid
sequenceDiagram
    actor User as 👤 User
    participant Browser as 🖥️ Browser
    participant Server as 🔧 Server.js
    participant SQLite as 💾 SQLite

    User->>Browser: Opens localhost:3000
    Browser->>Server: HTTP GET /
    Server->>Browser: Serves index.html
    Browser->>Server: HTTP GET /tasks
    Server->>SQLite: SELECT * FROM tasks
    SQLite-->>Server: tasks data
    Server-->>Browser: JSON response
    Browser->>Browser: Render board (3 columns)
    
    User->>Browser: Enters "Learn SQL"
    User->>Browser: Clicks "Add"
    Browser->>Server: HTTP POST /tasks
    Note over Server: { title: "Learn SQL" }
    Server->>SQLite: INSERT INTO tasks
    SQLite-->>Server: new task id
    Server-->>Browser: JSON task object
    Browser->>Server: HTTP GET /tasks
    Server->>SQLite: SELECT * FROM tasks
    SQLite-->>Server: all tasks
    Server-->>Browser: JSON response
    Browser->>Browser: Refresh board display
    
    User->>Browser: Click dropdown on task
    User->>Browser: Select "in_progress"
    Browser->>Server: HTTP PUT /tasks/1
    Note over Server: { status: "in_progress" }
    Server->>SQLite: UPDATE tasks SET status
    SQLite-->>Server: confirmation
    Server-->>Browser: JSON updated task
    Browser->>Server: HTTP GET /tasks
    Server->>SQLite: SELECT * FROM tasks
    SQLite-->>Server: all tasks
    Server-->>Browser: JSON response
    Browser->>Browser: Refresh board display
    
    User->>Browser: Click delete on task
    Browser->>Server: HTTP DELETE /tasks/1
    Server->>SQLite: DELETE FROM tasks WHERE id=1
    SQLite-->>Server: confirmation
    Server-->>Browser: JSON confirmation
    Browser->>Server: HTTP GET /tasks
    Server->>SQLite: SELECT * FROM tasks
    SQLite-->>Server: remaining tasks
    Server-->>Browser: JSON response
    Browser->>Browser: Refresh board display
```

## 📊 Data Flow for "Add Task" Operation

```mermaid
graph LR
    A["👤 User Types<br/>Task Title"] --> B["📝 Input Field<br/>Value Captured"]
    B --> C["🖱️ Click Add Button"]
    C --> D["🔄 Event Listener<br/>Triggered"]
    D --> E["📦 Create JSON<br/>{ title: '...' }"]
    E --> F["🌐 fetch POST<br/>/tasks"]
    F --> G["📨 HTTP Request<br/>to Server"]
    G --> H["🔧 Express Route<br/>POST /tasks"]
    H --> I["💾 SQL Query<br/>INSERT INTO tasks"]
    I --> J["📂 Save to<br/>SQLite Database"]
    J --> K["📄 Return JSON<br/>New Task Object"]
    K --> L["🌐 HTTP Response<br/>to Browser"]
    L --> M["🔄 Call fetchTasks<br/>GET /tasks"]
    M --> N["📂 Query all<br/>from Database"]
    N --> O["📊 Group by<br/>Status"]
    O --> P["🎨 Render<br/>3 Columns"]
    P --> Q["✅ Display<br/>New Task"]
```

## 🗂️ Database Schema

```mermaid
graph TB
    subgraph DB["🗄️ kanban.db"]
        subgraph TASKS["tasks table"]
            C1["id<br/>INTEGER PRIMARY KEY<br/>AUTOINCREMENT"]
            C2["title<br/>TEXT NOT NULL"]
            C3["status<br/>TEXT DEFAULT 'todo'"]
            C4["created_at<br/>TIMESTAMP<br/>DEFAULT CURRENT_TIMESTAMP"]
        end
    end
    
    subgraph StatusValues["Status Values"]
        S1["✏️ 'todo'"]
        S2["⚙️ 'in_progress'"]
        S3["✅ 'done'"]
    end
    
    TASKS -.-> StatusValues
```

## 🎯 Request/Response Examples

### 1️⃣ GET /tasks - Fetch All Tasks
```
REQUEST:
  GET http://localhost:3000/tasks

RESPONSE (200 OK):
{
  "tasks": [
    {
      "id": 1,
      "title": "Learn HTTP verbs",
      "status": "todo",
      "created_at": "2026-05-08T10:00:00Z"
    },
    {
      "id": 2,
      "title": "Build REST API",
      "status": "in_progress",
      "created_at": "2026-05-08T10:05:00Z"
    }
  ]
}
```

### 2️⃣ POST /tasks - Create New Task
```
REQUEST:
  POST http://localhost:3000/tasks
  Content-Type: application/json
  
  {
    "title": "Deploy the app"
  }

RESPONSE (201 Created):
{
  "task": {
    "id": 3,
    "title": "Deploy the app",
    "status": "todo",
    "created_at": "2026-05-08T10:10:00Z"
  }
}
```

### 3️⃣ PUT /tasks/:id - Update Task Status
```
REQUEST:
  PUT http://localhost:3000/tasks/1
  Content-Type: application/json
  
  {
    "status": "in_progress"
  }

RESPONSE (200 OK):
{
  "task": {
    "id": 1,
    "title": "Learn HTTP verbs",
    "status": "in_progress",
    "created_at": "2026-05-08T10:00:00Z"
  }
}
```

### 4️⃣ DELETE /tasks/:id - Delete Task
```
REQUEST:
  DELETE http://localhost:3000/tasks/1

RESPONSE (200 OK):
{
  "message": "Task deleted"
}
```

## 🖼️ UI Layout Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  KANBAN BOARD - localhost:3000              │
├──────────────────┬──────────────────┬──────────────────┐
│                  │                  │                  │
│     TO DO        │   IN PROGRESS    │      DONE        │
│                  │                  │                  │
│ ┌──────────────┐ │ ┌──────────────┐ │ ┌──────────────┐ │
│ │ Task 1       │ │ │ Task 2       │ │ │ Task 3       │ │
│ │ Learn HTTP   │ │ │ Build API    │ │ │ Ship app     │ │
│ │              │ │ │              │ │ │              │ │
│ │ [▼] [Delete] │ │ │ [▼] [Delete] │ │ │ [▼] [Delete] │ │
│ └──────────────┘ │ └──────────────┘ │ └──────────────┘ │
│                  │                  │                  │
│                  │                  │                  │
│                  │                  │                  │
├──────────────────┴──────────────────┴──────────────────┤
│ New Task: [__________________] [Add Task]             │
└──────────────────────────────────────────────────────────┘
```

## 🔄 State Management (Refetch Pattern)

```mermaid
stateDiagram-v2
    [*] --> Idle: Page loaded
    
    Idle --> Adding: User clicks Add
    Adding --> Posting: POST /tasks
    Posting --> Fetching: Refetch tasks
    Fetching --> Rendering: Parse JSON
    Rendering --> Idle: Display updated
    
    Idle --> Changing: User selects status
    Changing --> Putting: PUT /tasks/:id
    Putting --> Fetching
    
    Idle --> Deleting: User clicks delete
    Deleting --> Deleting_HTTP: DELETE /tasks/:id
    Deleting_HTTP --> Fetching
    
    note right of Fetching
        GET /tasks always follows
        any mutation (POST/PUT/DELETE)
        to refresh the entire board
    end note
```

## 📋 Summary: From Start to End

| Step | Component | Action | Result |
|------|-----------|--------|--------|
| 1 | Browser | Opens http://localhost:3000 | HTML loaded |
| 2 | Express | Serves index.html | JavaScript runs |
| 3 | Frontend JS | Calls fetch GET /tasks | API response |
| 4 | Express | Queries SQLite database | Returns JSON |
| 5 | Frontend | Groups tasks by status | Renders 3 columns |
| 6 | User | Interacts with board | Add/Update/Delete |
| 7 | Frontend | Sends HTTP request | POST/PUT/DELETE |
| 8 | Express | Executes SQL query | Database updated |
| 9 | Frontend | Refetches all tasks | GET /tasks |
| 10 | Database | Returns updated data | Fresh JSON |
| 11 | Frontend | Re-renders board | User sees changes |

---

**Ready to run?** Just type `npm install && node server.js` and open your browser! 🚀
