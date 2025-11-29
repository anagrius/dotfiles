#!/usr/bin/env bash
set -euo pipefail

# Thomas Anagrius's Arch Linux setup script

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}==>${NC} $1"; }
error() { echo -e "${RED}ERROR:${NC} $1" >&2; exit 1; }

# Check if running on Arch
[[ -f /etc/arch-release ]] || error "This script is for Arch Linux only"

# Install yay if not present
if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel git

    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$tmpdir"

    info "yay installed successfully"
else
    info "yay already installed"
fi

# Packages to install
PACKAGES=(
    # Version control
    jujutsu      # jj - Git-compatible VCS

    # CLI utilities
    tree         # Directory listing
)

info "Installing packages..."
yay -S --needed --noconfirm "${PACKAGES[@]}"

info "Done! Run 'stow <package>' to install dotfiles."
