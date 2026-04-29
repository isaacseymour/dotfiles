#!/bin/bash
# Mark tmux window when Claude needs user attention
# Changes window background color in status bar

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Get current window index
current_window=$(tmux display-message -p '#{window_index}')

# Set a user option on this window to indicate attention needed
# This can be checked in the window-status-format
tmux set-window-option -t ":${current_window}" @attention-needed "1" 2>/dev/null || true

exit 0
