#!/usr/bin/env bash

################################################################################
## Author:      Devin W. Leaman (4lch4)                                       ##
## Version:     2.0.0                                                         ##
## Filename:    install.sh                                                    ##
################################################################################
## Description:                                                               ##
##                                                                            ##
## The single entry point for installing these dotfiles. It works from a      ##
## local clone or straight from curl: when it isn't running from inside the   ##
## repo, it clones the repo to $DOTFILES_DIR (default ~/.dotfiles) and re-runs ##
## itself from there.                                                         ##
##                                                                            ##
## Safe to run repeatedly: packages that are already present are skipped,     ##
## correct symlinks are left alone and any file it replaces is backed up.     ##
################################################################################
## Usage:                                                                     ##
##                                                                            ##
##   ./install.sh [--profile server|dev] [--links-only] [--no-chsh]           ##
##                                                                            ##
##   curl -fsSL https://raw.githubusercontent.com/4lch4/Dotfiles/main/install.sh \
##     | bash -s -- --profile dev                                             ##
##                                                                            ##
## No --profile is needed on a normal install: Ubuntu picks server or dev by  ##
## whether a graphical session is installed. See resolve below.               ##
################################################################################

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/4lch4/Dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Left empty unless --profile or DOTFILES_PROFILE says otherwise, so the
# profile can be picked from what this machine turns out to be.
PROFILE="${DOTFILES_PROFILE:-}"
LINKS_ONLY=false
CHANGE_SHELL=true

ORIGINAL_ARGS=("$@")

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  -p, --profile <name>  What to install (default: detected, see below)
                          server  zsh, oh-my-zsh, plugins and a few CLI tools
                                  (fzf, zoxide, eza, tmux, jq, ripgrep).
                          dev     everything in server, plus Node (nvm) with
                                  global npm packages, Task and gh.
      --links-only      Only (re)link the config files and set up oh-my-zsh
                        and antidote; don't install any packages.
      --no-chsh         Don't change the login shell to zsh.
  -h, --help            Show this help.

With no --profile, Ubuntu installs the dev profile when a graphical session is
installed and the server profile otherwise. macOS always uses server. Set
DOTFILES_PROFILE, or pass --profile, to override the guess.

Environment:
  DOTFILES_DIR     Where the repo lives/gets cloned (default: ~/.dotfiles)
  DOTFILES_BRANCH  Branch to clone when bootstrapping (default: main)
  DOTFILES_PROFILE Profile to install when --profile isn't given
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p | --profile)
      [[ $# -ge 2 ]] || { echo "--profile needs a value" >&2; exit 1; }
      PROFILE="$2"
      shift 2
      ;;
    --profile=*)
      PROFILE="${1#*=}"
      shift
      ;;
    --links-only)
      LINKS_ONLY=true
      shift
      ;;
    --no-chsh)
      CHANGE_SHELL=false
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$PROFILE" in
  "" | server | dev) ;;
  *)
    echo "Unknown profile '$PROFILE' (expected 'server' or 'dev')" >&2
    exit 1
    ;;
esac

#region Bootstrap
# When piped from curl there's no repo on disk, so clone it and re-run from
# there. `${BASH_SOURCE[0]:-}` is empty when the script is read from stdin.
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -z "$SCRIPT_DIR" || ! -f "$SCRIPT_DIR/lib/common.sh" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "==> git is required, installing it..."
    if command -v apt-get >/dev/null 2>&1; then
      SUDO=""
      [[ $EUID -ne 0 ]] && SUDO="sudo"
      $SUDO apt-get update -qq
      $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git ca-certificates
    else
      echo "Please install git and re-run this script." >&2
      exit 1
    fi
  fi

  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    echo "==> Updating existing clone in $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only
  else
    echo "==> Cloning $DOTFILES_REPO into $DOTFILES_DIR"
    git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi

  exec bash "$DOTFILES_DIR/install.sh" "${ORIGINAL_ARGS[@]+"${ORIGINAL_ARGS[@]}"}"
fi

DOTFILES_DIR="$SCRIPT_DIR"
#endregion Bootstrap

# shellcheck source=lib/common.sh
source "$DOTFILES_DIR/lib/common.sh"

OS="$(detect_os)"

case "$OS" in
  ubuntu)
    # shellcheck source=lib/ubuntu.sh
    source "$DOTFILES_DIR/lib/ubuntu.sh"
    ;;
  macos)
    # shellcheck source=lib/macos.sh
    source "$DOTFILES_DIR/lib/macos.sh"
    ;;
  *)
    die "Unsupported OS. Only Ubuntu and macOS are supported."
    ;;
esac

# Pick a profile when the caller didn't name one. On Ubuntu a graphical
# session means someone works at this machine, so it gets the dev profile;
# a bare box is a server. macOS keeps the old default of server, since
# there's nothing to detect there and I'd rather not change that silently.
if [[ -z "$PROFILE" ]]; then
  if [[ "$OS" == ubuntu ]]; then
    variant="$(detect_variant)"
    if [[ "$variant" == desktop ]]; then
      PROFILE=dev
    else
      PROFILE=server
    fi
    info "No --profile given; this looks like an Ubuntu $variant, using '$PROFILE'."
  else
    PROFILE=server
  fi
fi

info "Installing dotfiles from $DOTFILES_DIR (os: $OS, profile: $PROFILE)"

if [[ "$LINKS_ONLY" == false ]]; then
  install_server_packages

  if [[ "$PROFILE" == dev ]]; then
    install_dev_packages
    # Shared between Ubuntu and macOS, defined in lib/dev.sh.
    install_node
  fi
fi

link_dotfiles
install_oh_my_zsh
install_antidote

if [[ "$CHANGE_SHELL" == true ]]; then
  set_login_shell_to_zsh
fi

success "Done! Start a new shell (or run 'exec zsh') to load everything."
