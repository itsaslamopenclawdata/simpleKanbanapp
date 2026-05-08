# Example BUILD-PROMPTS.md

> Template showing the exact shape `/build-loop`'s dispatcher expects.
> Copy to `<your-repo>/docs/BUILD-PROMPTS.md` and replace with your real sessions.

> **Run with:** `/build-loop docs/BUILD-PROMPTS.md`
>
> **Prerequisites:** Your "Phase A" / "Chunk 0" prep work must be merged to `main`
> before dispatching. Workers branch from `main`, so anything they reference
> (shared types, API clients, scaffolding) must be reachable from `main` first.

## Session checklist

**Format:** `- [x|s|/| ] **Session N** — title — deps`
**Legend:** `[x]` done · `[s]` skipped (human-gated) · `[/]` in progress · `[ ]` pending

- [ ] **Session 1** — Add user profile page — deps: none
- [ ] **Session 2** — Add settings page — deps: none
- [ ] **Session 3** — Wire profile + settings into nav — deps: Session 1, Session 2
- [s] **Session 4** — Production cutover — deps: Session 3

---

### Session 1 — Add user profile page

**Type:** execute  **Worktree:** `.worktrees/session-1`  **Branch:** `loop/session-1`  **Depends on:** none

```text
Skills: superpowers:using-superpowers, superpowers:subagent-driven-development,
        superpowers:test-driven-development, superpowers:verification-before-completion

Working directory: <inherit>

Pre-flight (Gate -1):
- File-presence is the real signal. Verify scaffolding exists on main:
  ls src/components/PageShell.tsx
  ls src/api/users.ts
  grep -q "fetchCurrentUser" src/api/users.ts
- If any check fails → STOP and emit:
  HUMAN GATE TRIPPED: scaffolding missing — finish Phase A first
- Exit non-zero so the orchestrator halts the whole loop.

This session adds the user profile page (Tasks 1–4 from the plan).

Plan file (read this section before Task 1):
docs/plans/2026-04-30-user-profile-plan.md

Reference docs (read in this order before Task 1):
1. CLAUDE.md
2. DESIGN.md (READ FIRST — design tokens are load-bearing)
3. src/components/PageShell.tsx
4. src/api/users.ts

Scope (4 tasks, strict order):
- Task 1: <UserProfileHeader> component
- Task 2: <UserProfileForm> with RHF + Zod validation
- Task 3: <UserProfileAvatar> upload via TUS
- Task 4: UserProfilePage page + /profile route in App.tsx

Execution rules:
- Each task: failing test → run → implement → verify → commit with the EXACT
  message in the plan. One commit per task.
- Run `npm run lint` before each commit.
- Every operator-facing string MUST be in EN + ZH locale files.
- Spec/plan conflicts → STOP and emit HUMAN GATE TRIPPED: spec/plan conflict at <ref>.

Subagent flow per task (use superpowers:subagent-driven-development):
- Tasks 1, 4 (focused components): implementer + combined reviewer.
- Tasks 2, 3 (judgment-heavy: forms, upload flow): full implementer + spec reviewer + code-quality reviewer.

Decision-point policy: any AskUserQuestion-shaped branch — spawn the relevant
gstack advisors in parallel (/plan-ceo-review, /plan-eng-review, /cso,
/plan-design-review), adopt majority. Tie → smallest blast radius.
NEVER call AskUserQuestion. NEVER block waiting for the user.

After all tasks close:
- Run `npm test`, `npm run lint`. All green.
- Final commit: `chore(loop): Session 1 done — user profile page`.
- STOP. The orchestrator merges; do NOT flip checkboxes yourself.
```

---

### Session 2 — Add settings page

**Type:** execute  **Worktree:** `.worktrees/session-2`  **Branch:** `loop/session-2`  **Depends on:** none

```text
Skills: superpowers:using-superpowers, superpowers:subagent-driven-development,
        superpowers:test-driven-development, superpowers:verification-before-completion

Working directory: <inherit>

Pre-flight (Gate -1):
- ls src/components/PageShell.tsx
- ls src/api/settings.ts
- grep -q "useSettings" src/api/settings.ts
- If any check fails → STOP and emit:
  HUMAN GATE TRIPPED: scaffolding missing

This session adds the settings page (Tasks 5–7).

Plan file: docs/plans/2026-04-30-settings-plan.md
Reference docs: same as Session 1.

Scope (3 tasks, strict order):
- Task 5: <SettingsTabs> component
- Task 6: <NotificationsTab> + <SecurityTab>
- Task 7: SettingsPage page + /settings route

Execution rules + decision policy: same as Session 1.

After all tasks close:
- Run `npm test`, `npm run lint`. All green.
- Final commit: `chore(loop): Session 2 done — settings page`.
- STOP.
```

---

### Session 3 — Wire profile + settings into nav

**Type:** execute  **Worktree:** `.worktrees/session-3`  **Branch:** `loop/session-3`  **Depends on:** Session 1, Session 2

```text
Skills: superpowers:using-superpowers, superpowers:test-driven-development,
        superpowers:verification-before-completion

Working directory: <inherit>

Pre-flight (Gate -1):
- Sessions 1 and 2 must have merged. Verify:
  ls src/pages/UserProfilePage.tsx
  ls src/pages/SettingsPage.tsx
  grep -q "/profile" src/App.tsx
  grep -q "/settings" src/App.tsx
- If any check fails → STOP and emit:
  HUMAN GATE TRIPPED: Session 1 or 2 outputs missing

This session wires the new pages into the global nav (Tasks 8–9).

Plan file: docs/plans/2026-04-30-nav-plan.md

Scope (2 tasks):
- Task 8: Add nav entries (RTL test asserts both visible to authenticated users)
- Task 9: Update App.tsx route order to ensure /profile and /settings resolve correctly

Execution rules + decision policy: same as Session 1.

After all tasks close:
- Final commit: `chore(loop): Session 3 done — nav wiring`.
- STOP.
```

---

### Session 4 — Production cutover

**Type:** human-gated  **Worktree:** N/A  **Branch:** N/A  **Depends on:** Session 3

```text
This session is human-gated ([s] in the checklist).

It is a production cutover (DNS swap, feature flag flip, post-deploy verification).
The build loop MUST NOT auto-execute it. The user runs this manually after
sessions 1–3 ship and bake in staging.

Sentinel: keep this as `[s]` in the checklist. The orchestrator skips it.
```
