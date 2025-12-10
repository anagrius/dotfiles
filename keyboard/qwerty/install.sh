#!/bin/bash
# Installation script for Nordic keyboard layout

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Nordic Keyboard Layout Installer"
echo "================================="
echo ""
echo "Choose installation method:"
echo "1) XKB system layout (X11/XWayland) - requires sudo"
echo "2) keyd configuration (Wayland native) - requires sudo and keyd"
echo "3) XCompose (user-level, works everywhere)"
echo "4) Exit"
echo ""

read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo "Installing XKB layout..."

        if [ ! -d "/usr/share/X11/xkb/symbols" ]; then
            echo "Error: /usr/share/X11/xkb/symbols not found"
            echo "This system may not have X11/XWayland"
            exit 1
        fi

        sudo cp "$SCRIPT_DIR/us-nordic" /usr/share/X11/xkb/symbols/
        echo "Layout file copied to /usr/share/X11/xkb/symbols/us-nordic"

        echo ""
        echo "To activate the layout, run:"
        echo "  setxkbmap us-nordic"
        echo ""
        echo "For RAlt-only variant (recommended if LAlt conflicts with WM):"
        echo "  setxkbmap us-nordic -variant ralt_only"
        echo ""
        echo "To make persistent, add to your startup scripts"
        ;;

    2)
        echo "Installing keyd configuration..."

        if ! command -v keyd &> /dev/null; then
            echo "Error: keyd not found. Install it first:"
            echo "  Arch: sudo pacman -S keyd"
            echo "  Or: https://github.com/rvaiya/keyd"
            exit 1
        fi

        sudo mkdir -p /etc/keyd
        sudo cp "$SCRIPT_DIR/keyd.conf" /etc/keyd/nordic.conf
        echo "Configuration copied to /etc/keyd/nordic.conf"

        echo ""
        echo "You may need to include this in your main keyd config:"
        echo "  include nordic.conf"
        echo ""
        echo "Then reload keyd:"
        echo "  sudo systemctl restart keyd"
        ;;

    3)
        echo "Installing XCompose..."

        if [ -f "$HOME/.XCompose" ]; then
            echo "Backing up existing ~/.XCompose to ~/.XCompose.bak"
            cp "$HOME/.XCompose" "$HOME/.XCompose.bak"
        fi

        cp "$SCRIPT_DIR/XCompose" "$HOME/.XCompose"
        echo "XCompose file installed to ~/.XCompose"

        echo ""
        echo "XCompose uses the Compose key to enter characters."
        echo "Set your Compose key (typically Right Alt or Menu key)"
        echo ""
        echo "Usage examples:"
        echo "  Compose + a + e = æ"
        echo "  Compose + ; + d = æ (for Danish at semicolon position)"
        echo "  Compose + ; + s = ä (for Swedish at semicolon position)"
        ;;

    4)
        echo "Exiting..."
        exit 0
        ;;

    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Installation complete!"
