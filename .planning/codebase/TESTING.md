# Testing Patterns

> Generated: 2026-05-07
> Focus: quality
> Project: Simple Kanban Practice App

**Analysis Date:** 2026-05-07

## Testing Status: Explicitly Excluded

Testing is **out of scope** for this project. The spec (`Docs/Spec.md`) lists "testing" under STRICTLY EXCLUDE. The constraints document (`.planning/intel/constraints.md`, CONST-006) limits dependencies to `express` and `pg` only -- no testing frameworks.

**There are:**
- No test files
- No test framework
- No test runner
- No coverage requirements
- No test scripts in `package.json`
- No CI pipeline to run tests

This is intentional. The app is a local practice/learning tool with ~150 lines of code. The spec deliberately excludes testing to keep the scope minimal and focused on the HTTP-to-SQL learning loop.

## Test Framework

**Runner:**
- Not applicable. No test framework specified or intended.

**Assertion Library:**
- Not applicable.

**Run Commands:**
- None. No test commands exist or should be added without explicit user request.

## Test File Organization

**Location:**
- Not applicable. No test files are planned.

**Naming:**
- Not applicable.

## If Testing Were Added Later

If the user decides to add tests in the future, here is the recommended approach based on the project's architecture (three-file structure, Express + pg, vanilla frontend).

### Recommended Stack

- **Runner:** Node's built-in `node --test` (Node 18+) or `vitest` (lightweight, no config needed)
- **Assertion:** Node's built-in `assert` module, or vitest's `expect()`
- **HTTP testing:** `supertest` for Express endpoint testing without starting a real server

### API Endpoint Tests (Priority 1)

These would test the four CRUD endpoints against a real or mocked PostgreSQL connection.

**Location:** `test/server.test.js` (single test file is sufficient for this app size)

```js
// Example pattern if tests are added later
const request = require('supertest');
const app = require('../server'); // would need to export `app`

describe('GET /tasks', () => {
  it('returns all tasks as JSON array', async () => {
    const res = await request(app).get('/tasks');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});

describe('POST /tasks', () => {
  it('creates a task with a title', async () => {
    const res = await request(app)
      .post('/tasks')
      .send({ title: 'Test task' });
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('Test task');
    expect(res.body.status).toBe('todo');
  });
});

describe('PUT /tasks/:id', () => {
  it('updates task status', async () => {
    // First create a task
    const created = await request(app)
      .post('/tasks')
      .send({ title: 'To update' });
    // Then update it
    const res = await request(app)
      .put(`/tasks/${created.body.id}`)
      .send({ status: 'in_progress' });
    expect(res.body.status).toBe('in_progress');
  });
});

describe('DELETE /tasks/:id', () => {
  it('deletes a task', async () => {
    const created = await request(app)
      .post('/tasks')
      .send({ title: 'To delete' });
    const res = await request(app).delete(`/tasks/${created.body.id}`);
    expect(res.status).toBe(200);
    // Verify it's gone
    const all = await request(app).get('/tasks');
    const found = all.body.find(t => t.id === created.body.id);
    expect(found).toBeUndefined();
  });
});
```

**Prerequisite:** `server.js` would need to export the Express `app` without calling `app.listen()` in the test environment. Pattern:

```js
// server.js - add at bottom
if (require.main === module) {
  app.listen(3000, () => console.log('Running on http://localhost:3000'));
}
module.exports = app;
```

### Database Considerations for Testing

- Use a separate test database (e.g., `kanban_practice_test`) to avoid polluting development data.
- Clean the `tasks` table between tests: `DELETE FROM tasks` in a `beforeEach` hook.
- Or use transactions that roll back after each test.

### Frontend Tests (Priority 3 -- low)

Frontend testing is low priority given the inline-vanilla-JS approach. If needed:

- **Tool:** A browser-based test runner or simple manual testing via the browser.
- **What to test:** Task rendering after fetch, dropdown change triggering PUT, delete button triggering DELETE.
- **Approach:** The frontend is simple enough that manual browser testing is more practical than automated DOM testing for this learning app.

### Test Setup Changes Required

Adding tests would require changes that currently violate the spec's constraints:

1. **New dependency:** `supertest` (violates CONST-006: only `express` and `pg`)
2. **New file:** `test/server.test.js` (violates CONST-007: three files total)
3. **Modified `server.js`:** Export the app, conditional `listen()` (modifies the simplicity target)
4. **Test database:** Separate `kanban_practice_test` database or transaction-based cleanup

These changes should only be made if the user explicitly requests testing.

## Coverage

**Requirements:** None enforced. Not applicable.

## Summary

| Aspect | Status |
|--------|--------|
| Unit tests | Excluded |
| Integration tests | Excluded |
| E2E tests | Excluded |
| Test framework | None |
| Coverage target | None |
| CI test automation | Excluded |

**Do not add test files, test dependencies, or test scripts unless the user explicitly requests it.** The spec is unambiguous: "STRICTLY EXCLUDE: ... testing."

---

*Testing analysis: 2026-05-07*
