# CLAUDE.md - Dotfiles Project Instructions

## CRITICAL SAFETY CONSTRAINTS

### 🚨 NEVER MODIFY $HOME FILES
**ABSOLUTE PROHIBITION**: 決して $HOME 以下のファイル・ディレクトリには変更を加えない

- NO symlink creation in $HOME
- NO file modification in $HOME  
- NO directory creation in $HOME
- NO permission changes in $HOME
- ONLY work within the dotfiles repository directory structure

### Safe Operations Only
- Read files for analysis: ✅ ALLOWED
- List directories for inspection: ✅ ALLOWED
- Work within `/Users/hnagato/Sync/dotfiles/`: ✅ ALLOWED
- Test in `/tmp/`: ✅ ALLOWED (for validation only)
- Modify/create files in $HOME: ❌ FORBIDDEN

## Project Context

This is a GNU Stow migration project for dotfiles management. The goal is to restructure the dotfiles repository to be Stow-compatible without affecting the currently working $HOME configuration.

## Development Workflow

1. **Analysis Phase**: Read and understand current structure
2. **Planning Phase**: Design new Stow package structure  
3. **Implementation Phase**: Reorganize files within dotfiles repo only
4. **Testing Phase**: Use `/tmp/` for validation testing
5. **Documentation Phase**: Update setup instructions

## Current Migration Status

- Phase 1: Public dotfiles Stow migration (IN PROGRESS)
- Working on repository restructuring only
- $HOME modifications are user responsibility after review