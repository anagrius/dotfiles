# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for Linux systems that uses GNU Stow to manage symlinks. The repository contains configurations for Zsh, Neovim (LazyVim), Ghostty terminal, Git, and various development tools.

## Installation and Setup Commands

### Initial Setup
```bash
# Install dependencies and set up dotfiles
./install.sh

# Alternative if install script isn't executable
chmod +x install.sh && ./install.sh
```

### Manual Installation Steps
```bash
# Clone repository (if not already cloned)
git clone <repo-url> ~/code/dotfiles
cd ~/code/dotfiles

# Use GNU Stow to create symlinks
stow --verbose --target="$HOME" .

# Set Zsh as default shell
chsh -s "$(which zsh)"
```

## Architecture and Structure

### Core Components
- **GNU Stow Management**: Uses Stow to symlink dotfiles from repository to home directory
- **Zsh Configuration**: Oh-My-Zsh based setup with custom configurations
- **Neovim Setup**: LazyVim starter template with custom plugins and configurations
- **Ghostty Terminal**: Custom terminal configuration with split pane shortcuts
- **Git Security**: Git hooks with gitleaks integration for secret detection

### Key Directories
- `.config/nvim/`: Complete LazyVim Neovim configuration
- `.config/ghostty/`: Ghostty terminal configuration with split pane shortcuts
- `.config/zsh/`: Zsh configuration files (symlinked when stowed)
- `git-hooks/`: Repository-specific git hooks for security scanning
- `.stow-local-ignore`: Files/directories to exclude from stowing

### Dependencies
Required packages that must be installed before setup:
- ghostty, snap, wget, stow, git, nvim, code, gh, zsh, go, fdfind

### Security Features
- **Pre-push Hook**: Automatically runs gitleaks scan before pushing to prevent secret leakage
- **Gitleaks Integration**: Automatically installs and configures gitleaks for secret detection
- **Local Git Hooks**: Repository-specific hooks configuration (not global)

### Neovim Configuration
- Based on LazyVim starter template
- Custom plugins in `lua/plugins/`
- Configuration split across `lua/config/` directory
- Uses lazy.nvim for plugin management

### Ghostty Terminal Configuration
- Split pane shortcuts: `Ctrl+X` then `2` (horizontal), `Ctrl+X` then `3` (vertical)
- Navigation: `Super+Arrow` or `Ctrl+Shift+Arrow` keys
- Resize splits: `Ctrl+Super+Arrow` keys
- Close pane: `Ctrl+X` then `0`

### Installation Flow
1. Checks for required dependencies
2. Installs Oh-My-Zsh if not present
3. Installs gitleaks via Go if not present
4. Configures git hooks for this repository only
5. Creates necessary directories
6. Uses Stow to symlink configurations
7. Sets Zsh as default shell

## Important Notes
- The repository sets git hooks path locally (not globally) to avoid affecting other repositories
- Zsh configuration expects ZDOTDIR to be set to `$HOME/.config/zsh`
- Installation script has dependency checking and will fail if required packages are missing
- Uses colored output for installation feedback and status reporting