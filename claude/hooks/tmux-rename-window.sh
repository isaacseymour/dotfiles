#!/bin/bash
# Automatically rename tmux window based on Claude Code conversation
# Uses LLM to generate smart, concise task names

set -e

# Only proceed if we're in a tmux session
if [ -z "$TMUX" ]; then
  exit 0
fi

# Read the JSON input from stdin
json_input=$(cat)

# Extract the user's prompt and transcript path
prompt=$(echo "$json_input" | jq -r '.prompt // empty')
transcript_path=$(echo "$json_input" | jq -r '.transcript_path // empty')

if [ -z "$prompt" ] || [ "$prompt" = "null" ]; then
  exit 0
fi

# Read the ENTIRE conversation from the transcript for better context
# Limit to last 100 lines (about 10-20 messages) for performance
context=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  # Extract user and assistant messages from the JSONL transcript
  context=$(tail -100 "$transcript_path" 2>/dev/null | \
    jq -r 'select(.role == "user" or .role == "assistant") |
           if .role == "user" then "User: \(.text[0:200])"
           elif .role == "assistant" then "Assistant: \(.text[0:200])"
           else empty end' 2>/dev/null | \
    tail -20)
fi

# If no transcript available, use just the current prompt
if [ -z "$context" ]; then
  context="User: $prompt"
fi

# Build the LLM prompt to generate a task name based on full conversation
llm_prompt="Based on this entire conversation, generate a short task name (1-3 words, hyphenated) that describes what the user is working on overall.

Conversation history:
${context}

Current prompt: ${prompt}

Examples of good task names:
- auth-bug-fix
- user-migration
- api-refactor
- worktrunk-config
- tmux-bell-setup

Generate ONLY the hyphenated task name, nothing else:"

# Generate task name using Claude Haiku (fast and cost-effective)
# Uses the ANTHROPIC_API_KEY from Claude Code environment
task_name=""
if [ -n "$ANTHROPIC_API_KEY" ]; then
  task_name=$(timeout 3s curl -s https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d '{
      "model": "claude-3-5-haiku-20241022",
      "max_tokens": 50,
      "messages": [{"role": "user", "content": "'"$(echo "$llm_prompt" | sed 's/"/\\"/g')"'"}]
    }' 2>/dev/null | jq -r '.content[0].text // empty' 2>/dev/null || echo "")
fi

# Fallback: if LLM fails or returns empty, use simple extraction
if [ -z "$task_name" ] || [ ${#task_name} -gt 30 ]; then
  task_name=$(echo "$prompt" | \
    tr '[:upper:]' '[:lower:]' | \
    sed -E 's/^(can you |please |i want to |i need to |help me |let'\''s |could you )//' | \
    sed 's/[?.!]*$//' | \
    head -c 25 | \
    sed 's/[^a-z0-9]/-/g' | \
    sed 's/^-*//' | sed 's/-*$//' | \
    sed 's/-\+/-/g')
fi

# Clean up the task name just in case (remove newlines, convert to lowercase, etc)
task_name=$(echo "$task_name" | \
  tr -d '\n\r' | \
  tr '[:upper:]' '[:lower:]' | \
  sed 's/[^a-z0-9-]//g' | \
  sed 's/^-*//' | sed 's/-*$//' | \
  sed 's/-\+/-/g' | \
  head -c 25)

# If we still got an empty name, use git repo name as default
if [ -z "$task_name" ]; then
  # Try to get git root directory name
  git_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  if [ -n "$git_root" ]; then
    task_name=$(basename "$git_root")
  else
    task_name=$(basename "$PWD")
  fi
fi

# Rename the current tmux window
tmux rename-window "$task_name"

exit 0
