#!/usr/bin/env bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get the home directory path
get_home_dir() {
    echo "$HOME"
}

# Function to create backup of existing file
backup_file() {
    local file_path="$1"
    local backup_path="${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if mv "$file_path" "$backup_path"; then
        log_warning "Existing file backed up to: $backup_path"
        return 0
    else
        log_error "Failed to create backup of $file_path"
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running on macOS
is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}
