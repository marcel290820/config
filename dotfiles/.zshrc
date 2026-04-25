# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Git worktree helper alias
alias wtree='~/Documents/Projects/Personal/git-toolkit/worktree-helper.sh'

alias claude-mem='bun "/Users/mheidebrecht/.claude/plugins/cache/thedotmack/claude-mem/12.1.6/scripts/worker-service.cjs"'
