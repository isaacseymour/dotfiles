#!/bin/bash
# Mark tmux window when Claude needs user attention
# Sends a bell to mark the window (tmux shows this with reverse video)

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Read the JSON input from stdin
json_input=$(cat)

# Get the assistant's last message
last_message=$(echo "$json_input" | jq -r '.lastMessage.text // empty')

if [ -z "$last_message" ] || [ "$last_message" = "null" ]; then
  exit 0
fi

# Check if Claude is waiting for input:
# - Contains question marks
# - Uses AskUserQuestion tool
# - Uses ExitPlanMode tool (plan needs approval)
# - Contains phrases like "would you like", "should I", "do you want"
# - Contains phrases about approval: "approve", "ready to proceed", "should I go ahead"
needs_attention=false

if echo "$last_message" | grep -qE '\?|would you like|should I|do you want|which would you prefer|let me know|please confirm|ready to proceed|approve the plan|review the plan|does this look good'; then
  needs_attention=true
fi

# Check if message contains tool calls that require user input
if echo "$json_input" | jq -e '.lastMessage.toolUse[]? | select(.name == "AskUserQuestion" or .name == "ExitPlanMode")' >/dev/null 2>&1; then
  needs_attention=true
fi

# Send a bell to mark the window if attention is needed
# tmux will automatically mark the window with the bell indicator
if [ "$needs_attention" = true ]; then
  printf '\a'
fi

exit 0
