################################################################################
## Author:      Devin W. Leaman (4lch4)                                       ##
## Version:     2.0.0                                                         ##
## Filename:    aliases.zsh                                                   ##
## Created On:  07/16/2023 @ 10:23                                            ##
################################################################################
## Description:                                                               ##
##                                                                            ##
## Custom aliases. Aliases that would shadow a real command (ls, tree, ...)   ##
## are only set when the replacement tool is installed.                       ##
################################################################################

#region Git & GitHub
alias ghrc="gh repo clone"
alias gs="git status"
alias gc="git commit -S -m"
alias gui="gitui"
#endregion Git & GitHub

#region Tools
alias dps="docker ps -a"
alias esp="espanso"
alias numi="numi-cli"
alias pvm="pyenv"
alias tg="terragrunt"
alias ail="ailcha"
alias tx="tmux"
alias n="npm"
alias sf="seedfile"

# Remove any existing `t` alias (e.g. from a plugin) before defining mine.
alias t >/dev/null 2>&1 && unalias t
alias t="task"
#endregion Tools

#region Listing
# Remove any existing `l` alias (common-aliases defines one) before defining mine.
alias l >/dev/null 2>&1 && unalias l

if has eza; then
  alias ls="eza"
  alias l="eza -la"
else
  alias l="ls -la"
fi

# Fallback `tree` for machines that don't have the real one.
has tree || alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
#endregion Listing

#region macOS only
if is-macos; then
  alias gk="open /Applications/GitKraken.app"
  alias pwdc="pwd | tr -d '\n' | pbcopy"
fi
#endregion macOS only
