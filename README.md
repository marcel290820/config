# macOS Config

One-command macOS setup — dotfiles, packages, and tool configuration.

## Quick Start

```bash
git clone <repo-url> && cd config
export NVIDIA_API_KEY=...
export CONTEXT7_API_KEY=...
./install.sh
```

## What it does

1. Installs Xcode Command Line Tools
2. Installs/updates Homebrew
3. Installs packages from `Brewfile` (ghostty, tmux, git, fzf, lazygit, htop, neovim)
4. Symlinks dotfiles to `~/` (edits round-trip back to repo)
5. Renders `opencode.json.tmpl` with API keys from env vars
6. Copies `settings.json` and `statusline.sh` to `~/.claude/`
7. Installs Tmux Plugin Manager (TPM)

Idempotent — safe to re-run anytime.

## Dotfiles

| File | Method | Target |
|------|--------|--------|
| `.gitconfig` | symlink | `~/.gitconfig` |
| `.tmux.conf` | symlink | `~/.tmux.conf` |
| `.zshrc` | symlink | `~/.zshrc` |
| `opencode.json.tmpl` | template | `~/.config/opencode/opencode.json` |
| `settings.json` | copy | `~/.claude/settings.json` |
| `statusline.sh` | copy | `~/.claude/statusline.sh` |

Existing files are backed up with timestamps before being replaced.

## Required Environment Variables

| Variable | Used by |
|----------|---------|
| `NVIDIA_API_KEY` | opencode.json (NVIDIA provider) |
| `CONTEXT7_API_KEY` | opencode.json (Context7 MCP) |

If these are not set, the opencode config is skipped with a warning.

## Adding New Config

1. Add the dotfile to `dotfiles/`
2. Add a `symlink_dotfile` or `copy_dotfile` call in `install.sh`
3. If it needs a Brew package, add it to `Brewfile`

## Tmux Keybindings

| Key | Action |
|-----|--------|
| `C-b f` | fzf + nvim file finder |
| `C-b g` | lazygit |
| `C-b y` | opencode popup |
| `C-b N` | Obsidian quick note |
| `C-b C` | zsh popup |
| `C-b H` | htop |

## Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
- Admin privileges (for Xcode CLI Tools)

## License

Personal use only — fork and adapt freely.
