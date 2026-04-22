#!/usr/bin/env bash

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Function to ensure ngrok shell completions are added to the user's .zshrc (idempotent)
install_ngrok_completion() {
    local home_dir="$(get_home_dir)"
    local zshrc_file="$home_dir/.zshrc"
    local required_snippet=$'if command -v ngrok &>/dev/null; then\n    eval "$(ngrok completion)"\nfi'
    local first_line='if command -v ngrok &>/dev/null; then'

    log_info "Ensuring exact ngrok completion snippet present in .zshrc..."

    # Skip if ngrok not installed (don't add placeholder)
    if ! command_exists ngrok; then
        log_warning "ngrok not found in PATH - skipping completion snippet"
        return 0
    fi

    # Ensure file exists
    if [[ ! -f "$zshrc_file" ]]; then
        if ! touch "$zshrc_file"; then
            log_error "Failed to create $zshrc_file"
            return 1
        fi
    fi

    # Remove any previously added marker-based block (legacy cleanup)
    if grep -Fq '# >>> ngrok completion (config repo) >>>' "$zshrc_file"; then
        if ! backup_file "$zshrc_file"; then
            log_warning "Could not backup before cleanup"
        fi
        # Delete lines between the markers inclusive
        tmp_file="${zshrc_file}.tmp.$$"
        awk '/# >>> ngrok completion (config repo) >>>/{flag=1;next} /# <<< ngrok completion (config repo) <<< /{flag=0;next} !flag {print}' "$zshrc_file" > "$tmp_file" && mv "$tmp_file" "$zshrc_file"
        log_info "Removed legacy ngrok completion block"
    fi

    # Detect if exact snippet already exists (match first line and eval line pattern)
    if grep -Fq "$first_line" "$zshrc_file" && grep -Fq 'eval "$(ngrok completion)"' "$zshrc_file"; then
        # Further validate contiguous block
        if grep -Fq "$required_snippet" "$zshrc_file"; then
            log_success "Exact ngrok completion snippet already present"
            return 0
        fi
    fi

    # Backup before appending new snippet
    if ! backup_file "$zshrc_file"; then
        log_warning "Proceeding without .zshrc backup (backup failed)"
    fi

    {
        echo "" # newline separation
        printf '%s\n' "$required_snippet"
    } >> "$zshrc_file"

    if [[ $? -eq 0 ]]; then
        log_success "ngrok completion snippet appended to .zshrc"
        log_info "Reload with: source ~/.zshrc"
    else
        log_error "Failed to append ngrok completion snippet"
        return 1
    fi
}

# Function to install .gitconfig
install_gitconfig() {
    local source_file="$SCRIPT_DIR/.gitconfig"
    local home_dir="$(get_home_dir)"
    local target_file="$home_dir/.gitconfig"
    
    log_info "Installing .gitconfig..."
    
    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        log_error ".gitconfig not found in $SCRIPT_DIR"
        return 1
    fi
    
    # Check if target file already exists
    if [[ -f "$target_file" ]]; then
        log_warning "Existing .gitconfig found at $target_file"
        
        # Create backup
        if ! backup_file "$target_file"; then
            return 1
        fi
    fi
    
    # Copy the file
    if cp "$source_file" "$target_file"; then
        log_success ".gitconfig installed successfully to $target_file"
        
        # Set appropriate permissions
        chmod 644 "$target_file"
        log_info "Set permissions (644) for .gitconfig"
        
        return 0
    else
        log_error "Failed to copy .gitconfig to $target_file"
        return 1
    fi
}

