# Dotfiles

This repository contains my personal dotfiles for Linux systems. It uses GNU Stow to manage symlinks between this repository and the appropriate locations in the home directory.

## What's Included

- Zsh configuration with Oh-My-Zsh
- Various aliases and custom configurations
- Git configuration
- Editor configurations

## Requirements

The following dependencies are required:

- ghostty
- snap
- wget
- stow
- git
- nvim
- code (Visual Studio Code)
- gh (GitHub CLI)
- zsh

## Installation

1. Clone this repository to your home directory:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/code/dotfiles
```

2. Run the installation script:

```bash
cd ~/code/dotfiles
chmod +x install.sh
./install.sh
```

The script will:

- Check for required dependencies
- Install Oh-My-Zsh if it's not already installed
- Set up Zsh as your default shell
- Use GNU Stow to create symlinks from this repository to your home directory

## Structure

- `.config/zsh/.zshrc`: Main Zsh configuration file
- `.config/zsh/custom/`: Directory for custom Oh-My-Zsh themes and plugins
- `.zshenv`: Points to the Zsh configuration directory

## Customization

To customize your setup:

1. Edit the appropriate files in this repository
2. Run `./install.sh` again to update the symlinks

## License

This project is licensed under the MIT License - see the LICENSE file for details.
