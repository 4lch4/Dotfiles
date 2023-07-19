sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_DIR="~/.config/zsh"

mkdir -p ${{zsh_dir}}

curl -L git.io/antigen > "$ZSH_DIR/antigen.zsh"















{{zsh_dir}}

#!/bin/bash

# Install zsh
sudo apt install -y zsh curl git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_DIR="~/.config/zsh"

#mkdir -p ${{zsh_dir}}

curl -L git.io/antigen > "$ZSH_DIR/antigen.zsh"


echo ${{zsh_dir}}


LATEST_NVM_VERSION=$(curl --silent "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

