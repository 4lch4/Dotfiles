# Dotfiles

My shell configuration (zsh + [oh-my-zsh][omz] + a few plugins via [antidote][antidote]) and an installer that sets it up on Ubuntu servers, Ubuntu dev machines and macOS.

## Install

One command, on a fresh machine or an existing one. Run it as your normal user (it uses `sudo` when it needs to):

```bash
curl -fsSL https://raw.githubusercontent.com/4lch4/Dotfiles/main/install.sh | bash
```

No arguments needed. On Ubuntu the script works out which profile you want: a machine with a graphical session installed gets `dev`, a bare one gets `server`. It says which it picked and why, so override it with `--profile` if the guess is wrong.

The script clones this repo to `~/.dotfiles` and re-runs itself from there. If you already have a clone, run it directly instead:

```bash
git clone git@github.com:4lch4/Dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

It's safe to run again at any time, e.g. to pick up changes after a `git pull`: installed packages are skipped, correct symlinks are left alone, and any existing file it would replace is moved to `~/.dotfiles-backup/<timestamp>/` first.

### Options

| Option                     | Description                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------- |
| `--profile server` / `dev` | What to install. Skipped by default: Ubuntu detects `dev` on a desktop and `server` on a bare box, macOS uses `server`. |
| `--links-only`             | Only link the config files and set up oh-my-zsh/antidote; no packages.                  |
| `--no-chsh`                | Don't change the login shell to zsh.                                                    |
| `DOTFILES_DIR=...`         | Where the repo is cloned when bootstrapping (default `~/.dotfiles`).                    |
| `DOTFILES_BRANCH=...`      | Branch to clone when bootstrapping (default `main`), handy for testing PRs.             |
| `DOTFILES_PROFILE=...`     | Same as `--profile`, for when you'd rather not pass a flag.                              |

### What each profile installs

|                  | `server`                                                        | `dev` (adds)                                                                           |
| ---------------- | --------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| **Ubuntu** (apt) | zsh, git, curl, fzf, zoxide, eza, tmux, jq, ripgrep             | build-essential, gh, Task                                                              |
| **macOS** (brew) | zsh, git, fzf, zoxide, eza, tmux, jq, ripgrep                   | gh, go-task                                                                            |
| **Both**         | oh-my-zsh, antidote + plugins, config symlinks, zsh login shell | nvm + latest Node LTS, global npm packages (pnpm, yarn, typescript, ts-node, prettier) |

Ubuntu 24.04 and 26.04 are tested in CI. 22.04 should still work but isn't tested. macOS support is kept but not currently tested.

## Customizing a single machine

Anything that should only apply to one machine goes in `~/.config/zsh/local.zsh`, which isn't tracked. It's loaded after my aliases and functions, so it can override them or add machine-specific environment variables and PATH entries. For example:

```zsh
export EDITOR=vim
path+=("$HOME/some-tool/bin")
```

## Layout

See [Architecture.md](./Architecture.md).

[antidote]: https://antidote.sh
[omz]: https://ohmyz.sh
