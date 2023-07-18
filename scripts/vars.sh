################################################################################
## Author:      Devin W. Leaman (4lch40)                                      ##
## Version:     1.0.0                                                         ##
## Filename:    vars.sh                                                       ##
## Created On:  07/16/2023 @ 11:05                                            ##
################################################################################
## Description:                                                               ##
##                                                                            ##
##                                                                            ##
## A bash script that exports variables and/or modifies the PATH by adding to ##
## it.                                                                        ##
################################################################################
## Usage:                                                                     ##
##                                                                            ##
## source ./vars.sh                                                           ##
################################################################################

export AILCHA_HOME="~/Development/alcha/Projects/AIlcha"
export ALCHA_SANDBOX="~/Development/alcha/Sandbox"
export ALCHA_LEARNING="~/Development/alcha/Learning"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GOPATH="$HOME/go"

# Add ~/sw/bin to path
export PATH="$PATH:$HOME/sw/bin"

# Add GOPATH/bin to path
export PATH="$PATH:$GOPATH/bin"

#region Directory/Path Variables
CONFIG_DIR="$HOME/.config"
DEVELOPMENT_DIR="$HOME/Development"
#endregion Directory/Path Variables
