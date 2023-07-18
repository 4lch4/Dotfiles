# Terminal Customization

This repository is home to a collection of configuration files, scripts, etc., for customizing my
terminal environment.

## One-Line Installation

If you're feeling brave (or lazy), you can run the following one-liner to install and apply my customizations and the necessary pre-requisites:

```bash
curl -fsSL https://raw.githubusercontent.com/4lch4/Term-Time/main/install.sh | bash
```

## Pre-requisites

In order for the following installation steps to work properly, you'll need to have the following software installed:

| Name          | Description                                   |
| ------------- | --------------------------------------------- |
| [Homebrew][0] | Used to install the [Taskfile][1] software.   |
| [Taskfile][1] | A modern replacement for [Make][2]/Makefiles. |

## Applying Customizations

Once you have the pre-requisites installed, you can run the following commands to apply my customizations:

```bash
# Clone this repository to your local machine.
git clone git@github.com:4lch4/Term-Time.git

# Change into the cloned repository.
cd Term-Time

# Run the setup task to apply the customizations.
task setup
```

[0]: https://brew.sh
[1]: https://taskfile.dev
[2]: https://www.gnu.org/software/make
