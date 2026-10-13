# Config

Personal configuration files for AI agents, Claude Code, Git, Ghostty, herdr,
Neovim, tmux, Vim, and Zsh. This repo contains no software installer or package list.

| Config | Location on macOS |
| --- | --- |
| `agents/AGENTS.md` | `~/.agents/AGENTS.md` |
| `claude/statusline.sh` | `~/.claude/statusline.sh` |
| `git/config` | `~/.gitconfig` |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `herdr/herdr-new` | `~/.local/bin/herdr-new` |
| `nvim/` | `~/.config/nvim/` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `vim/vimrc` | `~/.vimrc` |
| `zsh/zshrc` | `~/.zshrc` |

## Using these configs

The configs are generalized: they use `~` and `$HOME` instead of absolute
paths, and they hold no hosts, accounts, or private tools. Live configs on a
machine usually evolve faster than this repo, so never copy a file over an
existing config blindly:

1. Back up the target first, for example `cp ~/.zshrc ~/.zshrc.bak`.
2. Diff the repo file against the target and merge the parts you want.

This repo does not change files in your home directory.

## Local overrides

Machine-specific or private settings stay in untracked files next to the live
config. The tracked configs load them when they exist:

| Local file | Loaded by |
| --- | --- |
| `~/.zshrc.local` | `zsh/zshrc` |
| `~/.tmux.local.conf` | `tmux/tmux.conf` |
| `~/.agents/AGENTS.local.md` | `agents/AGENTS.md` |

SSH config is not tracked at all; it is entirely host- and account-specific.

The configs reference some external tools, tmux plugins, and agent skills.
They configure those integrations but do not install or manage them.

Run `.codex/check.sh` to validate the configs with their installed apps.
