# Architecture

A quick tour of how this repo is put together.

```text
.
├── install.sh              # The only entry point. Parses options, bootstraps, runs everything below.
├── lib/
│   ├── common.sh           # Logging, OS detection, symlinking, oh-my-zsh, antidote, login shell.
│   ├── dev.sh              # Dev-profile steps shared by every OS (nvm/Node, Go tools).
│   ├── ubuntu.sh           # apt packages and Ubuntu-specific dev tooling.
│   └── macos.sh            # Homebrew packages.
├── home/                   # Mirrors $HOME: every file here is symlinked to the same path there.
│   ├── .zshrc              # Also holds the oh-my-zsh theme and plugins=(...) list.
│   ├── .zsh_plugins.txt    # antidote plugins loaded before oh-my-zsh (zsh-completions, autosuggestions).
│   ├── .zsh_plugins.post.txt  # antidote plugins loaded last (zsh-syntax-highlighting).
│   └── .config/zsh/
│       ├── vars.zsh        # Environment variables and PATH. Loaded before plugins.
│       ├── functions.zsh   # Shell functions.
│       ├── aliases.zsh     # Aliases.
│       └── secrets.zsh     # Loads Doppler secrets when the CLI is available.
├── sandbox/                # Scratch space for experiments; not used by the installer.
└── .github/workflows/
    ├── install.yml         # ShellCheck + install tests on clean Ubuntu 22.04/24.04 containers.
    └── scans.yml           # Daily Gitleaks scan.
```

## How `install.sh` runs

1. **Bootstrap.** If the script isn't running from inside a clone (e.g. it was piped from `curl`), it installs git if needed, clones the repo to `$DOTFILES_DIR` (or fast-forwards an existing clone), and re-executes itself from there with the same arguments.
2. **Packages.** It sources `lib/ubuntu.sh` or `lib/macos.sh` depending on the OS. Each defines `install_server_packages` and `install_dev_packages`. The dev profile then runs the shared steps from `lib/dev.sh`. Every step checks first and skips what's already installed. `--links-only` skips this stage entirely.
3. **Links.** Every file under `home/` is symlinked into `$HOME` at the same relative path. Existing files are backed up to `~/.dotfiles-backup/<timestamp>/` rather than overwritten.
4. **oh-my-zsh.** If `~/.oh-my-zsh` doesn't exist, the official installer runs unattended (it keeps the linked `~/.zshrc` and doesn't change the shell). An existing git install is fast-forwarded instead.
5. **antidote.** antidote is cloned (or updated) into `~/.antidote` and both plugin bundles are pre-built, so the first shell starts quickly and plugin problems surface during install.
6. **Login shell.** The user's login shell is switched to zsh unless `--no-chsh` is passed.

## How the shell loads

`~/.zshrc` loads things in this order: `vars.zsh` → oh-my-zsh settings (`ZSH`, theme, `plugins=(...)`) → antidote `.zsh_plugins.txt` → `oh-my-zsh.sh` (runs compinit) → fzf/zoxide/Doppler integrations → `functions.zsh` → `aliases.zsh` → `~/.config/zsh/local.zsh` (untracked, optional) → `secrets.zsh` → antidote `.zsh_plugins.post.txt`.

zsh-completions has to be on `fpath` before oh-my-zsh runs compinit, and zsh-syntax-highlighting has to come after everything that defines widgets, which is why antidote loads in two parts around oh-my-zsh.

Anything that depends on an optional tool is guarded with `has <cmd>`, so the same config starts cleanly on a bare server and on a fully loaded dev machine.

## Adding things

- **A package for every machine:** add it to `APT_SERVER_PACKAGES` in `lib/ubuntu.sh` (and `BREW_SERVER_PACKAGES` in `lib/macos.sh`).
- **A dev-only package:** `APT_DEV_PACKAGES` / `BREW_DEV_PACKAGES`, or an `install_<tool>` function called from `install_dev_packages` if it needs its own repo or download.
- **An oh-my-zsh plugin:** add it to `plugins=(...)` in `home/.zshrc`.
- **A third-party zsh plugin:** add a line to `home/.zsh_plugins.txt` (or `.zsh_plugins.post.txt` if it must load last); antidote picks it up in the next shell.
- **A new config file:** drop it under `home/` at the path it should have in `$HOME` and re-run `install.sh --links-only`.
