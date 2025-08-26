# dotfiles

GNU Stow managed dotfiles configuration.

## Prerequisites

```shell
# Install GNU Stow
brew install stow
```

## Setup

```shell
git clone --recursive git@github.com:hnagato/dotfiles.git
cd dotfiles

# Install all packages
stow shell terminal dev-tools system fish editors

# Or install individual packages
stow shell      # .zshrc, .zshenv, .tigrc, .inputrc, .editorconfig  
stow terminal   # ghostty, tmux, starship
stow dev-tools  # git, lazygit, bat, mise
stow system     # karabiner, 1Password
stow fish       # fish shell configuration
stow editors    # nvim configuration
```

## Package Structure

- **shell**: Core shell environment files
- **terminal**: Terminal emulator and prompt configurations
- **dev-tools**: Development and version control tools  
- **system**: System-level utilities and services
- **fish**: Fish shell configuration (special handling)
- **editors**: Editor configurations with submodules

## Legacy Setup

The old Ruby-based setup script is available at `bin/setup.rb` but is deprecated in favor of GNU Stow.
