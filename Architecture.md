# Architecture

This file will provide a generic overview of the architecture of this repository.

## File/Folder Structure

First up, let's take a look at the file/folder structure of this repository and what each file/folder is used for.

```bash
.
├── .github/
│   └── workflows/
│       └── scans.yml
├── scripts/
│   ├── install/
│   │   ├── macos.sh
│   │   └── ubuntu.sh
│   └── shared/
│       ├── aliases.sh
│       ├── functions.sh
│       ├── secrets.sh
│       ├── vars.sh
│       └── .zshrc
├── .gitignore
├── install.sh
├── README.md
└── Taskfile.yml
```

### `.github/`

This folder is a folder unique to GitHub as it contains files that are used by GitHub to perform various actions. In this case, we have the `workflows` directory, which contains the configuration for GitHub Actions. At the moment, there is only one workflow defined, [`scans.yml`](./.github/workflows/scans.yml), which performs some basic security scans on the repository on a regular basis.

### `scripts/`

This folder contains all of the scripts that are used to install, configure, or otherwise customize my environment. These scripts are then further divided into the `install` and `shared` directories.

#### `install/`

This directory contains the scripts that are called by the root `install.sh` script based on which OS you're using. For example, if you're using macOS, the `install.sh` script will call the `macos.sh` script, which will then install the necessary software and apply the necessary customizations for macOS.

#### `shared/`

And now, the last directory related to scripts. This directory contains the scripts that are used no matter which OS you're using. For example, the `aliases.sh` script contains all of the aliases that I use in my terminal environment, while the `functions.sh` script contains all of the functions that I use in my terminal environment.

### `.gitignore`

I don't even feel like I need to mention this but I also don't like skipping items in a list so here we are 😅

### `install.sh`

This file is the main entry point for installing and configuring my terminal environment. It is responsible for determining which OS you're using and then calling the appropriate script from the `scripts/install` directory, which will handle the remainder of the installation process.

### `Taskfile.yml`

This file is used by [Taskfile][0] to define the various tasks that can be run against this repository. For example, you can run the `pretty` task to run `prettier` against all of the files in this repository and have them formatted according to the rules defined in the `.prettierrc` file.

[0]: https://taskfile.dev
