#!/usr/bin/env bash

################################################################################
## macOS package installation via Homebrew. Sourced by install.sh; not meant  ##
## to be run directly.                                                        ##
################################################################################

# Installed on every Mac (server and dev profiles).
BREW_SERVER_PACKAGES=(
  zsh
  git
  fzf
  zoxide
  eza
  tmux
  jq
  ripgrep
)

# Added on top of the server list for the dev profile.
BREW_DEV_PACKAGES=(
  gh
  go-task
)

ensure_homebrew() {
  if ! has brew; then
    info "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Make brew available for the rest of this script on Apple Silicon/Intel.
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    if [[ -x "$prefix/bin/brew" ]]; then
      eval "$("$prefix/bin/brew" shellenv)"
      break
    fi
  done
}

# Install only the formulae that aren't already present.
brew_install() {
  local missing=() pkg
  for pkg in "$@"; do
    brew list --formula "${pkg##*/}" >/dev/null 2>&1 || missing+=("$pkg")
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0

  info "brew install ${missing[*]}"
  brew install "${missing[@]}"
}

install_server_packages() {
  ensure_homebrew
  info "Installing server packages"
  brew_install "${BREW_SERVER_PACKAGES[@]}"
}

install_dev_packages() {
  info "Installing dev packages"
  brew_install "${BREW_DEV_PACKAGES[@]}"
}
