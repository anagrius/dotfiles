#!/usr/bin/env bash
# Clone MoErgo's glove80-zmk-config for local builds
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOVE80_DIR="$(dirname "$SCRIPT_DIR")"
ZMK_CONFIG_DIR="$GLOVE80_DIR/glove80-zmk-config"

if [[ -d "$ZMK_CONFIG_DIR" ]]; then
    echo "glove80-zmk-config already exists at $ZMK_CONFIG_DIR"
    echo "To update: cd $ZMK_CONFIG_DIR && git pull"
    exit 0
fi

echo "Cloning MoErgo glove80-zmk-config (shallow clone)..."
git clone --depth 1 https://github.com/moergo-sc/glove80-zmk-config.git "$ZMK_CONFIG_DIR"

echo ""
echo "Done! ZMK config cloned to: $ZMK_CONFIG_DIR"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/build.sh"
echo "  2. Flash the resulting firmware with: make flash"