# Function to install .tmux.conf
install_tmux_conf() {
    local home_dir="$(get_home_dir)"
    local target_file="$home_dir/.tmux.conf"
    
    log_info "Installing .tmux.conf..."
    
    # Check if target file already exists
    if [[ -f "$target_file" ]]; then
        log_warning "Existing .tmux.conf found at $target_file"
        
        # Create backup
        if ! backup_file "$target_file"; then
            return 1
        fi
    fi
    
    # Create the tmux configuration
    cat > "$target_file" << 'EOF'
# -- Basic Settings ------------------------------------------
set -g @continuum-restore 'on'
set -g @continuum-boot 'on'
set -g @continuum-save-interval '5'
set -g mouse on
set -g prefix C-b
set -g escape-time 500
set -g history-limit 50000
set -g base-index 1
setw -g pane-base-index 1

setw -g mode-keys vi

set-option -g renumber-windows on

bind-key f display-popup -E "find . -type f | fzf | xargs nvim"
bind-key H display-popup -E "htop"
bind-key N display-popup -E "nvim /Users/mheidebrecht/Library/Mobile Documents/iCloud~md~obsidian/Documents/Marcels Second Brain/Notes/quick-note.md"
bind-key C display-popup -w 80% -h 60% -E "bash"
bind-key g display-popup -w 80% -h 80% -E "git status && echo 'Press any key to close' && read"

# Tmux Plugin Manager (TPM) - Essential plugin manager for tmux
set -g @plugin 'tmux-plugins/tpm'

# Theme
set -g @plugin 'arcticicestudio/nord-tmux'

# Tmux sensible defaults - Basic tmux settings that everyone can agree on
set -g @plugin 'tmux-plugins/tmux-sensible'

# Session persistence plugins
set -g @plugin 'tmux-plugins/tmux-resurrect'  # Save and restore tmux sessions
set -g @plugin 'tmux-plugins/tmux-continuum'  # Continuous saving of tmux environment

# Other plugins
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'tmux-plugins/tmux-copycat'
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
set -g @plugin 'tmux-plugins/tmux-battery'
set -g @plugin 'tmux-plugins/tmux-sidebar'

# -- Status Bar ---------------------------------------------
set -g @nord_tmux_show_status_content "0"
set -g status-position bottom
set -g status-interval 1
set -g status-left "#{session_name} "
set -g status-left-length 50
set -g status-right-length 200

# -- Custom Nord Tmux Extended Status Bar -------------------
# Copyright (c) 2016-present Sven Greb <development@svengreb.de>
# This source code is licensed under the MIT license found in the license file.

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
set -g @prefix_highlight_output_prefix "#[fg=brightcyan]#[bg=black]#[nobold]#[noitalics]#[nounderscore]#[bg=brightcyan]#[fg=black]"
set -g @prefix_highlight_output_suffix ""
set -g @prefix_highlight_copy_mode_attr "fg=brightcyan,bg=black,bold"

#+--------+
#+ Status +
#+--------+
#+--- Bars ---+
set -g status-left "#[fg=black,bg=blue,bold] #S #[fg=blue,bg=black,nobold,noitalics,nounderscore]"
set -g status-right "#{prefix_highlight}#[fg=brightblack,bg=black,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %Y-%m-%d #[fg=white,bg=brightblack,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %H:%M #[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]#[fg=black,bg=cyan,bold] #H "

#+--- Windows ---+
set -g window-status-format "#[fg=black,bg=brightblack,nobold,noitalics,nounderscore] #[fg=white,bg=brightblack]#I #[fg=white,bg=brightblack,nobold,noitalics,nounderscore] #[fg=white,bg=brightblack]#W #F #[fg=brightblack,bg=black,nobold,noitalics,nounderscore]"
set -g window-status-current-format "#[fg=black,bg=cyan,nobold,noitalics,nounderscore] #[fg=black,bg=cyan]#I #[fg=black,bg=cyan,nobold,noitalics,nounderscore] #[fg=black,bg=cyan]#W #F #[fg=cyan,bg=black,nobold,noitalics,nounderscore]"
set -g window-status-separator ""


# Initialize TPM (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
    
    if [[ $? -eq 0 ]]; then
        log_success ".tmux.conf installed successfully to $target_file"
        
        # Set appropriate permissions
        chmod 644 "$target_file"
        log_info "Set permissions (644) for .tmux.conf"
        
        # Reload tmux configuration if tmux is currently running
        if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
            log_info "Tmux is running - reloading configuration..."
            if tmux source "$target_file"; then
                log_success "Tmux configuration reloaded successfully"
            else
                log_warning "Failed to reload tmux configuration, but continuing..."
                log_info "You can manually reload with: tmux source ~/.tmux.conf"
            fi
        else
            log_info "Tmux not running - configuration will be loaded on next tmux start"
        fi
        
        return 0
    else
        log_error "Failed to create .tmux.conf at $target_file"
        return 1
    fi
}

# Main installation function
main() {
    log_info "Starting configuration installation..."
    log_info "Detected OS: $(uname -s)"
    log_info "Home directory: $(get_home_dir)"
    
    # Install .gitconfig
    if ! install_gitconfig; then
        log_error "Installation failed!"
        exit 1
    fi

    # Install .tmux.conf
    if ! install_tmux_conf; then
        log_error "Installation failed!"
        exit 1
    fi

    # Install ngrok completion (non-fatal if it fails)
    if ! install_ngrok_completion; then
        log_warning "ngrok completion setup encountered an issue (continuing)"
    fi
    
    log_success "All configurations installed successfully!"
}

# Run main function
main "$@"


