#!/bin/bash

################################################################################
## Author:      Devin W. Leaman (4lch4)                                       ##
## Version:     1.0.0                                                         ##
## Filename:    macos-install.sh                                              ##
## Created On:  07/16/2023 @ 12:29-0500                                       ##
################################################################################
## Description:                                                               ##
##                                                                            ##
##                                                                            ##
## This script will install the various software/tools I use and apply my     ##
## various customizations.                                                    ##
################################################################################
## Usage:                                                                     ##
##                                                                            ##
## ./macos.sh                                                                 ##
################################################################################

# NOTE: It's important to note that this script assumes that you have already
# installed and configured ZSH, Oh My ZSH, and Antigen. If you have not done
# this, please do so with the zsh-install.sh script before running this one.

YELLOW_TEXT="\033[1;33m"
GREEN_TEXT="\033[1;32m"
RESET_TEXT="\033[0m"

if [[ $(which brew) ]]; then
  echo -e "${GREEN_TEXT}Homebrew is installed, skipping installation...${RESET_TEXT}}"
else
  echo "${YELLOW_TEXT}Homebrew is not installed, installing now...${RESET_TEXT}"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#region Tools & Software Setup

# An array of all the software I want to install via Homebrew.
BREW_CORE_LIST=(
  go
  ko
)

for package in ${BREW_CORE_LIST[@]}; do
  if [[ $(brew list --formula | grep $package) ]]; then
    echo -e "${GREEN_TEXT}$package is installed, skipping installation...${RESET_TEXT}"
  else
    echo "${YELLOW_TEXT}$package is not installed, installing now...${RESET_TEXT}"

    brew install $package
  fi
done

# An array of all the software I want to install via Homebrew Casks/Taps.
BREW_TAP_LIST=(
  goreleaser/tap/goreleaser
  go-task/tap/go-task
)

for package in ${BREW_TAP_LIST[@]}; do
  if [[ $(brew list --formula | grep $package) ]]; then
    echo -e "${GREEN_TEXT}$package is installed, skipping installation...${RESET_TEXT}"
  else
    echo "${YELLOW_TEXT}$package is not installed, installing now...${RESET_TEXT}"

    brew install $package
  fi
done

#region Go Setup
# Install the latest version of go.
brew install go

# Install the latest version of GoReleaser.
brew install goreleaser/tap/goreleaser

# Install the latest version of Ko.
brew install ko
#endregion Go Setup

#region Node Setup
# Get the latest version of nvm from GitHub.
LATEST_NVM_VERSION=$(curl --silent "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Download and run the nvm install script.
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$LATEST_NVM_VERSION/install.sh" | bash

# An array of all the npm packages I want to install globally.
NPM_GLOBAL_PACKAGES=(
  pnpm
  yarn
  typescript
  ts-node
  prettier
  wrangler
)

# Install and configure Node.js v20.
nvm install v20
nvm use v20
npm install -g ${NPM_GLOBAL_PACKAGES[@]}

# Install and configure Node.js v18.
nvm install v18
nvm use v18
npm install -g ${NPM_GLOBAL_PACKAGES[@]}

# Install and configure Node.js v16.
nvm install v16
nvm use v16
npm install -g ${NPM_GLOBAL_PACKAGES[@]}
#endregion Node Setup

# Install Taskfile CLI.
brew install go-task/tap/go-task

# Run the setup task in the Taskfile.
task setup

#endregion Tools & Software Setup

