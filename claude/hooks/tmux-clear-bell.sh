#!/bin/bash
# Clear tmux bell indicator by briefly switching windows
# Called when session ends

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Get current window
current_window=$(tmux display-message -p '#{window_index}')

# Get list of all windows
window_count=$(tmux list-windows | wc -l)

# If there's more than one window, switch to another and back to clear bell
if [ "$window_count" -gt 1 ]; then
  # Find a different window to switch to temporarily
  other_window=$(tmux list-windows -F "#{window_index}" | grep -v "^${current_window}$" | head -1)

  if [ -n "$other_window" ]; then
    # Switch away and back to clear any bell flags
    tmux select-window -t ":${other_window}" 2>/dev/null || true
    sleep 0.1
    tmux select-window -t ":${current_window}" 2>/dev/null || true
  fi
fi

exit 0
