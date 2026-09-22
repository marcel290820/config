# macOS config

One-command macOS setup for packages and dotfiles.

## Quick start

```bash
git clone <repo-url> && cd config
./install.sh
```

The installer:

1. Installs Xcode Command Line Tools and Homebrew.
2. Installs the packages in `Brewfile`.
3. Symlinks the tracked dotfiles into the home directory.
4. Installs or updates Tmux Plugin Manager (TPM).

It is safe to run the installer again. Existing targets are moved to timestamped backup files before new links replace them.

## Dotfiles

| Source | Target |
| --- | --- |
| `dotfiles/.gitconfig` | `~/.gitconfig` |
| `dotfiles/.tmux.conf` | `~/.tmux.conf` |
| `dotfiles/.vimrc` | `~/.vimrc` |
| `dotfiles/.zshrc` | `~/.zshrc` |
| `dotfiles/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/config` |

The Brew bundle installs Git, GitHub CLI, Ghostty, Vim, tmux, fzf, direnv, lazygit, htop, and the terminal font used by Ghostty.

## Tmux keybindings

| Key | Action |
| --- | --- |
| `C-b f` | Open an fzf file picker in Vim |
| `C-b g` | Open lazygit |
| `C-b N` | Open the Obsidian quick note in Vim |
| `C-b C` | Open a zsh popup |
| `C-b H` | Open htop |

Install tmux plugins with `C-b I` after the first setup run.

## Adding a dotfile

1. Add the file to `dotfiles/`.
2. Add its `symlink_dotfile` call to `install.sh`.
3. Add any required Homebrew package to `Brewfile`.

## Requirements

- macOS on Apple Silicon or Intel
- An internet connection
- Administrator access for Xcode Command Line Tools

## License

Personal use only. Fork and adapt as needed.
