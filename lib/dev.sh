#!/usr/bin/env bash

################################################################################
## Dev-profile steps that are identical on Ubuntu and macOS. Sourced by       ##
## lib/common.sh; not meant to be run.                                        ##
################################################################################

NVM_FALLBACK_VERSION="v0.40.3"

# npm packages installed globally into the default (LTS) Node version.
NPM_GLOBAL_PACKAGES=(
  pnpm
  yarn
  typescript
  ts-node
  prettier
)

install_node() {
  export NVM_DIR="$HOME/.nvm"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    local version
    version="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest 2>/dev/null |
      sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' || true)"
    version="${version:-$NVM_FALLBACK_VERSION}"

    info "Installing nvm $version"
    # PROFILE=/dev/null stops the nvm installer from appending to ~/.zshrc,
    # which is a symlink into this repo. .zshrc already sets NVM_DIR.
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" | PROFILE=/dev/null bash >/dev/null
  fi

  # nvm isn't compatible with `set -u`.
  set +u
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"

  info "Installing the latest Node.js LTS"
  nvm install --lts --no-progress >/dev/null
  nvm alias default 'lts/*' >/dev/null

  info "Installing global npm packages: ${NPM_GLOBAL_PACKAGES[*]}"
  npm install --global --silent --no-fund --no-audit "${NPM_GLOBAL_PACKAGES[@]}"
  set -u
}

install_bun() {
  export BUN_INSTALL="$HOME/.bun"

  if [[ -x "$BUN_INSTALL/bin/bun" ]]; then
    return 0
  fi

  info "Installing Bun"
  # The Bun installer appends to the rc file of whatever $SHELL is, and
  # ~/.zshrc is a symlink into this repo. With SHELL=sh it only prints a hint,
  # which we drop. .zshrc already sets BUN_INSTALL and PATH. Its output
  # (mostly a download progress bar) is only shown if it fails.
  local output
  if ! output="$(curl -fsSL https://bun.sh/install | SHELL=sh bash 2>&1)"; then
    echo "$output" >&2
    die "Bun install failed."
  fi
}
