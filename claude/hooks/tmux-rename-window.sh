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

# Extract the user's prompt
prompt=$(echo "$json_input" | jq -r '.prompt // empty')

if [ -z "$prompt" ] || [ "$prompt" = "null" ]; then
  exit 0
fi

# Extract recent conversation context (last 3 messages for efficiency)
context=$(echo "$json_input" | jq -r '
  if .messages then
    .messages[-3:] | map(
      if .role == "user" then "User: \(.text)"
      elif .role == "assistant" then "Assistant: \(.text)"
      else empty
      end
    ) | join("\n")
  else ""
  end
')

# Build the LLM prompt to generate a task name
llm_prompt="Based on this conversation, generate a short task name (1-3 words, hyphenated) that describes what the user is working on.

Recent conversation:
${context}

Current prompt: ${prompt}

Examples of good task names:
- auth-bug-fix
- user-migration
- api-refactor
- worktrunk-config
- add-logging

Generate ONLY the hyphenated task name, nothing else:"

# Generate task name using LLM (with timeout and fallback)
task_name=$(echo "$llm_prompt" | timeout 3s llm -m 4o-mini --system "You generate short, hyphenated task names. Output ONLY the task name." 2>/dev/null || echo "")

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
