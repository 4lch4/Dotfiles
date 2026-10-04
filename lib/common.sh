#!/usr/bin/env bash
# shellcheck disable=SC2034  # Variables here are used by the scripts that source this file.

################################################################################
## Helpers shared by every OS. Sourced by install.sh; not meant to be run.     ##
################################################################################

BLUE_TEXT="\033[1;34m"
YELLOW_TEXT="\033[1;33m"
GREEN_TEXT="\033[1;32m"
RED_TEXT="\033[1;31m"
RESET_TEXT="\033[0m"

info() { echo -e "${BLUE_TEXT}==>${RESET_TEXT} $*"; }
warn() { echo -e "${YELLOW_TEXT}==> $*${RESET_TEXT}" >&2; }
success() { echo -e "${GREEN_TEXT}==> $*${RESET_TEXT}"; }
die() {
  echo -e "${RED_TEXT}==> $*${RESET_TEXT}" >&2
  exit 1
}

has() { command -v "$1" >/dev/null 2>&1; }

CURRENT_USER="${USER:-$(id -un)}"

# Use sudo only when we aren't already root.
SUDO=""
if [[ $EUID -ne 0 ]]; then
  has sudo || die "sudo is required when not running as root."
  SUDO="sudo"
fi

detect_os() {
  if [[ "$OSTYPE" == darwin* ]]; then
    echo macos
  elif [[ -r /etc/os-release ]] && grep -qiE '^(ID|ID_LIKE)=.*ubuntu' /etc/os-release; then
    echo ubuntu
  else
    echo unknown
  fi
}

# Translate `uname -m` into the names used by most release downloads.
detect_arch() {
  case "$(uname -m)" in
    x86_64 | amd64) echo amd64 ;;
    aarch64 | arm64) echo arm64 ;;
    *) die "Unsupported CPU architecture: $(uname -m)" ;;
  esac
}

#region Linking
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Symlink $1 to $2. Anything already at $2 that isn't the right link is moved
# into $BACKUP_DIR first, so nothing is ever silently overwritten.
link_file() {
  local src="$1" dest="$2"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    return 0
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="$BACKUP_DIR/${dest#"$HOME"/}"
    mkdir -p "$(dirname "$backup")"
    mv "$dest" "$backup"
    warn "Backed up existing $dest to $backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "    linked ~/${dest#"$HOME"/}"
}

# Every file under home/ is linked to the same path under $HOME, e.g.
# home/.config/zsh/aliases.zsh -> ~/.config/zsh/aliases.zsh
link_dotfiles() {
  info "Linking config files into $HOME"

  local src rel
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES_DIR/home/"}"
    link_file "$src" "$HOME/$rel"
  done < <(find "$DOTFILES_DIR/home" \( -type f -o -type l \) -print0 | sort -z)
}
#endregion Linking

#region zsh
ANTIDOTE_DIR="${ZDOTDIR:-$HOME}/.antidote"

# Install (or update) the antidote plugin manager, then pre-build the plugin
# bundle so the first shell starts quickly and any plugin errors show up now.
install_antidote() {
  if [[ -d "$ANTIDOTE_DIR/.git" ]]; then
    info "Updating antidote"
    git -C "$ANTIDOTE_DIR" pull --ff-only --quiet
  else
    info "Installing antidote"
    git clone --depth=1 --quiet https://github.com/mattmc3/antidote.git "$ANTIDOTE_DIR"
  fi

  if has zsh; then
    info "Downloading zsh plugins"
    zsh -c "source '$ANTIDOTE_DIR/antidote.zsh' && antidote bundle <'$HOME/.zsh_plugins.txt' >'$HOME/.zsh_plugins.zsh'"
  else
    warn "zsh isn't installed, skipping plugin download."
  fi
}

set_login_shell_to_zsh() {
  local zsh_path current_shell
  zsh_path="$(command -v zsh || true)"
  [[ -n "$zsh_path" ]] || { warn "zsh isn't installed, not changing the login shell."; return 0; }

  if [[ "$OSTYPE" == darwin* ]]; then
    current_shell="$(dscl . -read "/Users/$CURRENT_USER" UserShell | awk '{print $2}')"
  else
    current_shell="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"
  fi

  if [[ "$current_shell" == "$zsh_path" ]]; then
    return 0
  fi

  grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null

  info "Changing login shell for $CURRENT_USER to $zsh_path"
  $SUDO chsh -s "$zsh_path" "$CURRENT_USER"
}
#endregion zsh

# shellcheck source=lib/dev.sh
source "$DOTFILES_DIR/lib/dev.sh"
