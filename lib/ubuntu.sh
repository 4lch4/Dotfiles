#!/usr/bin/env bash

################################################################################
## Ubuntu package installation. Sourced by install.sh; not meant to be run.   ##
## Tested on Ubuntu 24.04 and 26.04 (22.04 should work but is untested).     ##
################################################################################

# Installed on every Ubuntu machine (server and dev).
APT_SERVER_PACKAGES=(
  zsh
  git
  curl
  ca-certificates
  gnupg
  unzip
  fzf
  zoxide
  tmux
  jq
  ripgrep
)

# Added on top of the server list for the dev profile.
APT_DEV_PACKAGES=(
  build-essential
)

APT_UPDATED=false

apt_update() {
  if [[ "$APT_UPDATED" == false ]]; then
    $SUDO apt-get update -qq
    APT_UPDATED=true
  fi
}

# Install only the packages that aren't already present.
apt_install() {
  local missing=() pkg
  for pkg in "$@"; do
    dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed" || missing+=("$pkg")
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0

  info "apt install ${missing[*]}"
  apt_update
  # Keep any locally modified config files instead of stopping to ask.
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold \
    "${missing[@]}" >/dev/null
}

apt_has_candidate() {
  apt_update
  [[ -n "$(apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ && $2 != "(none)" {print $2}')" ]]
}

# eza is in the 24.04 archive but not in 22.04, so fall back to the release
# binary from GitHub there.
install_eza() {
  has eza && return 0

  if apt_has_candidate eza; then
    apt_install eza
    return 0
  fi

  local arch tmp
  case "$(detect_arch)" in
    amd64) arch=x86_64 ;;
    arm64) arch=aarch64 ;;
  esac

  info "Installing eza from GitHub releases"
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-unknown-linux-gnu.tar.gz" |
    tar -xz -C "$tmp"
  $SUDO install -m 0755 "$tmp/eza" /usr/local/bin/eza
  rm -rf "$tmp"
}

install_server_packages() {
  info "Installing server packages"
  apt_install "${APT_SERVER_PACKAGES[@]}"
  install_eza
}

#region Dev
install_gh() {
  has gh && return 0

  info "Installing GitHub CLI"
  $SUDO mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    $SUDO tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  $SUDO chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  APT_UPDATED=false
  apt_install gh
}

install_doppler() {
  has doppler && return 0

  info "Installing Doppler CLI"
  curl -fsSL --retry 3 --tlsv1.2 --proto "=https" https://cli.doppler.com/install.sh | $SUDO sh >/dev/null
}

# Ubuntu's golang package lags well behind, so use the official tarball.
install_go() {
  local latest current=""
  latest="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)"
  [[ -n "$latest" ]] || die "Couldn't determine the latest Go version."

  if [[ -x /usr/local/go/bin/go ]]; then
    current="$(/usr/local/go/bin/go env GOVERSION)"
  fi
  [[ "$current" == "$latest" ]] && return 0

  info "Installing Go $latest (was: ${current:-not installed})"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://go.dev/dl/${latest}.linux-$(detect_arch).tar.gz" -o "$tmp/go.tar.gz"
  $SUDO rm -rf /usr/local/go
  $SUDO tar -C /usr/local -xzf "$tmp/go.tar.gz"
  rm -rf "$tmp"
}

install_task() {
  has task && return 0

  info "Installing Task"
  mkdir -p "$HOME/.local/bin"
  sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -b "$HOME/.local/bin" >/dev/null
}

install_dev_packages() {
  info "Installing dev packages"
  apt_install "${APT_DEV_PACKAGES[@]}"
  install_gh
  install_doppler
  install_go
  install_task
}
#endregion Dev
