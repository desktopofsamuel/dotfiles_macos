# Base ZSH Configuration
# This file contains essential shell configuration that works for all setups

# Set Variables
# Syntax highlighting for man pages using bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export HOMEBREW_CASK_OPTS="--no-quarantine"


# Change ZSH Options
eval "$(try init ~/src/tries)"

# Create Alias
#alias ls='ls -lAFh'
alias exa='eza -laFh --gict'
alias ls='eza'
alias la='eza -la'

# Auto-start SSH agent and load keys
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain ~/.ssh/id_personal
  ssh-add --apple-use-keychain ~/.ssh/id_work
  ssh-add --apple-use-keychain ~/.ssh/id_ai
fi

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

# pnpm
export PNPM_HOME="/Users/desktopofsamuel/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(rbenv init - zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/desktopofsamuel/src/tries/2026-05-07-gcloud-mcp/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/desktopofsamuel/src/tries/2026-05-07-gcloud-mcp/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/desktopofsamuel/src/tries/2026-05-07-gcloud-mcp/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/desktopofsamuel/src/tries/2026-05-07-gcloud-mcp/google-cloud-sdk/completion.zsh.inc'; fi

# Created by `pipx` on 2026-05-07 12:46:18
export PATH="$PATH:/Users/desktopofsamuel/.local/bin"

# Go
export PATH="$PATH:/opt/homebrew/bin:$HOME/go/bin"
