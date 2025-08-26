# GNU Stow Package Structure Design

## Analysis of Current setup.rb Behavior

### Root Dotfiles (symlinked to $HOME)
- `.zshrc`, `.zshenv`, `.tigrc`, `.inputrc`, `.editorconfig`
- Skips: `.git*`, `.config`

### .config Files (symlinked to $HOME/.config/)  
- All directories: `1Password`, `bat`, `fish`, `ghostty`, `git`, `karabiner`, `lazygit`, `mise`, `tmux`
- Special handling: `fish` (individual file linking), `nvim` (skipped - submodule)
- `starship.toml` (individual file)

### Special Cases
- **fish**: Individual files linked, functions directory handled separately
- **nvim**: Submodule, skipped by setup.rb  
- **.ssh**: Not in current repo, handled by private repo

## Proposed Stow Package Structure

```
dotfiles/
├── shell/                 # Shell environment
│   ├── .zshrc
│   ├── .zshenv
│   ├── .tigrc
│   ├── .inputrc
│   └── .editorconfig
├── terminal/              # Terminal & prompt
│   └── .config/
│       ├── ghostty/
│       ├── tmux/
│       └── starship.toml
├── dev-tools/             # Development tools
│   └── .config/
│       ├── git/
│       ├── lazygit/
│       ├── bat/
│       └── mise/
├── system/               # System utilities
│   └── .config/
│       ├── karabiner/
│       └── 1Password/
├── fish/                 # Fish shell (special handling)
│   └── .config/
│       └── fish/
├── editors/              # Editors (submodules)
│   └── .config/
│       └── nvim/
├── bin/                  # Utility scripts
├── .stow-local-ignore   # Stow ignore patterns
├── PLAN.md              # (ignore)
├── TODO.md              # (ignore)
├── STOW_DESIGN.md       # (ignore)
└── README.md            # (ignore)
```

## Package Rationale

### Logical Grouping
- **shell**: Core shell environment files
- **terminal**: Terminal emulator and prompt configurations  
- **dev-tools**: Development and version control tools
- **system**: System-level utilities and services
- **fish**: Separate due to special file handling requirements
- **editors**: Editor configurations with submodule handling

### Stow Compatibility
- Each package creates proper directory structure
- Mimics final $HOME layout structure
- Handles special cases (fish, nvim) appropriately

## Migration Strategy

1. Create package directories within dotfiles repo
2. Move files to appropriate package locations
3. Handle nvim submodule relocation
4. Create .stow-local-ignore for documentation files
5. Test with `stow --simulate` in /tmp