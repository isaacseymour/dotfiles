#!/bin/sh
# Install base16-shell (sourced from ~/.zshrc for `base16_materia` etc.).
set -e
DEST="$HOME/.config/base16-shell"
if [ ! -d "$DEST" ]; then
  git clone https://github.com/chriskempson/base16-shell.git "$DEST"
  echo "→ Installed base16-shell at $DEST"
fi
