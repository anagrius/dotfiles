# Glove80 Firmware Management
#
# Workflow:
#   make setup   - One-time setup: clone ZMK config repo
#   make build   - Compile firmware from custom.keymap
#   make flash   - Flash firmware to both keyboard halves
#
# Or just: make all (runs setup if needed, then build)
#
# Requirements:
#   - Docker (for building)
#
# Files:
#   custom.keymap         - Your keymap configuration
#   firmware/glove80.uf2  - Compiled firmware (after build)
#   glove80-zmk-config/   - ZMK build environment (gitignored)

KEYMAP = custom.keymap
FIRMWARE_DIR = firmware
FIRMWARE = $(FIRMWARE_DIR)/glove80.uf2
ZMK_CONFIG_DIR = glove80-zmk-config
LAYOUT_EDITOR = https://my.glove80.com

.PHONY: all help setup build edit flash clean check-docker

# Default: setup (if needed) + build
all: $(FIRMWARE)

$(FIRMWARE): $(KEYMAP) | check-docker $(ZMK_CONFIG_DIR)
	@./scripts/build.sh

$(ZMK_CONFIG_DIR):
	@./scripts/setup-zmk.sh

check-docker:
	@command -v docker >/dev/null 2>&1 || { echo "Error: Docker is required. Install with: sudo pacman -S docker"; exit 1; }

help:
	@echo "Glove80 Firmware Management"
	@echo ""
	@echo "Usage:"
	@echo "  make          - Build firmware (runs setup if needed)"
	@echo "  make setup    - Clone ZMK config repo (one-time)"
	@echo "  make build    - Build firmware from custom.keymap"
	@echo "  make flash    - Flash firmware to keyboard"
	@echo "  make edit     - Open online layout editor"
	@echo "  make clean    - Remove compiled firmware"
	@echo ""
	@echo "Workflow:"
	@echo "  1. Edit custom.keymap"
	@echo "  2. make build"
	@echo "  3. make flash"

setup: $(ZMK_CONFIG_DIR)

build: check-docker $(ZMK_CONFIG_DIR)
	@./scripts/build.sh

edit:
	@echo "Opening Glove80 Layout Editor..."
	@xdg-open $(LAYOUT_EDITOR) 2>/dev/null || open $(LAYOUT_EDITOR)

flash: $(FIRMWARE)
	@./scripts/flash.sh

clean:
	@echo "Removing compiled firmware..."
	@rm -f $(FIRMWARE_DIR)/*.uf2
	@echo "Done. Run 'make build' to recompile."
