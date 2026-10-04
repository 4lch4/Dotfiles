################################################################################
## Author:      Devin W. Leaman (4lch4)                                       ##
## Version:     2.0.0                                                         ##
## Filename:    vars.zsh                                                      ##
## Created On:  07/16/2023 @ 11:05                                            ##
################################################################################
## Description:                                                               ##
##                                                                            ##
## Exports environment variables and builds up the PATH. Sourced early in     ##
## ~/.zshrc so plugins can see these values.                                  ##
################################################################################

#region Directory/Path Variables
CONFIG_DIR="$HOME/.config"
DEVELOPMENT_DIR="$HOME/Development"

export AILCHA_HOME="$DEVELOPMENT_DIR/alcha/Projects/AIlcha"
export ALCHA_SANDBOX="$DEVELOPMENT_DIR/alcha/Sandbox"
export ALCHA_LEARNING="$DEVELOPMENT_DIR/alcha/Learning"
#endregion Directory/Path Variables

# Loaded by the oh-my-zsh nvm plugin.
export NVM_DIR="$HOME/.nvm"

export GOPATH="$HOME/go"

if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi

# Keep PATH entries unique, then add mine. Entries that don't exist are skipped.
typeset -U path
for dir in \
  "$PNPM_HOME" \
  "$HOME/.local/bin"; do
  [[ -d "$dir" ]] && path=("$dir" $path)
done
for dir in \
  /usr/local/go/bin \
  "$GOPATH/bin" \
  "$HOME/sw/bin"; do
  [[ -d "$dir" ]] && path+=("$dir")
done
unset dir
