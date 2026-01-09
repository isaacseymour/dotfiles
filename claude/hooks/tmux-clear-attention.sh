#!/bin/bash
# Clear attention marker when user responds
# Resets window background color to normal

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Get current window index
current_window=$(tmux display-message -p '#{window_index}')

# Clear the attention flag
tmux set-window-option -t ":${current_window}" -u @attention-needed 2>/dev/null || true

exit 0
