# Base ZSH Configuration
# This file contains essential shell configuration that works for all setups

# Set Variables
# Syntax highlighting for man pages using bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Change ZSH Options

# Create Alias
#alias ls='ls -lAFh'
alias ls='exa -laFh --git'
alias exa='exa -laFh --git'

# Customisze Prompts
PROMPT='
Samuel:
%1~ %L %# '

RPROMPT='%*'

# Write Handy Functions
Function mkcd() {
  mkdir -p "$@" && cd "$_";
}

# Use ZSH Plugins

# Other
export GPG_TTY=$(tty)

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/desktopofsamuel/.cache/lm-studio/bin"

# Load development-specific configuration if enabled
if [ -f "$HOME/.dev_setup_enabled" ]; then
    if [ -f "$HOME/.zshrc.dev" ]; then
        source "$HOME/.zshrc.dev"
    fi
fi
