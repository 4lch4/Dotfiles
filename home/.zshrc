# ~/.zshrc, managed by https://github.com/4lch4/Dotfiles.
# This file is a symlink into the repo, so edit it there. Machine-specific
# settings go in ~/.config/zsh/local.zsh, which isn't tracked.

export ZSH_CFG_DIR="$HOME/.config/zsh"

# Helpers used here and by the plugin list.
has() { (( $+commands[$1] )) }
is-macos() { [[ "$OSTYPE" == darwin* ]] }

# Environment first, so plugins can see PATH, NVM_DIR, etc.
source "$ZSH_CFG_DIR/vars.zsh"

# oh-my-zsh settings; must be set before its library is loaded.
HIST_STAMPS="yyyy-mm-dd"

# Plugins (see ~/.zsh_plugins.txt).
source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
antidote load

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

# Per-machine overrides. Loaded before secrets so it can set DOTFILES_SKIP_SECRETS.
[[ -f "$ZSH_CFG_DIR/local.zsh" ]] && source "$ZSH_CFG_DIR/local.zsh"

source "$ZSH_CFG_DIR/secrets.zsh"

# Don't let a missing optional file above make the shell start with an error code.
true
