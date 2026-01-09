#!/bin/bash
# Clear tmux bell indicator
# Called when user responds or session ends

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Get the current window and pane
current_window=$(tmux display-message -p '#{window_index}')
current_pane=$(tmux display-message -p '#{pane_index}')

# Briefly select this window and pane to clear the bell flag
# This is the only way to programmatically clear a bell in tmux
tmux select-window -t ":$current_window" 2>/dev/null || true
tmux select-pane -t ":.${current_pane}" 2>/dev/null || true

exit 0
