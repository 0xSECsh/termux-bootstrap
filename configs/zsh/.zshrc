# Termux Bootstrap - Default ZSH Configuration

# Prompt
PROMPT='%F{cyan}%n%f@%F{green}%m%f:%F{blue}%~%f %# '

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Options
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
