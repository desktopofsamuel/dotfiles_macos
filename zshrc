

export NVM_DIR="/Users/samuelisme/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Set Variables

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
