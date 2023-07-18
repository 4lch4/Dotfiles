################################################################################
## Author:      Devin W. Leaman (4lch4)                                       ##
## Version:     1.0.0                                                         ##
## Filename:    secrets.sh                                                    ##
## Created On:  07/16/2023 @ 11:08                                            ##
################################################################################
## Description:                                                               ##
##                                                                            ##
##                                                                            ##
## A bash script that adds all the secrets stored in Doppler under my         ##
## laptop-secrets project to the shell environment.                           ##
################################################################################
## Usage:                                                                     ##
##                                                                            ##
## source secrets.sh                                                          ##
################################################################################

COMP_NAME=$(hostname | sed 's/[.-]/_/g' | tr '[:upper:]' '[:lower:]')
PROJECT_NAME="laptop-secrets"
CONFIG_NAME="prime_$COMP_NAME"

# echo "Importing Doppler secrets from project \"$PROJECT_NAME\" and config \"$CONFIG_NAME\""

source <(doppler secrets download --no-file --format env -p $PROJECT_NAME -c "$CONFIG_NAME")
