# Phase 1: Public dotfiles Stow Migration TODO

## Prerequisites & Setup
- [ ] Install GNU Stow
- [ ] Create backup of current symlinks
- [ ] Analyze existing setup.rb symlink creation

## Structure Design & Planning  
- [ ] Design Stow package structure
- [ ] Create .stow-local-ignore file

## Package Creation & Migration
- [ ] Create shell package directory structure  
- [ ] Move shell dotfiles to shell package
- [ ] Create system package for .config files
- [ ] Move .config files to appropriate packages
- [ ] Handle nvim submodule special case

## Testing & Validation
- [ ] Test Stow setup in /tmp
- [ ] Remove old symlinks created by setup.rb
- [ ] Apply Stow configuration to HOME
- [ ] Verify all symlinks are working

## Documentation
- [ ] Update README with new setup instructions

## Package Structure Plan

```
dotfiles/
├── shell/
│   ├── .zshrc
│   ├── .zshenv  
│   ├── .tigrc
│   ├── .inputrc
│   └── .editorconfig
├── terminal/
│   └── .config/
│       ├── ghostty/
│       ├── tmux/
│       └── starship.toml
├── dev-tools/
│   └── .config/
│       ├── git/
│       ├── lazygit/
│       ├── bat/
│       └── mise/
├── system/
│   └── .config/
│       ├── karabiner/
│       └── 1Password/
├── editors/
│   └── .config/
│       └── nvim/ (submodule)
├── fish/
│   └── .config/
│       └── fish/
├── bin/
└── .stow-local-ignore
```