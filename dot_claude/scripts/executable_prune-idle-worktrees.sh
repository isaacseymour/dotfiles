#!/usr/bin/env bash
# Remove Claude Code agent worktrees that have been idle for IDLE_MIN minutes.
#
# Claude Code drops worktree-isolated agent checkouts under
# <repo>/.claude/worktrees/agent-*. They accumulate fast (tens per day, ~0.5GB
# each) and Claude Code has no built-in idle-based cleanup, so we sweep them.
#
# "Idle" = no file inside the worktree modified within the window. Branch refs
# survive `git worktree remove`, so this only ever discards the working dir of a
# tree nothing has touched recently — no unpushed commits are lost.
#
# Locked worktrees are NEVER touched: a lock is a deliberate "keep this" signal
# (and can mark an actively-running agent). This script only ever force-removes
# UNLOCKED, idle worktrees, and never unlocks anything.
#
# Scans every repo at $HOME/work/*; repos without a .claude/worktrees dir are
# skipped. Driven hourly by ~/Library/LaunchAgents/com.isaac.prune-claude-worktrees.plist
# and on every Claude session end by the SessionEnd hook in ~/.claude/settings.json.
set -uo pipefail

IDLE_MIN="${IDLE_MIN:-60}"
LOG="$HOME/.claude/prune-idle-worktrees.log"

shopt -s nullglob
for wt_dir in "$HOME"/work/*/.claude/worktrees; do
  [ -d "$wt_dir" ] || continue
  repo="$(dirname "$(dirname "$wt_dir")")"
  repo_name="$(basename "$repo")"

  # Set of locked worktree paths for this repo, one per line.
  locked="$(git -C "$repo" worktree list --porcelain 2>/dev/null \
    | awk '/^worktree /{wt=$2} /^locked/{print wt}')"

  removed=0
  for dir in "$wt_dir"/agent-*; do
    [ -d "$dir" ] || continue
    # Never touch locked worktrees.
    if printf '%s\n' "$locked" | grep -qxF "$dir"; then
      continue
    fi
    # Skip if anything inside was modified within the idle window.
    if find "$dir" -type f -mmin -"$IDLE_MIN" -print -quit 2>/dev/null | grep -q .; then
      continue
    fi
    if git -C "$repo" worktree remove --force "$dir" 2>/dev/null; then
      removed=$((removed + 1))
    fi
  done

  git -C "$repo" worktree prune 2>/dev/null || true
  if [ "$removed" -gt 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$repo_name] pruned ${removed} unlocked worktree(s) idle >${IDLE_MIN}m" >> "$LOG"
  fi
done
