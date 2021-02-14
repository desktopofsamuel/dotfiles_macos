# Add Locations to $PATH ariable
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

export NVM_DIR="/Users/samuelisme/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Set Variables
# Syntax highlighting for man pages using bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Change ZSH Options

# Create Alias
alias ls='ls -lAFh'

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
