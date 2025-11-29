# Glove80 Firmware Management
# Compilation happens online at https://my.glove80.com
# This Makefile provides helpers for the workflow

KEYMAP = glove80.keymap
FIRMWARE_DIR = firmware
LAYOUT_EDITOR = https://my.glove80.com

.PHONY: help edit flash clean

help:
	@echo "Glove80 Firmware Targets:"
	@echo "  make edit   - Open the Glove80 Layout Editor"
	@echo "  make flash  - Flash firmware to keyboard"
	@echo "  make clean  - Remove old firmware files"
	@echo ""
	@echo "Workflow:"
	@echo "  1. Edit keymap at $(LAYOUT_EDITOR)"
	@echo "  2. Download .uf2 firmware to $(FIRMWARE_DIR)/"
	@echo "  3. Run 'make flash' to flash both halves"

edit:
	@echo "Opening Glove80 Layout Editor..."
	xdg-open $(LAYOUT_EDITOR) 2>/dev/null || open $(LAYOUT_EDITOR)

flash:
	@./scripts/flash.sh

clean:
	@echo "Removing old firmware files..."
	rm -f $(FIRMWARE_DIR)/*.uf2
