################################################################################
## Author:      Devin W. Leaman (jisodl0)                                     ##
## Version:     1.0.0                                                         ##
## Filename:    aliases.sh                                                    ##
## Created On:  07/16/2023 @ 10:23                                            ##
################################################################################
## Description:                                                               ##
##                                                                            ##
##                                                                            ##
## A bash script that contains custom aliases I use in my terminals.          ##
################################################################################
## Usage:                                                                     ##
##                                                                            ##
## source ./aliases.sh                                                        ##
################################################################################

alias ghrc="gh repo clone"
alias gs="git status"
alias gc="git commit -S -m"

alias gui="gitui"

alias dps="docker ps -a"

alias esp="espanso"

alias numi="numi-cli"

# Check if an alias exists for `t`. If so, unalias it.
alias t > /dev/null 2>&1 && unalias t
alias t="task"

alias ghrc="gh repo clone"

alias pvm="pyenv"

alias tg="terragrunt"

alias cobra="~/go/bin/cobra-cli"

alias ail="ailcha"

alias tx="tmux"

alias n="npm"

alias gk="open /Applications/GitKraken.app"

alias pwdc="pwd | tr -d '\n' | pbcopy"

alias air="~/go/bin/air"

alias glint="golangci-lint run ./..."

alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

alias sf="seedfile"

# Check if an alias exists for `l`. If so, unalias it.
alias l > /dev/null 2>&1 && unalias l
alias l="exa -la"

alias ls="exa"
