#!/bin/bash
# Clear tmux bell indicator
# Called when user responds or session ends

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Get current session, window, and pane info
current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')
original_window=$(tmux display-message -p '#{window_index}')

# The ONLY reliable way to clear a bell in tmux is to make the window active
# We'll briefly switch to it and back
# Check if this window has a bell flag
has_bell=$(tmux list-windows -t "$current_session" -F "#{window_index}:#{window_bell_flag}" | grep "^${current_window}:" | cut -d: -f2)

if [ "$has_bell" = "1" ]; then
  # Window has bell - briefly activate it to clear
  # Save the currently active window
  active_window=$(tmux display-message -p '#{window_index}')

  # If we're not currently in this window, switch to it and back
  if [ "$active_window" != "$current_window" ]; then
    tmux select-window -t ":${current_window}"
    sleep 0.05  # Brief pause to let tmux register the switch
    tmux select-window -t ":${active_window}"
  fi
fi

exit 0
