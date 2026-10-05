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

# Go tools installed with `go install`.
GO_TOOLS=(
  github.com/goreleaser/goreleaser/v2@latest
  github.com/google/ko@latest
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

install_go_tools() {
  local go_bin
  go_bin="$(command -v go || true)"
  [[ -n "$go_bin" ]] || go_bin=/usr/local/go/bin/go
  [[ -x "$go_bin" ]] || { warn "Go isn't installed, skipping Go tools."; return 0; }

  export GOPATH="${GOPATH:-$HOME/go}"

  local tool name
  for tool in "${GO_TOOLS[@]}"; do
    # github.com/goreleaser/goreleaser/v2@latest -> goreleaser
    name="${tool%%@*}"
    name="${name%/v[0-9]*}"
    name="${name##*/}"
    if has "$name" || [[ -x "$GOPATH/bin/$name" ]]; then
      continue
    fi
    info "go install $tool"
    "$go_bin" install "$tool"
  done
}
