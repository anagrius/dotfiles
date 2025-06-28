. "$HOME/.cargo/env"

# Set Zsh configuration directory
export ZDOTDIR="$HOME/.config/zsh"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Use Wayland for Electron
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# Set locale (needed by all processes)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Add common directories to PATH
export PATH="$HOME/.local/bin:$PATH"

# Set default editor
export EDITOR="nvim"
export VISUAL="nvim"
