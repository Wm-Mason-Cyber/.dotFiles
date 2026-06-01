
#!/usr/bin/env bash
# ~/.bashrc - sensible defaults for students and instructors
# Simple, easy-to-read, and safe for classroom VMs.

# Only run in interactive shells (set BASH_TESTING=1 to bypass in automated tests)
[[ $- != *i* ]] && [[ -z "${BASH_TESTING:-}" ]] && return

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Path additions (do not overwrite existing PATH)
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Load user aliases and helpers if present
if [ -f "$HOME/.bash_aliases" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.bash_aliases"
fi

# Helpful default umask for multi-user VMs
umask 0022

# Enable colorized ls if possible
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Safe defaults for editors
: "${EDITOR:=vim}"
: "${VISUAL:=$EDITOR}"

# Enable bash completion if available
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    # shellcheck source=/dev/null
    . /etc/bash_completion
fi

#### Prompt configuration (colors, git branch, root indicator)
# Environment variables (optional, set before sourcing this file):
#  DOTFILES_PS_USER_COLOR   - color for the username
#  DOTFILES_PS_HOST_COLOR   - color for the hostname
#  DOTFILES_PS_CWD_COLOR    - color for the working directory
#  DOTFILES_PS_GIT_COLOR    - color for the git branch indicator
#  DOTFILES_PS_ROOT_COLOR   - color for the prompt symbol when root
# Use tput setaf N or raw ANSI escapes.

if command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    : "${DOTFILES_PS_USER_COLOR:=$(tput setaf 2)}"   # green
    : "${DOTFILES_PS_HOST_COLOR:=$(tput setaf 6)}"   # cyan
    : "${DOTFILES_PS_CWD_COLOR:=$(tput setaf 4)}"    # blue
    : "${DOTFILES_PS_GIT_COLOR:=$(tput setaf 3)}"    # yellow
    : "${DOTFILES_PS_ROOT_COLOR:=$(tput setaf 1)}"   # red
    RESET_SEQ="$(tput sgr0)"
else
    DOTFILES_PS_USER_COLOR=""
    DOTFILES_PS_HOST_COLOR=""
    DOTFILES_PS_CWD_COLOR=""
    DOTFILES_PS_GIT_COLOR=""
    DOTFILES_PS_ROOT_COLOR=""
    RESET_SEQ=""
fi

# Helper: wrap a color sequence in PS1 non-printing markers
_esc() { printf '%s' "\[${1}\]"; }
USER_COLOR_ESC=$(_esc "$DOTFILES_PS_USER_COLOR")
HOST_COLOR_ESC=$(_esc "$DOTFILES_PS_HOST_COLOR")
CWD_COLOR_ESC=$(_esc "$DOTFILES_PS_CWD_COLOR")
GIT_COLOR_ESC=$(_esc "$DOTFILES_PS_GIT_COLOR")
ROOT_COLOR_ESC=$(_esc "$DOTFILES_PS_ROOT_COLOR")
RESET_ESC=$(_esc "$RESET_SEQ")

# Lightweight git branch helper (only runs when inside a git repo)
git_branch() {
    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null \
                 || git rev-parse --short HEAD 2>/dev/null)
        [ -n "$branch" ] && printf '%s' "$branch"
    fi
    true  # always exit 0; callers may run under set -e
}

# Print '*' if the working tree has uncommitted changes
git_dirty() {
    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        [ -n "$(git status --porcelain 2>/dev/null)" ] && printf '*'
    fi
    true  # always exit 0; callers may run under set -e
}

# Prompt symbol: # for root, $ for normal users
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    PROMPT_SYMBOL="#"
    PROMPT_SYMBOL_ESC=$ROOT_COLOR_ESC
else
    PROMPT_SYMBOL="\$"
    PROMPT_SYMBOL_ESC=$USER_COLOR_ESC
fi

# Prompt style: short (default) or verbose. Override with DOTFILES_PROMPT_STYLE env var.
: "${DOTFILES_PROMPT_STYLE:=short}"

