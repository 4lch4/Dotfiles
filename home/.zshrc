# ~/.zshrc, managed by https://github.com/4lch4/Dotfiles.
# This file is a symlink into the repo, so edit it there. Machine-specific
# settings go in ~/.config/zsh/local.zsh, which isn't tracked.

export ZSH_CFG_DIR="$HOME/.config/zsh"

# Helpers used here and in ~/.config/zsh/*.zsh.
has() { (( $+commands[$1] )) }
is-macos() { [[ "$OSTYPE" == darwin* ]] }

# Environment first.
#region Directory Variables
CONFIG_DIR="$HOME/.config"
DEVELOPMENT_DIR="$HOME/Development"

# Loaded by the oh-my-zsh nvm plugin.
export NVM_DIR="$HOME/.nvm"
#endregion Directory Variables

#region oh-my-zsh settings (must be set before oh-my-zsh.sh is sourced)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="steeef"
HIST_STAMPS="yyyy-mm-dd"

# Most of these only add aliases/completions when the tool is installed.
plugins=(
  colorize
  command-not-found
  common-aliases
  docker
  docker-compose
  doctl
  dotenv
  extract
  gh
  git
  kubectl
  npm
  nvm
  rsync
  rust
  sudo
  terraform
  tmux
  urltools
  vscode
)
is-macos && plugins+=(brew)
#endregion oh-my-zsh settings

# Third-party plugins that must be on fpath before oh-my-zsh runs compinit
# (see ~/.zsh_plugins.txt).
source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
antidote load "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"

source "$ZSH/oh-my-zsh.sh"

# fzf key bindings/completion. Newer fzf (0.48+) generates them itself; older
# Ubuntu packages ship them as files, which minimal images may have stripped.
if has fzf; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for f in ~/.fzf.zsh /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh; do
      [[ -f "$f" ]] && source "$f"
    done
    unset f
  fi
fi
has zoxide && eval "$(zoxide init zsh)"
has doppler && source <(doppler completion 2>/dev/null)

# My customizations go last so nothing above overrides them.
source "$ZSH_CFG_DIR/functions.zsh"
source "$ZSH_CFG_DIR/aliases.zsh"

# Per-machine overrides.
[[ -f "$ZSH_CFG_DIR/local.zsh" ]] && source "$ZSH_CFG_DIR/local.zsh"

# Plugins that must load after everything else (see ~/.zsh_plugins.post.txt).
antidote load "${ZDOTDIR:-$HOME}/.zsh_plugins.post.txt"

# Don't let a missing optional file above make the shell start with an error code.
true
