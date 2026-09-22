# AGENTS.md

## Repo purpose

This repository contains macOS dotfiles and a one-command setup. `dotfiles/` is the canonical config source. `install.sh` runs the setup, and `utils.sh` provides its shared shell helpers.

## Source of truth

- `dotfiles/` holds `.gitconfig`, `.tmux.conf`, `.vimrc`, `.zshrc`, and `config.ghostty`.
- `Brewfile` declares every Homebrew package and cask.
- `install.sh` defines the setup flow and symlink targets.
- `utils.sh` contains logging, backup, and command lookup helpers used by `install.sh`.
- Keep config in real files under `dotfiles/`. Do not add inline config to the installer.

## Running the setup

```bash
./install.sh
```

The script installs Xcode Command Line Tools, Homebrew packages, dotfile symlinks, and TPM. It is safe to run again. Existing targets are moved to timestamped backup files before replacement.

## Symlink architecture

`install.sh` creates these links:

- `dotfiles/.gitconfig` -> `~/.gitconfig`
- `dotfiles/.tmux.conf` -> `~/.tmux.conf`
- `dotfiles/.vimrc` -> `~/.vimrc`
- `dotfiles/.zshrc` -> `~/.zshrc`
- `dotfiles/config.ghostty` -> `~/Library/Application Support/com.mitchellh.ghostty/config`

Edits made through a target path update the tracked source. `symlink_dotfile` supports files and directories and creates the target's parent directory.

## Brewfile

Edit the root `Brewfile` when adding or removing a package. Do not install packages from `install.sh` directly.

## Tmux popup keybindings

| Key | Action |
| --- | --- |
| `C-b f` | fzf file picker in Vim |
| `C-b g` | lazygit |
| `C-b N` | Obsidian quick note in Vim |
| `C-b C` | zsh popup |
| `C-b H` | htop |

## Adding a dotfile

1. Place the file in `dotfiles/`.
2. Add a `symlink_dotfile` call in `install.sh`.
3. Add a required package to `Brewfile`.

## Hardcoded paths

- `dotfiles/.tmux.conf` contains the personal Obsidian quick-note path.
- `dotfiles/.zshrc` contains local paths for personal scripts and tools.

## Verification

This repository has no build, test suite, or CI pipeline. Run the available local checks:

```bash
bash -n install.sh utils.sh
brew bundle check --file=Brewfile
vim -Nu dotfiles/.vimrc -n -es '+qa!'
```

Run `./install.sh` only when an end-to-end setup run is intended because it installs packages and updates files in the home directory.
