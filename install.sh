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
##     | sh -s -- --profile dev                                              ##
##                                                                            ##
## Plain `sh` works as well as `bash`; see the hand-off below.                 ##
################################################################################

#region Hand-off
# The first section of this file is POSIX sh. Everything after it is bash,
# which rules out `sh` on Debian/Ubuntu (dash has no arrays, [[ ]] or
# pipefail) and a `curl … | sh` pipeline ignores this file's shebang
# entirely. So under anything that isn't bash, get the repo onto disk and
# `exec` bash against the clone.
#
# Note this deliberately does NOT stage a copy of itself to run under bash:
# a script cannot reliably read its own piped stdin, because the shell has
# already buffered the body by the time any of it runs. Handing off to the
# clone sidesteps that entirely -- and the clone is what the script wanted
# anyway when it was piped in.
set -eu

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/4lch4/Dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Running from a checkout? Then use it as-is and skip the clone, which is
# what makes testing a branch locally work. `$0` is only a path when the
# script was named on the command line; piped in, it's just the shell's name.
__dotfiles_dir=""
if [ -f "${0:-}" ]; then
  __dotfiles_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
fi

if [ -n "$__dotfiles_dir" ] && [ -f "$__dotfiles_dir/lib/common.sh" ]; then
  DOTFILES_DIR="$__dotfiles_dir"
else
  if ! command -v git >/dev/null 2>&1; then
    printf '%s\n' "==> git is required, installing it..." >&2
    if command -v apt-get >/dev/null 2>&1; then
      __dotfiles_sudo=""
      [ "$(id -u)" -ne 0 ] && __dotfiles_sudo="sudo"
      $__dotfiles_sudo apt-get update -qq
      $__dotfiles_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git ca-certificates
    else
      printf '%s\n' "Please install git and re-run this script." >&2
      exit 1
    fi
  fi

  if [ -d "$DOTFILES_DIR/.git" ]; then
    printf '%s\n' "==> Updating existing clone in $DOTFILES_DIR" >&2
    git -C "$DOTFILES_DIR" pull --ff-only
  else
    printf '%s\n' "==> Cloning $DOTFILES_REPO into $DOTFILES_DIR" >&2
    git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
fi

# Under bash (including `curl … | bash` and `./install.sh`) there is nothing
# to hand off to, so fall through to the section below with the repo located.
if [ -z "${BASH_VERSION:-}" ]; then
  if ! command -v bash >/dev/null 2>&1; then
    printf '%s\n' "install.sh needs bash. On Debian/Ubuntu: apt-get install -y bash" >&2
    exit 1
  fi
  export DOTFILES_REPO DOTFILES_BRANCH DOTFILES_DIR
  exec bash "$DOTFILES_DIR/install.sh" "$@"
fi
#endregion Hand-off

set -euo pipefail

PROFILE="${DOTFILES_PROFILE:-server}"
LINKS_ONLY=false
CHANGE_SHELL=true


usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  -p, --profile <name>  What to install (default: server, or $DOTFILES_PROFILE)
                          server  zsh, oh-my-zsh, plugins and a few CLI tools
                                  (fzf, zoxide, eza, tmux, jq, ripgrep).
                          dev     everything in server, plus Node (nvm) with
                                  global npm packages, Task and gh.
      --links-only      Only (re)link the config files and set up oh-my-zsh
                        and antidote; don't install any packages.
      --no-chsh         Don't change the login shell to zsh.
  -h, --help            Show this help.

Environment:
  DOTFILES_DIR     Where the repo lives/gets cloned (default: ~/.dotfiles)
  DOTFILES_BRANCH  Branch to clone when bootstrapping (default: main)
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
  server | dev) ;;
  *)
    echo "Unknown profile '$PROFILE' (expected 'server' or 'dev')" >&2
    exit 1
    ;;
esac

# The hand-off section above has already put us in a checkout by the time we
# get here: either this file is in one, or the repo was cloned or pulled.

# shellcheck source=lib/common.sh
source "$DOTFILES_DIR/lib/common.sh"

OS="$(detect_os)"
info "Installing dotfiles from $DOTFILES_DIR (os: $OS, profile: $PROFILE)"

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
