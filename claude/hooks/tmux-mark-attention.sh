#!/bin/bash
# Mark tmux window when Claude needs user attention
# Triggered by Notification hooks

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Send a bell to mark the window
# Can't use tmux send-keys because Claude Code is running in the pane, not a shell
# Instead, use tmux's run-shell to execute a command that produces a bell
# The -b flag runs it in the background so it doesn't block
current_pane=$(tmux display-message -p '#{pane_id}')
tmux run-shell -b -t "$current_pane" 'printf "\a"' 2>/dev/null || true

exit 0
