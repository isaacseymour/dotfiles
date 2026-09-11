#!/bin/sh
# Install ccusage, which renders the Claude Code status line.
# settings.json points at ~/.bun/bin/ccusage, so install it with bun.
set -e

if command -v bun >/dev/null 2>&1; then
  BUN=bun
elif command -v mise >/dev/null 2>&1 && mise which bun >/dev/null 2>&1; then
  BUN="mise exec bun -- bun"
else
  echo "→ Skipping ccusage — bun not on PATH. The status line stays blank until you install it."
  exit 0
fi

if [ -x "$HOME/.bun/bin/ccusage" ]; then
  exit 0
fi

$BUN install -g ccusage
echo "→ Installed ccusage at $HOME/.bun/bin/ccusage"
