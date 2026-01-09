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

# Gather git context (branch name and recent commits)
git_context=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Get commit messages since diverging from main/master
  main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "master")
  if git rev-parse "$main_branch" >/dev/null 2>&1; then
    commit_msgs=$(git log --oneline "$main_branch"..HEAD 2>/dev/null | head -5)
  else
    # Fallback to last 3 commits if no main branch
    commit_msgs=$(git log --oneline -3 2>/dev/null)
  fi

  git_context="Branch: $branch_name"
  if [ -n "$commit_msgs" ]; then
    git_context="$git_context
Recent commits:
$commit_msgs"
  fi
fi

# Read recent conversation for additional context (but prioritize git info)
conversation_snippet=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  conversation_snippet=$(tail -50 "$transcript_path" 2>/dev/null | \
    jq -r 'select(.role == "user") | .text[0:100]' 2>/dev/null | \
    tail -3 | head -c 300)
fi

# Build the LLM prompt with git context prioritized
llm_prompt="Generate an EXTREMELY SHORT task name (2-3 words MAX, hyphenated). Focus on the specific technical work being done.

Git context:
${git_context}

Current task: ${prompt}

Recent work: ${conversation_snippet}

RULES:
- Maximum 2-3 words, hyphenated
- Use technical terms, avoid generic words like 'app', 'code', 'fix', 'update'
- Focus on WHAT is being worked on, not the action
- Examples: 'worktrunk-hooks', 'tmux-bell', 'auth-migration', 'incident-api'

Output ONLY the hyphenated name (e.g., 'tmux-integration'):"

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
