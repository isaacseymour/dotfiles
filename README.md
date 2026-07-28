# Isaac's dotfiles

Personal config managed by [chezmoi](https://www.chezmoi.io/).

## Bootstrap on a fresh Mac

> **Public bootstrap is intentionally simple** so it works before you have
> SSH/GitHub auth set up. Once you've authenticated to GitHub, the private
> overlay (Claude memory, work-flavoured config) gets pulled in automatically
> on the next `chezmoi apply`.

```bash
# 1. Use Safari to download Chrome.
# 2. Install Xcode CLT.
xcode-select --install

# 3. Install Homebrew.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. Install chezmoi + the password managers + age.
brew install chezmoi gh age 1password-cli
brew install --cask 1password dashlane

# 5. Sign into both password managers (GUI). For Dashlane: copy the
#    "age master key" secure note into ~/.config/chezmoi/key.txt
#    (chmod 600). For 1Password: enable CLI biometric integration in
#    its settings.

# 6. GitHub auth (for the private overlay).
gh auth login                    # browser flow in Chrome
gh ssh-key add                   # uploads a fresh SSH key

# 7. Bootstrap chezmoi.
chezmoi init --apply isaacseymour
```

`chezmoi init --apply` clones this repo into `~/.local/share/chezmoi`,
renders all templates, and writes the result to `$HOME`. Re-run
`chezmoi apply` to pick up new commits.

## Day-to-day

| Action | Command |
|--------|---------|
| Edit a managed file | `chezmoi edit ~/.zshrc` |
| Pull latest, then apply | `chezmoi update` |
| See what would change | `chezmoi diff` |
| Add an existing file | `chezmoi add ~/.foo` |
| Open the source repo | `chezmoi cd` |

The source dir is at `~/me/dotfiles` (configured via
`~/.config/chezmoi/chezmoi.toml`). Files live in chezmoi naming:

| Source path | Target |
|-------------|--------|
| `dot_zshrc` | `~/.zshrc` |
| `dot_zsh/` | `~/.zsh/` |
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` (templated by arch) |
| `private_dot_gnupg/` | `~/.gnupg/` (mode 700) |
| `private_dot_ssh/` | `~/.ssh/` (mode 700) |
| `dot_claude/` | `~/.claude/` |
| `dot_local/bin/executable_*` | `~/.local/bin/*` (chmod +x) |

## macOS sleep behaviour

Remote-controlled sessions (cmux, ssh) used to die whenever the screen got
locked or the lid closed, because macOS ships two separate behaviours:

- **Idle sleep.** The system-sleep countdown only starts once the display is
  off, and the stock AC timer is 1 minute — so locking the screen dropped the
  network ~60s later. `pmset -c sleep 0` fixes this.
- **Clamshell sleep.** Closing the lid sleeps immediately, ignoring the timers.
  The only knob that stops it is `pmset disablesleep`, which is *system-wide*
  rather than per power source.

Since leaving `disablesleep` on permanently would keep a bagged laptop awake
until the battery was flat, `com.isaac.ac-nosleep` (a root LaunchDaemon, see
`.chezmoiscripts/run_onchange_after_macos-power.sh.tmpl`) watches
`pmset -g pslog` and flips it with the power source: never sleep on AC, stock
behaviour on battery. It logs transitions to `/var/log/ac-nosleep.log`.

Because it writes to `/Library/LaunchDaemons` and `/usr/local/sbin`, that one
script needs `sudo` at apply time; it skips itself if there's no TTY to prompt
on. To back it all out:

```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.isaac.ac-nosleep.plist
sudo rm /Library/LaunchDaemons/com.isaac.ac-nosleep.plist /usr/local/sbin/ac-nosleep
sudo pmset -a disablesleep 0
```

## Companion private repo

`isaacseymour/dotfiles-private` holds Claude Code memory and any
work-flavoured config that shouldn't be public. It's pulled in via
chezmoi's `.chezmoiexternal`, gated on having an SSH key with access.
On the very first `chezmoi apply` (before `gh ssh-key add`) the external
is skipped; a follow-up apply picks it up.

## Secrets

Two-password-manager split:

- **Dashlane (personal):** stores the **age master key** as a secure note.
  Personal secrets (GPG private key, etc.) live age-encrypted in the
  private repo and decrypt on apply.
- **1Password (work):** referenced from chezmoi templates via
  `{{ onepasswordRead "op://..." }}`. Whole-file env files use
  `op inject` from a small helper script.

Neither password manager's CLI is on the bootstrap critical path beyond
"have it installed and signed in"; chezmoi pulls from them at apply time
and caches.
