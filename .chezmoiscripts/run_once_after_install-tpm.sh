#!/bin/sh
# Install tmux plugin manager (tpm) so tmux.conf's plugins work.
set -e
DEST="$HOME/.tmux/plugins/tpm"
if [ ! -d "$DEST" ]; then
  git clone https://github.com/tmux-plugins/tpm "$DEST"
  echo "→ Installed tpm at $DEST"
fi
