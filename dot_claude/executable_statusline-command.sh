#!/bin/sh
# Claude Code status line
# Shows: git-root-name  model  context%  session-cost  today-cost

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Find git root folder name (just the basename of the repo root)
project_name=""
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$git_root" ]; then
  project_name=$(basename "$git_root")
else
  project_name=$(basename "$cwd")
fi

# Session cost: prefer Claude Code's own cumulative figure, which accounts for
# cache-creation and cache-read tokens (the bulk of real spend) across every turn.
# Estimating from .context_window token counts is wrong — those are the current
# context snapshot and exclude cache tokens, undercounting by ~10x.
cost_val=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Fallback: if .cost is unavailable, estimate from input/output tokens by model.
# Opus: $15/M in, $75/M out | Sonnet: $3/M in, $15/M out | Haiku: $0.80/M in, $4/M out
if [ -z "$cost_val" ]; then
  input_price=3.0
  output_price=15.0
  case "$model" in
    *[Oo]pus*)   input_price=15.0; output_price=75.0 ;;
    *[Hh]aiku*)  input_price=0.80; output_price=4.0 ;;
  esac
  if [ "$total_input" -gt 0 ] 2>/dev/null || [ "$total_output" -gt 0 ] 2>/dev/null; then
    cost_val=$(awk -v inp="$total_input" -v out="$total_output" -v ip="$input_price" -v op="$output_price" \
      'BEGIN { printf "%.6f", (inp / 1000000 * ip) + (out / 1000000 * op) }')
  fi
fi

session_cost=""
if [ -n "$cost_val" ]; then
  session_cost=$(awk -v c="$cost_val" 'BEGIN { printf "$%.3f", c }')
fi

# Today's cost: persist this session's cumulative cost keyed by session id, then
# sum all session files touched today.
if [ -n "$cost_val" ]; then
  session_id=$(echo "$input" | jq -r '.session_id // empty')
  if [ -n "$session_id" ]; then
    session_file="/tmp/claude_session_cost_${session_id}.txt"
    echo "$cost_val" > "$session_file"
  fi
fi

# Sum all session cost files for today
today_total=0
for f in /tmp/claude_session_cost_*.txt; do
  [ -f "$f" ] || continue
  # Only count files modified today
  file_date=$(date -r "$f" +%Y%m%d 2>/dev/null)
  today_date=$(date +%Y%m%d)
  if [ "$file_date" = "$today_date" ]; then
    val=$(cat "$f" 2>/dev/null)
    today_total=$(awk -v a="$today_total" -v b="${val:-0}" 'BEGIN { printf "%.6f", a + b }')
  fi
done
today_cost=$(awk -v t="$today_total" 'BEGIN { if (t > 0) printf "$%.3f", t; else print "" }')

# Build output — project name prominently in blue
printf "\033[34;1m%s\033[0m" "$project_name"

# Model name prominently in white/bold
if [ -n "$model" ]; then
  printf "  \033[1m%s\033[0m" "$model"
fi

# Context usage
if [ -n "$used_pct" ]; then
  printf "  \033[90mctx: %s%%\033[0m" "$(printf '%.0f' "$used_pct")"
fi

# Session cost
if [ -n "$session_cost" ]; then
  printf "  \033[36msession: %s\033[0m" "$session_cost"
fi

# Today's total cost
if [ -n "$today_cost" ]; then
  printf "  \033[36mtoday: %s\033[0m" "$today_cost"
fi

printf "\n"
