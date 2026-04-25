# AGENTS.md

## Repo purpose
macOS dotfiles + one-command setup. `dotfiles/` is the canonical config source. `install.sh` is the only script.

## Source of truth
- **`dotfiles/`** holds all canonical dotfiles (`.gitconfig`, `.tmux.conf`, `.zshrc`, `settings.json`, `statusline.sh`)
- **`dotfiles/opencode.json.tmpl`** is a template — API keys are env vars (`$NVIDIA_API_KEY`, `$CONTEXT7_API_KEY`), rendered at install time via `envsubst`
- No inline config anywhere. All dotfiles are real files in `dotfiles/`.

## Running the setup
```bash
./install.sh
```
Single script: Xcode CLI tools → Homebrew → Brewfile packages → symlink dotfiles → render templates → copy configs → TPM.

Idempotent — safe to re-run.

## Required env vars (for opencode.json template)
- `NVIDIA_API_KEY`
- `CONTEXT7_API_KEY`

Set these before running `install.sh` or the opencode config will be skipped with a warning.

## Symlink architecture
`install.sh` symlinks dotfiles to `~/`:
- `dotfiles/.gitconfig` → `~/.gitconfig`
- `dotfiles/.tmux.conf` → `~/.tmux.conf`
- `dotfiles/.zshrc` → `~/.zshrc`

Edits in `~/` round-trip back to the repo. Existing files are backed up before linking.

Non-symlinkable configs (JSON, scripts) are copied:
- `dotfiles/settings.json` → `~/.claude/settings.json`
- `dotfiles/statusline.sh` → `~/.claude/statusline.sh`
- `dotfiles/opencode.json.tmpl` → `~/.config/opencode/opencode.json` (rendered)

## Brewfile
`Brewfile` at repo root declares all Homebrew packages. Edit there, not in a script.

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
1. Place file in `dotfiles/`
2. Add a `symlink_dotfile` or `copy_dotfile` call in `install.sh`
3. If it's a Brew package, add to `Brewfile`

## Hardcoded paths
- `dotfiles/.tmux.conf:19` — Obsidian note path hardcoded to `/Users/mheidebrecht/Library/Mobile Documents/iCloud~md~obsidian/...`
- `dotfiles/settings.json:8` — statusline script path `~/.claude/statusline.sh`
- `dotfiles/.zshrc` — `wtree` alias path, `claude-mem` alias path

## No build/test/lint
Pure shell repo. No package manager, no CI, no test suite. Validate by running `./install.sh`.
