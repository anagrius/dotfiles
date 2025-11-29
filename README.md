# dotfiles

Thomas Anagrius's dotfiles for Arch Linux.

## Quick Start

```bash
# Install packages
./install.sh

# Install dotfiles with stow
stow bash
```

## Structure

Each directory is a stow package that gets symlinked to `~`:

- `bash/` - Bash configuration
- `nvim/` - Custom neovim plugins (layered on top of Omarchy's LazyVim)
- `keyboard/glove80/` - Glove80 keyboard firmware tools

## Requirements

- Arch Linux
- GNU Stow (`pacman -S stow`)
