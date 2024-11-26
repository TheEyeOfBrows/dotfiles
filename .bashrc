#!/bin/bash
HERE="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

alias ls='ls -F --color=auto --show-control-chars'
alias ll='ls -alF'

# Term colours
USER_HOST_COLOR="\[\033[01;32m\]"
PATH_COLOR="\[\033[01;34m\]"
GIT_BRANCH_COLOR="\[\e[91m\]"
RESET="\[\033[00m\]"

source "${HERE}/git-prompt.sh"

export PS1="${USER_HOST_COLOR}\u@\h${RESET}:${PATH_COLOR}\w${GIT_BRANCH_COLOR}\$(__git_ps1 \" (%s)\")${RESET}\$ "