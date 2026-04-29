#!/bin/sh
# Install vim-plug + plugins + coc.nvim extensions on first apply.
set -e
if command -v nvim >/dev/null 2>&1; then
  echo "→ Installing nvim plugins (vim-plug + coc extensions)"
  nvim --headless "+PlugInstall --sync" +qall || true
  nvim --headless "+CocInstall -sync" +qall || true
fi
