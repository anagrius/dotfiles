#!/usr/bin/env bash
# Build Glove80 firmware locally using Docker
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOVE80_DIR="$(dirname "$SCRIPT_DIR")"
ZMK_CONFIG_DIR="$GLOVE80_DIR/glove80-zmk-config"
CUSTOM_KEYMAP="$GLOVE80_DIR/custom.keymap"
CUSTOM_CONF="$GLOVE80_DIR/glove80.conf"
FIRMWARE_DIR="$GLOVE80_DIR/firmware"

# Check prerequisites
if [[ ! -d "$ZMK_CONFIG_DIR" ]]; then
    echo "Error: glove80-zmk-config not found."
    echo "Run 'make setup' first."
    exit 1
fi

if [[ ! -f "$CUSTOM_KEYMAP" ]]; then
    echo "Error: custom.keymap not found at $CUSTOM_KEYMAP"
    exit 1
fi

if ! command -v docker &>/dev/null; then
    echo "Error: Docker is required for building."
    echo "Install with: sudo pacman -S docker"
    exit 1
fi

# Copy custom keymap and config into the zmk config
echo "Copying custom.keymap and glove80.conf to glove80-zmk-config..."
cp "$CUSTOM_KEYMAP" "$ZMK_CONFIG_DIR/config/glove80.keymap"
if [[ -f "$CUSTOM_CONF" ]]; then
    cp "$CUSTOM_CONF" "$ZMK_CONFIG_DIR/config/glove80.conf"
fi

# Build using the repo's build.sh (Docker + Nix)
echo "Building firmware (this may take a while on first run)..."
cd "$ZMK_CONFIG_DIR"

# Build with main branch (per-key RGB is now in main)
./build.sh main

# Copy firmware to our firmware directory
if [[ -f "$ZMK_CONFIG_DIR/glove80.uf2" ]]; then
    mkdir -p "$FIRMWARE_DIR"
    cp "$ZMK_CONFIG_DIR/glove80.uf2" "$FIRMWARE_DIR/"
    echo ""
    echo "Firmware built successfully: $FIRMWARE_DIR/glove80.uf2"
    echo "Run 'make flash' to flash the keyboard."
else
    echo "Error: Build failed - no glove80.uf2 produced"
    exit 1
fi
