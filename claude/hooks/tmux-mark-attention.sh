#!/bin/bash
# Mark tmux window when Claude needs user attention
# Triggered by Notification or PermissionRequest hooks

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Send a bell to mark the window
# This matches the same triggers as the terminal-notifier notifications:
# - permission_prompt: When Claude needs permission
# - idle_prompt: When Claude is waiting for input (60+ seconds)
# - elicitation_dialog: When Claude needs additional information (AskUserQuestion)
current_pane=$(tmux display-message -p '#{pane_id}')
tmux send-keys -t "$current_pane" C-g 2>/dev/null || printf '\a'

exit 0
