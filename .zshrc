export ZSH="$HOME/.oh-my-zsh"
export ZSH_CFG_DIR="$HOME/.config/zsh"

source $ZSH_CFG_DIR/antigen.zsh

HIST_STAMPS="yyyy-mm-dd"

antigen use oh-my-zsh

antigen theme steeef

antigen bundle git
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle docker
antigen bundle docker-compose
antigen bundle doctl
antigen bundle dotenv
antigen bundle colorize
antigen bundle common-aliases
antigen bundle fzf
antigen bundle gh
antigen bundle git
antigen bundle httpie
antigen bundle kubectl
antigen bundle nvm
antigen bundle npm
antigen bundle rust
antigen bundle rsync
antigen bundle sudo
antigen bundle terraform
antigen bundle tmux
antigen bundle urltools
antigen bundle vscode
antigen bundle brew
antigen bundle extract

antigen apply

# Add doppler autocomplete.
source <(doppler completion 2> /dev/null)

# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"
autoload -U compinit; compinit

# Apply my customizations after everything to ensure they are not overwritten.
source $ZSH_CFG_DIR/functions.sh
source $ZSH_CFG_DIR/aliases.sh
source $ZSH_CFG_DIR/vars.sh
source $ZSH_CFG_DIR/secrets.sh

