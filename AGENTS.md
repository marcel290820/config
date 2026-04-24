# AGENTS.md

## Repo purpose
macOS dotfiles + setup scripts. `dotfiles/` is the canonical config source. Scripts (`configure.sh`, `install-macos.sh`) are secondary — may be simplified or removed.

## Source of truth
- **`dotfiles/`** holds canonical dotfiles (`.tmux.conf`, `opencode.json`, `settings.json`, `statusline.sh`)
- **`configure.sh`** inlines a stale tmux.conf that diverges from `dotfiles/.tmux.conf` (e.g. popup key binds `claude` vs `opencode`). Do **not** trust the inline copy; `dotfiles/.tmux.conf` is correct.
- `.gitconfig` at repo root is the canonical git config (copied to `~/.gitconfig` by `configure.sh`).

## Key divergence
`configure.sh:126-207` — inline tmux heredoc is out of sync with `dotfiles/.tmux.conf`. If editing tmux config, edit `dotfiles/.tmux.conf` only. Do not edit the inline copy in `configure.sh` (it should eventually read from `dotfiles/` instead).

## Running scripts
```bash
./install-macos.sh   # macOS only: xcode CLI tools → homebrew → ghostty/tmux/git → TPM
./configure.sh        # cross-platform: copies .gitconfig + .tmux.conf + ngrok completion to ~/
```
Order: `install-macos.sh` first, then `configure.sh`. Both source `utils.sh` for logging/helpers.

## No build/test/lint
Pure shell repo. No package manager, no CI, no test suite. Validate changes by running the relevant script.

## OpenCode config
`dotfiles/opencode.json` — model + MCP config. Not at repo root. The `.opencode/` dir at root is an Entire CLI plugin (auto-generated, don't edit).

## Tmux popup keybindings (from dotfiles/.tmux.conf)
| Key | Action |
|-----|--------|
| `C-b f` | fzf + nvim file finder |
| `C-b g` | lazygit |
| `C-b y` | opencode popup session |
| `C-b N` | Obsidian quick note |
| `C-b C` | zsh popup |
| `C-b H` | htop |

## Adding new dotfiles
Place in `dotfiles/`. Update `configure.sh` to copy from there (not inline). Follow existing `install_gitconfig()` pattern: backup existing → copy → chmod.

## Hardcoded paths
- `dotfiles/.tmux.conf:19` — Obsidian note path hardcoded to `/Users/mheidebrecht/Library/Mobile Documents/iCloud~md~obsidian/...`
- `dotfiles/settings.json:8` — statusline script path `~/.claude/statusline.sh`
