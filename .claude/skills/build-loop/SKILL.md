---
name: build-loop
description: Headless parallel Ralph Loop. Reads `docs/BUILD-PROMPTS.md` and dispatches every `[ ]` (pending, non-skipped) Phase B session as a headless `claude -p` worker in its own git worktree (max 3 in parallel), merges results back to main, flips checkboxes, and notifies Telegram on each completion. Pure execution — does NOT audit `[x]` work; that's `/verify-fix-loop`'s job. Use when the user says "run the build loop", "execute remaining build sessions", "/build-loop", or invokes the skill with a file path.
---

# Build Loop — Headless Parallel Session Executor

You are the orchestrator. The user gave you a checklist-driven build-prompt file (default `docs/BUILD-PROMPTS.md`). Your job: execute every `[ ]` (pending, non-skipped) Phase B session by dispatching parallel headless `claude -p` workers in git worktrees, merging their work back to main, updating the checklist, and pinging Telegram on each completion.

**This skill is single-purpose: EXECUTE pending work.** It is INDEPENDENT of `/verify-fix-loop` (which is the autonomous bug-bash loop that hardens already-shipped code). They share no state. Run `/build-loop` to make forward progress on `BUILD-PROMPTS.md`; run `/verify-fix-loop` to bug-bash the existing codebase. They CAN run concurrently in different orchestrator sessions.

## Algorithm

### 1. Parse remaining work
Read `docs/BUILD-PROMPTS.md`. Extract Phase B `- [ ]` lines. For each:
- Capture session number, title, and `deps: <list>` annotation.
- Skip `[s]` (human-gated) and `[x]` (already done — `/verify-fix-loop`'s domain).
- Detect `RE-OPENED` annotation: re-opened sessions sort BEFORE originally-unchecked sessions at the same dependency depth (finish what was claimed done before starting new).

Build the dependency DAG. Topologically order. Compute "ready set" = sessions whose deps are all `[x]`.

If the ready set is empty but pending non-empty: notify deadlock and exit.

### 2. Dispatch wave (max 3 concurrent)

Notify Telegram once per wave: `▶️ Build Loop dispatching: Sessions [N1, N2, N3] (parallel)`

For each session N in the ready set (up to 3 at a time):
```
bash scripts/build-loop-dispatch.sh N docs/BUILD-PROMPTS.md
```
…via Bash with `run_in_background: true`. Capture each shell ID.

The dispatcher (already implemented at `scripts/build-loop-dispatch.sh`) handles:
- `git worktree add -b loop/session-N .worktrees/session-N main`
- awk-extract Session N prompt block from `BUILD-PROMPTS.md`
- prepend `references/worker-preamble.md` + append working-directory footer
- `cd` into worktree and exec `claude -p --dangerously-skip-permissions --output-format stream-json --verbose --max-turns 250`
- verify the worker produced a `chore(loop): Session N done` commit on its branch
- exit 0 (success) / 2 (worker non-zero) / 3 (no done-commit) / 4 (HUMAN GATE TRIPPED)

### 3. Wait + reconcile

Poll BashOutput on each in-flight shell. As each finishes:

**On dispatcher exit 0 (success):**
- `cd <repo-root>`
- `git merge --no-ff loop/session-N -m "merge: loop/session-N (Session N done)"`
- Edit `docs/BUILD-PROMPTS.md`: flip `- [ ] **Session N**` → `- [x] **Session N**`
- Commit: `chore(loop): mark Session N done in checklist`
- `git worktree remove .worktrees/session-N`
- Notify Telegram: `✅ Session N complete (merged)`
- Recompute ready set; if new sessions are now ready, dispatch in the next wave (respecting the 3-concurrent throttle)

**On dispatcher exit 2 or 3 (worker failed or no done-commit):**
- Notify Telegram with `tail -50` of `.planning/build-loop-logs/session-N.log`
- Do NOT merge; leave the worktree intact for human inspection
- Halt the loop

**On dispatcher exit 4 (HUMAN GATE TRIPPED):**
- Notify Telegram: `🔴 Session N tripped HUMAN GATE — needs manual handling`
- Halt the loop

### 4. Final report

When no sessions remain pending (only `[s]` skipped + `[x]` done): send a Telegram summary listing sessions completed this run, sessions still skipped (Session 11), and any halts. Suggest: "Run `/verify-fix-loop` to confirm all just-built sessions are truly complete."

## Constraints

- **Maximum 3 parallel workers** at a time (resource throttle).
- **Never auto-run Session 11.** Session 11 must remain `[s]` (production cutover, human-gated).
- **Never modify code in the main worktree** while workers are running. Only Edit `docs/BUILD-PROMPTS.md` (the checklist), and only AFTER a worker's branch has merged cleanly.
- **Merge conflicts** between concurrent workers' branches → halt loop, notify Telegram with conflict files. Don't auto-resolve.
- **Telegram cadence:** 1 message at start, 1 per dispatch wave, 1 per completion (success/fail), 1 final summary. Don't spam.
- **Workers MUST use the right skills.** The worker preamble enforces: workers load the `Skills:` line from the session prompt (e.g. `superpowers:writing-plans`, `superpowers:test-driven-development`, `superpowers:verification-before-completion`), and use gstack advisors (`/plan-ceo-review`, `/plan-eng-review`, `/cso`, `/plan-design-review`) for any decision points (majority vote; tie → smallest blast radius).

## Worker preamble

The preamble at `references/worker-preamble.md` is the worker contract: decision policy (gstack advisors, majority vote), HUMAN GATE handling, the per-session 14-gate contract, and final-commit format. The dispatcher prepends it to every worker prompt. See that file for the verbatim text.

## Recovery / re-entry

If the user invokes `/build-loop` after a partial run:
- Re-read checklist. Sessions already `[x]` are done — skip.
- If `.worktrees/session-N` exists for an N that's not `[x]`: worker was interrupted or halted. Default: notify the user and ask before auto-resuming (a re-dispatch overwrites the previous attempt's branch).
- If a `RE-OPENED` annotation exists on a `[ ]` line (set by `/verify-fix-loop`), treat it as a normal `[ ]` for dispatch — but it sorts ahead of un-flagged `[ ]` lines at the same dep depth.

## Stop conditions

- All Phase B `[ ]` lines flipped to `[x]` (or only `[s]` remain).
- Any worker fails (dispatcher exit 2 or 3).
- HUMAN GATE TRIPPED (dispatcher exit 4).
- Merge conflict.
- User interrupts.

## Invocation patterns

- `/build-loop` → use default `docs/BUILD-PROMPTS.md`
- `/build-loop docs/some-other-file.md` → use a different checklist file
- `/build-loop --only 13` → execute only Session 13 (smoke-test mode)
- `/build-loop --dry-run` → print the dispatch plan (sessions, order, parallelism waves) without invoking workers

## Companion skill

`/verify-fix-loop` is the autonomous bug-bash iteration loop (default 10 iterations). It is **independent of this skill** — share no state. Run `/build-loop` for forward progress on `BUILD-PROMPTS.md`; run `/verify-fix-loop` to harden the existing codebase by hunting bugs.