# Named color presets: 'school', 'night', 'high-contrast'
dotfiles_prompt_preset() {
    case "$1" in
        school)
            DOTFILES_PS_USER_COLOR="$(tput setaf 2  2>/dev/null || true)"
            DOTFILES_PS_HOST_COLOR="$(tput setaf 6  2>/dev/null || true)"
            DOTFILES_PS_CWD_COLOR="$(tput setaf 4  2>/dev/null || true)"
            DOTFILES_PS_GIT_COLOR="$(tput setaf 3  2>/dev/null || true)"
            DOTFILES_PS_ROOT_COLOR="$(tput setaf 1  2>/dev/null || true)"
            ;;
        night)
            DOTFILES_PS_USER_COLOR="$(tput setaf 5  2>/dev/null || true)"
            DOTFILES_PS_HOST_COLOR="$(tput setaf 4  2>/dev/null || true)"
            DOTFILES_PS_CWD_COLOR="$(tput setaf 6  2>/dev/null || true)"
            DOTFILES_PS_GIT_COLOR="$(tput setaf 11 2>/dev/null || tput setaf 3 2>/dev/null || true)"
            DOTFILES_PS_ROOT_COLOR="$(tput setaf 1  2>/dev/null || true)"
            ;;
        high-contrast)
            DOTFILES_PS_USER_COLOR="$(tput setaf 15 2>/dev/null || tput setaf 7  2>/dev/null || true)"
            DOTFILES_PS_HOST_COLOR="$(tput setaf 12 2>/dev/null || tput setaf 4  2>/dev/null || true)"
            DOTFILES_PS_CWD_COLOR="$(tput setaf 14 2>/dev/null || tput setaf 6  2>/dev/null || true)"
            DOTFILES_PS_GIT_COLOR="$(tput setaf 13 2>/dev/null || tput setaf 5  2>/dev/null || true)"
            DOTFILES_PS_ROOT_COLOR="$(tput setaf 9  2>/dev/null || tput setaf 1  2>/dev/null || true)"
            ;;
        *)
            echo "Usage: dotfiles_prompt_preset <school|night|high-contrast>" >&2
            return 2
            ;;
    esac
    USER_COLOR_ESC=$(_esc "$DOTFILES_PS_USER_COLOR")
    HOST_COLOR_ESC=$(_esc "$DOTFILES_PS_HOST_COLOR")
    CWD_COLOR_ESC=$(_esc "$DOTFILES_PS_CWD_COLOR")
    GIT_COLOR_ESC=$(_esc "$DOTFILES_PS_GIT_COLOR")
    ROOT_COLOR_ESC=$(_esc "$DOTFILES_PS_ROOT_COLOR")
    RESET_ESC=$(_esc "$RESET_SEQ")
    build_ps1
}

# Build PS1 from DOTFILES_PROMPT_STYLE.
# Called by PROMPT_COMMAND before each prompt so git info is always current.
build_ps1() {
    case "$DOTFILES_PROMPT_STYLE" in
        short)
            PS1="${USER_COLOR_ESC}\u${RESET_ESC}:${CWD_COLOR_ESC}\w${RESET_ESC} ${PROMPT_SYMBOL_ESC}${PROMPT_SYMBOL}${RESET_ESC} "
            ;;
        verbose)
            local _branch _dirty _git_part
            _branch=$(git_branch)
            _dirty=$(git_dirty)
            if [ -n "$_branch" ]; then
                _git_part=" ${GIT_COLOR_ESC}${_branch}${_dirty}${RESET_ESC}"
            else
                _git_part=""
            fi
            PS1="${USER_COLOR_ESC}\u${RESET_ESC}@${HOST_COLOR_ESC}\h${RESET_ESC}:${CWD_COLOR_ESC}\w${RESET_ESC}${_git_part} ${PROMPT_SYMBOL_ESC}${PROMPT_SYMBOL}${RESET_ESC} "
            ;;
        *)
            PS1="${USER_COLOR_ESC}\u${RESET_ESC}:${CWD_COLOR_ESC}\w${RESET_ESC} ${PROMPT_SYMBOL_ESC}${PROMPT_SYMBOL}${RESET_ESC} "
            ;;
    esac
}

# Convenience functions to switch styles at runtime
prompt_short()   { export DOTFILES_PROMPT_STYLE=short;   build_ps1; }
prompt_verbose() { export DOTFILES_PROMPT_STYLE=verbose; build_ps1; }

# Rebuild PS1 before each prompt (keeps git branch current in verbose mode)
PROMPT_COMMAND='build_ps1'

# End of .bashrc
