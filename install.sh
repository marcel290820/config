#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
source "$SCRIPT_DIR/utils.sh"

# --- Xcode CLI Tools ---

install_xcode_tools() {
  log_info "Checking Xcode Command Line Tools..."
  if xcode-select -p >/dev/null 2>&1; then
    log_success "Xcode Command Line Tools already installed"
    return 0
  fi
  log_info "Installing Xcode Command Line Tools..."
  log_warning "A dialog will appear — complete the installation, then re-run this script"
  xcode-select --install && return 0 || return 1
}

# --- Homebrew ---

install_homebrew() {
  log_info "Checking Homebrew..."
  if command_exists brew; then
    log_success "Homebrew already installed at $(which brew)"
    log_info "Updating Homebrew..."
    brew update || log_warning "Homebrew update failed (continuing)"
    return 0
  fi
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

# --- Brew Bundle ---

install_brew_packages() {
  log_info "Installing packages from Brewfile..."
  brew bundle --file="$SCRIPT_DIR/Brewfile" --no-lock
  log_success "All Brew packages installed"
}

# --- Symlink helper ---

symlink_dotfile() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log_success "$(basename "$target") already symlinked correctly"
      return 0
    fi
    log_warning "$(basename "$target") symlink points elsewhere — backing up and relinking"
    backup_file "$target"
  elif [[ -e "$target" ]]; then
    log_warning "Existing $(basename "$target") found — backing up"
    backup_file "$target"
  fi

  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  log_success "$(basename "$target") symlinked → $target"
}

# --- Template helper ---

install_template() {
  local template="$1"
  local target="$2"
  shift 2
  local required_vars=("$@")

  for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
      log_error "Required env var $var is not set — skipping $(basename "$target")"
      return 1
    fi
  done

  if [[ -f "$target" && ! -L "$target" ]]; then
    backup_file "$target"
  fi

  mkdir -p "$(dirname "$target")"
  envsubst < "$template" > "$target"
  log_success "$(basename "$template") rendered → $target"
}

# --- Copy helper ---

copy_dotfile() {
  local source="$1"
  local target="$2"
  local permissions="${3:-}"

  if [[ -f "$target" && ! -L "$target" ]]; then
    backup_file "$target"
  fi

  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"

  if [[ -n "$permissions" ]]; then
    chmod "$permissions" "$target"
  fi

  log_success "$(basename "$source") copied → $target"
}

# --- TPM ---

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  log_info "Checking Tmux Plugin Manager (TPM)..."
  if [[ -d "$tpm_dir" ]]; then
    log_success "TPM already installed"
    log_info "Updating TPM..."
    (cd "$tpm_dir" && git pull) || log_warning "TPM update failed (continuing)"
    return 0
  fi

  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  log_success "TPM installed — press prefix+I in tmux to install plugins"
}

# --- Main ---

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This script is for macOS only"
    exit 1
  fi

  log_info "Starting macOS setup..."
  log_info "Home directory: $HOME"

  # Step 1: System prerequisites
  install_xcode_tools
  install_homebrew

  # Step 2: Packages
  if command_exists brew; then
    install_brew_packages
  else
    log_error "Homebrew not available — skipping package installation"
    exit 1
  fi

  # Step 3: Symlink dotfiles
  log_info "Symlinking dotfiles..."
  symlink_dotfile "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  symlink_dotfile "$DOTFILES_DIR/.tmux.conf"  "$HOME/.tmux.conf"
  symlink_dotfile "$DOTFILES_DIR/.zshrc"       "$HOME/.zshrc"

  # Claude Code global instructions and skills
  symlink_dotfile "$DOTFILES_DIR/CLAUDE.md"       "$HOME/.claude/CLAUDE.md"
  symlink_dotfile "$DOTFILES_DIR/ARCHITECTURE.md" "$HOME/.claude/ARCHITECTURE.md"
  symlink_dotfile "$DOTFILES_DIR/skills/ci-setup" "$HOME/.claude/skills/ci-setup"

  # Step 4: Template configs (require env vars)
  log_info "Rendering config templates..."
  install_template \
    "$DOTFILES_DIR/opencode.json.tmpl" \
    "$HOME/.config/opencode/opencode.json" \
    NVIDIA_API_KEY CONTEXT7_API_KEY || true

  # Step 5: Copy non-symlinkable configs
  log_info "Copying config files..."
  copy_dotfile "$DOTFILES_DIR/settings.json" "$HOME/.claude/settings.json"
  copy_dotfile "$DOTFILES_DIR/statusline.sh" "$HOME/.claude/statusline.sh" "+x"

  # Step 6: TPM
  if command_exists git; then
    install_tpm
  fi

  log_success "Setup complete!"
  log_info "Restart your terminal or run: source ~/.zshrc"
  log_info "In tmux, press prefix+I to install plugins"
}

# Only run when executed directly, so the helpers can be sourced and tested
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
