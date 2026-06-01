# shellcheck shell=bash
# ~/.bash_aliases - small, clear, and documented for classroom use

# Common navigation
alias ...='cd ..'
alias ls='ls --color=auto'
alias ll='ls -alF'

# Safer file operations
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Git helpers
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Quick python server for sharing files in a VM
alias serve='python3 -m http.server 8000'

# Show last 25 commands
alias hist25='history | tail -n 25'

# Minimal function: ensure a directory exists then cd into it
mcd() {
  mkdir -p -- "$1" && cd -- "$1" || return
}

# End of .bash_aliases
