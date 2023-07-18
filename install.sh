#!/bin/bash

################################################################################
## Author:      Devin W. Leaman (4lch4)                                       ##
## Version:     1.0.0                                                         ##
## Filename:    install.sh                                                    ##
## Created On:  07/16/2023 @ 12:17                                            ##
################################################################################
## Description:                                                               ##
##                                                                            ##
##                                                                            ##
## A script that will install the pre-requisites necessary to apply my shell  ##
## customizations to a new MacOS or Linux system.                             ##
################################################################################
## Usage:                                                                     ##
##                                                                            ##
## ./install.sh                                                               ##
################################################################################

YELLOW_TEXT="\033[1;33m"
GREEN_TEXT="\033[1;32m"
RESET_TEXT="\033[0m"

# Determine if the current OS is MacOS or Linux and set the OS variable accordingly.
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo -e "${GREEN_TEXT}Detected OS is macOS, running macos-install.sh...${RESET_TEXT}"

  /bin/bash ./install/macos.sh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo -e "${GREEN_TEXT}Detected OS is Linux, running ./install/linux-install.sh...${RESET_TEXT}"

  /bin/bash ./install/macos.sh
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# if [[ "$OS" == "macos" && $(which brew) ]]; then
#   echo "Both OS is macOS and Homebrew is installed, skipping installation.."
# elif [[ "$OS" == "macos" ]]; then
#   echo "OS is macOS but Homebrew is not installed, installing now..."

#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi


