#!/usr/bin/env bash

set -euo pipefail

# Define color codes for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color
INFO="${BLUE}${BOLD}○${NC} "
SUCCESS="${GREEN}${BOLD}✓${NC} "
WARNING="${YELLOW}${BOLD}!${NC} "
ERROR="${RED}${BOLD}✗${NC} "

echo -e "${BLUE}"
cat << EOF
   ██████╗  ██████╗ ██████╗       ███████╗███╗   ███╗██████╗ ███████╗██████╗  ██████╗ ██████╗ 
  ██╔════╝ ██╔═══██╗██╔══██╗      ██╔════╝████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗
  ██║  ███╗██║   ██║██║  ██║█████╗█████╗  ██╔████╔██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝
  ██║   ██║██║   ██║██║  ██║╚════╝██╔══╝  ██║╚██╔╝██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██╔══██╗
  ╚██████╔╝╚██████╔╝██████╔╝      ███████╗██║ ╚═╝ ██║██║     ███████╗██║  ██║╚██████╔╝██║  ██║
   ╚═════╝  ╚═════╝ ╚═════╝       ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝                                                                                         
EOF
echo -e "${NC}"

dependency_packages=(
  ghostty
  snap
  wget
  stow
  git
  nvim
  code
  gh
  zsh
  go
  fdfind
)

# Create necessary directories
mkdir -p "$HOME/.config/zsh"

# Check if Oh-My-Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${INFO}Oh-My-Zsh not found, installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo -e "${SUCCESS}Oh-My-Zsh already installed"
fi

# Create .zshenv in dotfiles repo if it doesn't exist
if [ ! -f ".zshenv" ]; then
  echo "export ZDOTDIR=\"\$HOME/.config/zsh\"" > .zshenv
  echo -e "${SUCCESS}Created .zshenv file"
fi

# Check if gitleaks is installed, install it if not
if ! command -v gitleaks &> /dev/null; then
  echo -e "${INFO}gitleaks not found, installing using go..."
  go install github.com/zricethezav/gitleaks@latest
  echo -e "${SUCCESS}gitleaks installed successfully"
else
  echo -e "${SUCCESS}gitleaks already installed"
fi

# Use the repository-specific git config to set hooks path, not the user's global one
git -C "$(pwd)" config --local core.hooksPath "$(pwd)/git-hooks"
echo -e "${SUCCESS}Git hooks configured for the dotfiles repository only"

all_dependency_packages_are_installed=true
for dep_pkg in "${dependency_packages[@]}"; do
  if ! command -v "$dep_pkg" &>/dev/null; then
    all_dependency_packages_are_installed=false
  fi
done

if $all_dependency_packages_are_installed; then
  echo -e "${SUCCESS}All dependency packages are installed."
  echo -e "${INFO}Starting installation..."
  stow --verbose --target="$HOME" .
  
  # Make zsh the default shell if it's not already
  if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${INFO}Setting Zsh as default shell"
    chsh -s "$(which zsh)"
  fi
  
  echo -e "${SUCCESS}Zsh configuration installed successfully"
else
  echo -e "${ERROR}ONE OR MORE OF THE REQUIRED DEPENDENCY PACKAGES ARE NOT INSTALLED"
  # checks each package individually to see which packages
  # are not installed and echos them out if they are not installed
  for dep_pkg in "${dependency_packages[@]}"; do
    if ! command -v "$dep_pkg" &>/dev/null; then
      echo -e "${ERROR}${dep_pkg} - Status: NOT INSTALLED"
    fi
  done
  exit 1
fi