# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Thomas Anagrius's dotfiles for Arch Linux, managed with GNU Stow. Each top-level directory represents a "package" that can be symlinked to the home directory using `stow <package>`.

## Repository Structure

- `bash/` - Bash configuration, sources Omarchy defaults from `~/.local/share/omarchy/default/bash/rc`
- `nvim/` - Custom neovim plugins, symlinked into `~/.config/nvim/lua/plugins/` (Omarchy manages the base LazyVim config)
- `keyboard/glove80/` - Glove80 split keyboard keymap and firmware flashing tools

## Commands

### Stow Packages

```bash
stow bash      # Install package (creates symlinks in ~)
stow -D bash   # Remove package
stow -R bash   # Restow (after adding new files)
```

## Version Control

This repo uses jj (Jujutsu) colocated with git. Always use the `git-jj` skill for version control operations.
