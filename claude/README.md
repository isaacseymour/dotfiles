# Claude Code Configuration

This directory contains personal Claude Code configuration that's shared across all projects.

## Files

- **settings.json** - Claude Code settings (model, status line, plugins, hooks)
- **CLAUDE.md** - Global instructions for Claude (applies to all projects)
- **hooks/** - Shell scripts that run on Claude Code lifecycle events

## Installation

To set up symlinks from `~/.claude`:

```bash
# Backup existing settings if needed
mv ~/.claude/settings.json ~/.claude/settings.json.backup
mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup
mv ~/.claude/hooks ~/.claude/hooks.backup

# Create symlinks
ln -sf ~/me/dotfiles/claude/settings.json ~/.claude/settings.json
ln -sf ~/me/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/me/dotfiles/claude/hooks ~/.claude/hooks
```

## Hooks

### tmux Window Management

Three hooks work together to name and mark tmux windows:

1. **tmux-rename-window.sh** (UserPromptSubmit)
   - Uses AI (via `llm` tool) to generate smart task names from conversation
   - Examples: `auth-bug-fix`, `worktrunk-config`, `issue-migration`
   - Falls back to git repo name if no context

2. **tmux-mark-attention.sh** (Stop)
   - Sends a bell when Claude needs attention (marked with reverse video in tmux status)
   - Triggers on: questions, AskUserQuestion tool, ExitPlanMode tool, approval phrases

3. **tmux-mark-permission.sh** (PermissionRequest)
   - Sends a bell when permission dialogs appear

**Result:** Window names like `worktrunk-config`, with visual bell indicator when input needed.
