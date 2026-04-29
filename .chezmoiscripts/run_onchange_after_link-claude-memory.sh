#!/bin/sh
# Create symlinks at ~/.claude/projects/<encoded>/memory pointing into the
# dotfiles-private overlay. Discovers projects dynamically by listing
# ~/me/dotfiles-private/claude/memory/*/ — keeps repo names out of the public
# source tree.
#
# Encoded path follows Claude Code's convention (replace `/` with `-`); we
# assume each memory dir <X> corresponds to ~/work/<X>. Repos elsewhere need
# their symlink set up by hand.
set -e

PRIVATE="$HOME/me/dotfiles-private/claude/memory"
[ -d "$PRIVATE" ] || exit 0

for memory_dir in "$PRIVATE"/*/; do
  proj=$(basename "$memory_dir")
  encoded="-Users-$(whoami)-work-$proj"
  target="$HOME/.claude/projects/$encoded/memory"
  mkdir -p "$(dirname "$target")"
  # Already a symlink — trust it
  [ -L "$target" ] && continue
  # Real dir/file at target — back up and replace with symlink
  [ -e "$target" ] && mv "$target" "$target.backup-$(date +%s)"
  ln -s "${memory_dir%/}" "$target"
  echo "→ Linked ~/.claude/projects/$encoded/memory → $proj"
done
