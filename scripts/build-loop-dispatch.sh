#!/usr/bin/env bash
# scripts/build-loop-dispatch.sh
#
# Headless dispatcher for the /build-loop skill. Spawns a single `claude -p` worker
# in a git worktree, with the worker preamble + extracted session prompt + working-dir
# footer. The orchestrator (main Claude session) calls this script per session, in
# parallel via Bash run_in_background.
#
# This script is a thin wrapper — all decision logic (Phase 0 audit, parallelism,
# merge, checkbox flip, Telegram) lives in the orchestrator skill at
# .claude/skills/build-loop/SKILL.md.
#
# Usage:
#   scripts/build-loop-dispatch.sh <session_num> [prompt_file]
#
#   session_num   numeric session id (e.g. 9, 10, 12, 13)
#   prompt_file   path to BUILD-PROMPTS.md (default: docs/BUILD-PROMPTS.md)
#
# Exit codes:
#   0   worker completed and produced a "chore(loop): Session N done" commit
#   1   bad usage / missing inputs
#   2   worker exited non-zero
#   3   worker finished but produced NO done-commit (work incomplete)
#   4   worker tripped HUMAN GATE (string "HUMAN GATE TRIPPED" found in log)
#
# Env overrides:
#   CLAUDE_BIN         path to claude CLI (default: claude on PATH)
#   MAX_TURNS          --max-turns value (default: 250)
#   WORKTREE_BASE      where to put worktrees (default: <repo-root>/.worktrees)
#   LOG_DIR            where to put logs+prompts (default: <repo-root>/.planning/build-loop-logs)
#   BASE_BRANCH        worktree base branch (default: main)
#   PREAMBLE_FILE      path to worker preamble (default: <repo-root>/.claude/skills/build-loop/references/worker-preamble.md)

set -euo pipefail

# --- args ---
SESSION_NUM="${1:?usage: $0 <session_num> [prompt_file]}"
PROMPT_FILE="${2:-docs/BUILD-PROMPTS.md}"

# --- resolve paths ---
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

CLAUDE_BIN="${CLAUDE_BIN:-claude}"
MAX_TURNS="${MAX_TURNS:-250}"
WORKTREE_BASE="${WORKTREE_BASE:-$REPO_ROOT/.worktrees}"
LOG_DIR="${LOG_DIR:-$REPO_ROOT/.planning/build-loop-logs}"
BASE_BRANCH="${BASE_BRANCH:-main}"
PREAMBLE_FILE="${PREAMBLE_FILE:-$REPO_ROOT/.claude/skills/build-loop/references/worker-preamble.md}"

WORKTREE_DIR="$WORKTREE_BASE/session-$SESSION_NUM"
WORKER_BRANCH="loop/session-$SESSION_NUM"
PROMPT_OUT="$LOG_DIR/session-$SESSION_NUM.prompt"
LOG_OUT="$LOG_DIR/session-$SESSION_NUM.log"

mkdir -p "$LOG_DIR" "$WORKTREE_BASE"

# --- preflight ---
if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  echo "ERROR: claude CLI not found ($CLAUDE_BIN)" >&2
  exit 1
fi
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "ERROR: prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi
if [[ ! -f "$PREAMBLE_FILE" ]]; then
  echo "ERROR: worker preamble not found: $PREAMBLE_FILE" >&2
  exit 1
fi

# --- extract session prompt block ---
# Matches the `### Session N — title` heading, then the FIRST fenced block under it.
# Stops at the next `### Session ` heading or `## ` heading.
EXTRACTED=$(awk -v s="$SESSION_NUM" '
  BEGIN { in_section = 0; in_fence = 0; captured = 0 }
  /^### Session / {
    if (in_section) exit
    # match "### Session N — " or "### Session N "
    if ($0 ~ "^### Session "s"( |$|—)") { in_section = 1; next }
    next
  }
  /^## / { if (in_section) exit }
  in_section && /^```/ {
    if (in_fence) { exit }
    in_fence = 1
    captured = 1
    next
  }
  in_section && in_fence { print }
' "$PROMPT_FILE")

if [[ -z "$EXTRACTED" ]]; then
  echo "ERROR: could not extract prompt for Session $SESSION_NUM from $PROMPT_FILE" >&2
  echo "       Expected a '### Session $SESSION_NUM — ...' heading with a fenced text block." >&2
  exit 1
fi

# --- compose full prompt ---
{
  cat "$PREAMBLE_FILE"
  echo ""
  echo "$EXTRACTED"
  echo ""
  echo "---"
  echo "Working directory: $WORKTREE_DIR"
  echo "Branch: $WORKER_BRANCH"
  echo "Final commit MUST be: chore(loop): Session $SESSION_NUM done — <one-line summary>"
  echo "After that commit, STOP. Do not flip the checkbox in $PROMPT_FILE — the orchestrator handles that on merge."
} > "$PROMPT_OUT"

# --- create worktree (idempotent: if branch exists, recreate worktree only) ---
if [[ -d "$WORKTREE_DIR" ]]; then
  echo "WARN: worktree $WORKTREE_DIR already exists — reusing." >&2
else
  if git show-ref --verify --quiet "refs/heads/$WORKER_BRANCH"; then
    git worktree add "$WORKTREE_DIR" "$WORKER_BRANCH"
  else
    git worktree add -b "$WORKER_BRANCH" "$WORKTREE_DIR" "$BASE_BRANCH"
  fi
fi

# --- dispatch headless worker ---
echo "[dispatch] Session $SESSION_NUM → $WORKTREE_DIR (branch $WORKER_BRANCH)"
echo "[dispatch] log: $LOG_OUT"
echo "[dispatch] prompt: $PROMPT_OUT"

WORKER_EXIT=0
(
  cd "$WORKTREE_DIR"
  "$CLAUDE_BIN" -p "$(cat "$PROMPT_OUT")" \
    --dangerously-skip-permissions \
    --output-format stream-json \
    --verbose \
    --max-turns "$MAX_TURNS" \
    > "$LOG_OUT" 2>&1
) || WORKER_EXIT=$?

# --- post-flight checks ---
if [[ $WORKER_EXIT -ne 0 ]]; then
  echo "[dispatch] Session $SESSION_NUM worker exited $WORKER_EXIT" >&2
  exit 2
fi

if grep -q "HUMAN GATE TRIPPED" "$LOG_OUT"; then
  echo "[dispatch] Session $SESSION_NUM tripped HUMAN GATE — see $LOG_OUT" >&2
  exit 4
fi

# Verify the worker produced the expected done-commit on its branch.
# Note: capture into a variable first — `git log | grep -q` triggers SIGPIPE on
# the producer once grep -q matches, and with `set -o pipefail` that turns a
# successful match into a non-zero pipeline (false negative on exit 3).
WORKER_LOG="$(git -C "$WORKTREE_DIR" log --oneline -20)"
if ! grep -qE "chore\(loop\): Session $SESSION_NUM done" <<<"$WORKER_LOG"; then
  echo "[dispatch] Session $SESSION_NUM produced NO 'chore(loop): Session $SESSION_NUM done' commit" >&2
  echo "[dispatch] last 5 commits in worktree:" >&2
  git -C "$WORKTREE_DIR" log --oneline -5 >&2 || true
  exit 3
fi

echo "[dispatch] Session $SESSION_NUM ✅ done — branch $WORKER_BRANCH ready for merge"
exit 0
