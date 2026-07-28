#!/usr/bin/env bash
# Remove idle git worktrees to reclaim disk.
#
# Scope is every LINKED worktree of every repo under $HOME/work. We enumerate
# with `git worktree list` rather than globbing paths, because worktrees here
# live in three layouts and a glob only ever caught the first:
#   <repo>/.claude/worktrees/<name>   Claude Code — both agent-* and named
#   <repo>-worktrees/<name>
#   <repo>-<name>                     sibling checkouts
# Claude Code names a worktree after whatever it was given, so agent-* is only a
# fraction of the trees it leaves behind; the rest used to accumulate forever.
#
# Idle windows ("idle" = nothing inside the worktree modified in the window):
#   AGENT_IDLE_MIN  disposable Claude agent-* trees  (default 60m)
#   IDLE_MIN        everything else                  (default 1440m / 24h)
#
# Locked worktrees are NEVER touched: a lock is a deliberate "keep this" signal
# and can mark an actively-running agent.
#
# Committed work is never at risk — branch refs survive `git worktree remove`,
# so only the working directory goes. Uncommitted work WOULD be lost to
# --force, so before removing a dirty tree we snapshot it to a rescue ref in the
# parent repo (tracked edits plus non-ignored untracked files; ignored build
# output is skipped so .git doesn't balloon):
#
#   git -C <repo> for-each-ref refs/prune-rescue/       # list snapshots
#   git -C <repo> show --stat <ref>                     # inspect one
#   git -C <repo> checkout -b recover <ref>             # get the work back
#
# If a snapshot can't be taken, the worktree is left alone rather than destroyed.
#
# AGENT_ONLY=1  only sweep agent-* (SessionEnd hook uses this, so session
#               teardown doesn't stat every worktree on the machine).
# DRY_RUN=1     report what would go, touch nothing.
#
# Driven hourly by ~/Library/LaunchAgents/com.isaac.prune-claude-worktrees.plist
# and on session end by the SessionEnd hook in ~/.claude/settings.json.
set -uo pipefail

IDLE_MIN="${IDLE_MIN:-1440}"
AGENT_IDLE_MIN="${AGENT_IDLE_MIN:-60}"
AGENT_ONLY="${AGENT_ONLY:-0}"
DRY_RUN="${DRY_RUN:-0}"
LOG="$HOME/.claude/prune-idle-worktrees.log"

note() {
  if [ "$DRY_RUN" = "1" ]; then
    echo "would: $*"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
  fi
}

shopt -s nullglob
for repo in "$HOME"/work/*; do
  # A main worktree has .git as a directory; a linked one has it as a file
  # containing "gitdir: ...". Taking main worktrees only means each repo's
  # worktree set gets considered exactly once, however the trees are laid out.
  [ -d "$repo/.git" ] || continue
  repo_name="$(basename "$repo")"

  # Paths git considers locked, one per line. substr rather than $2 so paths
  # containing spaces survive.
  locked="$(git -C "$repo" worktree list --porcelain 2>/dev/null \
    | awk '/^worktree /{wt=substr($0,10)} /^locked/{print wt}')"

  removed=0
  rescued=0

  while IFS= read -r wt; do
    [ -n "$wt" ] || continue
    # Never the main worktree (git would refuse anyway).
    [ "$wt" = "$repo" ] && continue
    [ -d "$wt/.git" ] && continue
    # Stale admin entry for an already-deleted dir; `worktree prune` gets it.
    [ -d "$wt" ] || continue

    name="$(basename "$wt")"

    case "$name" in
      agent-*) window="$AGENT_IDLE_MIN" ;;
      *)
        [ "$AGENT_ONLY" = "1" ] && continue
        window="$IDLE_MIN"
        ;;
    esac

    if printf '%s\n' "$locked" | grep -qxF "$wt"; then
      continue
    fi

    # Anything modified inside the window means it's still in play.
    if find "$wt" -type f -mmin -"$window" -print -quit 2>/dev/null | grep -q .; then
      continue
    fi

    # Dirty tree: snapshot before --force throws the edits away. `add -A`
    # honours .gitignore, so build artifacts stay out of the snapshot.
    if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
      ref="refs/prune-rescue/$(printf '%s' "$name" | tr -c '[:alnum:]._-' '_')-$(date +%s)"
      if git -C "$wt" add -A >/dev/null 2>&1 \
        && tree="$(git -C "$wt" write-tree 2>/dev/null)" && [ -n "$tree" ] \
        && commit="$(git -C "$wt" commit-tree "$tree" -p HEAD \
             -m "prune-rescue: $name removed while dirty" 2>/dev/null)" \
        && [ -n "$commit" ]; then
        if [ "$DRY_RUN" = "1" ]; then
          note "[$repo_name] rescue $name -> $ref"
        else
          git -C "$repo" update-ref "$ref" "$commit" 2>/dev/null \
            && note "[$repo_name] rescued dirty $name -> $ref"
        fi
        rescued=$((rescued + 1))
      else
        note "[$repo_name] KEPT $name: dirty but could not snapshot it"
        continue
      fi
    fi

    if [ "$DRY_RUN" = "1" ]; then
      note "[$repo_name] remove $name (idle >${window}m)"
      removed=$((removed + 1))
    elif git -C "$repo" worktree remove --force "$wt" 2>/dev/null; then
      removed=$((removed + 1))
    fi
  done < <(git -C "$repo" worktree list --porcelain 2>/dev/null \
    | awk '/^worktree /{print substr($0,10)}')

  [ "$DRY_RUN" = "1" ] || git -C "$repo" worktree prune 2>/dev/null || true

  if [ "$removed" -gt 0 ] && [ "$DRY_RUN" != "1" ]; then
    note "[$repo_name] pruned ${removed} unlocked worktree(s) (${rescued} rescued dirty)"
  fi
done
