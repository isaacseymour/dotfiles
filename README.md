# Isaac's dotfiles

Personal config for shell, editor, terminal, git, and a few macOS tweaks.

## Install on a fresh Mac

```bash
git clone git@github.com:isaacseymour/dotfiles ~/me/dotfiles
cd ~/me/dotfiles
make
```

`make` runs `symlinks brew-bundle vim npm tpm powerline-fonts gpg mac-settings` in turn. The `symlinks` target sets up the `~/.foo` -> `~/me/dotfiles/foo` indirection; the rest installs deps and configures plugins.

## What's where

| Path | Purpose |
|------|---------|
| `zsh/` | shell — zshrc, profile, aliases, functions, agnoster-derived theme with async right-prompt |
| `vim/` | Neovim — vimrc, treesitter, coc.nvim |
| `tmux/tmux.conf` | tmux + tpm plugins (resurrect, continuum, etc.) |
| `kitty/` | Kitty terminal config |
| `git/` | gitconfig with signed commits + custom aliases |
| `gpg/` | GPG/agent config (drduh-derived) |
| `claude/` | Claude Code settings + tmux-integration hooks |
| `bin/` | small helper scripts |
| `Brewfile` | macOS package list — `brew bundle` reads this |
| `mise.toml` | language version pins (Node, etc.) |
| `Makefile` | bootstrap entry point |

## Companion private repo

The "private overlay" — Claude memory and other internal-flavoured config — lives in `isaacseymour/dotfiles-private` and is not referenced from this repo. Clone separately and follow the README there.

## Migration to chezmoi

The Makefile + symlinks setup is being replaced with [chezmoi](https://www.chezmoi.io/). When that lands, `make` will be replaced by a single bootstrap script. Until then the Makefile is authoritative.
