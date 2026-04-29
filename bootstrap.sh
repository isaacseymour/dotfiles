#!/bin/bash
# Isaac's dotfiles bootstrap. Public; safe to curl|bash on a fresh Mac:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/isaacseymour/dotfiles/master/bootstrap.sh)"
#
# Gets you to a working chezmoi-managed shell. Manual finishing steps
# (Dashlane, 1Password, gh auth, age key) are documented at the end.

set -euo pipefail

step() { printf "\n\033[34;1m== %s ==\033[0m\n" "$*"; }
note() { printf "  \033[90m%s\033[0m\n" "$*"; }

# 1. Xcode CLT (provides git, cc, make — needed by Homebrew install)
if ! xcode-select -p &>/dev/null; then
  step "Installing Xcode Command Line Tools"
  xcode-select --install
  note "Click 'Install' in the dialog, then re-run this bootstrap once it finishes."
  exit 0
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  step "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Source brew env so brew/chezmoi/etc are on PATH for the rest of this run.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Bootstrap-only tools (chezmoi will install the rest via Brewfile)
step "Installing bootstrap tools"
brew install chezmoi gh age 1password-cli
brew install --cask 1password dashlane

# 4. Clone dotfiles to ~/me/dotfiles (the canonical location).
DOTFILES="$HOME/me/dotfiles"
if [[ ! -d "$DOTFILES/.git" ]]; then
  step "Cloning dotfiles to $DOTFILES"
  mkdir -p "$(dirname "$DOTFILES")"
  git clone https://github.com/isaacseymour/dotfiles.git "$DOTFILES"
fi

# 5. Initial chezmoi init+apply. This will:
#    - render ~/.config/chezmoi/chezmoi.toml from .chezmoi.toml.tmpl
#    - apply all chezmoi-managed files
#    - run run_once_* scripts (Brewfile, tpm, base16-shell, vim plugins, macOS defaults)
#    The private overlay is skipped on this first run (no SSH yet).
step "Running chezmoi init + apply"
chezmoi init --apply --source "$DOTFILES"

cat <<'EOF'

================================================================
  Almost there. Manual finishing steps:

  1. Sign in to 1Password (GUI) and enable
       Settings → Developer → "Connect with 1Password CLI"
     so chezmoi templates can read secrets via `op`.

  2. Sign in to Dashlane (GUI). Find the secure note titled
       "age master key"
     and copy its value into
       ~/.config/chezmoi/key.txt
     (chmod 600 it).

  3. Authenticate GitHub (browser flow):
       gh auth login

  4. Generate an SSH key for this machine and upload it:
       ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
       gh ssh-key add ~/.ssh/id_ed25519.pub

  5. Re-run chezmoi to pick up the private overlay:
       chezmoi apply

  All done — open a new terminal and you're home.
================================================================
EOF
