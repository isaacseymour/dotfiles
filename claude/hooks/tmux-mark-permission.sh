#!/bin/bash
# Mark tmux window when Claude needs permission
# Sends a bell to mark the window (tmux shows this with reverse video)

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Send a bell to mark the window when permission is needed
# tmux will automatically mark the window with the bell indicator
printf '\a'

exit 0
