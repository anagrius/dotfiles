#!/usr/bin/env bash
set -euo pipefail

# Glove80 Flash Script
# Flashes firmware to both halves of the Glove80 keyboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRMWARE_DIR="${SCRIPT_DIR}/../firmware"
DOWNLOADS_DIR="$HOME/Downloads"
MOUNT_BASE="/run/media/$USER"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Find firmware file
find_firmware() {
    local firmware=""

    # Check if argument provided
    if [[ -n "${1:-}" ]] && [[ -f "$1" ]]; then
        firmware="$1"
    # Check firmware directory
    elif [[ -d "$FIRMWARE_DIR" ]]; then
        firmware=$(ls -t "$FIRMWARE_DIR"/*.uf2 2>/dev/null | head -1)
    fi

    # Fallback to Downloads
    if [[ -z "$firmware" ]]; then
        firmware=$(ls -t "$DOWNLOADS_DIR"/*.uf2 2>/dev/null | grep -i glove80 | head -1 || true)
        if [[ -z "$firmware" ]]; then
            firmware=$(ls -t "$DOWNLOADS_DIR"/*.uf2 2>/dev/null | head -1 || true)
        fi
    fi

    echo "$firmware"
}

# Wait for device to mount
wait_for_device() {
    local device_name="$1"
    local timeout=60
    local elapsed=0

    echo -n "Waiting for $device_name to mount"
    while [[ $elapsed -lt $timeout ]]; do
        if [[ -d "$MOUNT_BASE/$device_name" ]]; then
            echo ""
            return 0
        fi
        echo -n "."
        sleep 1
        ((elapsed++))
    done
    echo ""
    return 1
}

# Flash a single half
flash_half() {
    local side="$1"      # "RIGHT" or "LEFT"
    local device="$2"    # "GLV80RHBOOT" or "GLV80LHBOOT"
    local firmware="$3"

    print_header "FLASHING ${side} HALF"

    echo -e "${BOLD}To enter bootloader mode:${NC}"
    echo ""
    echo "  1. Hold the ${BOLD}MAGIC${NC} key (bottom left corner key)"
    echo "  2. While holding MAGIC, tap the ${BOLD}upper-left key${NC} in the Magic layer"
    echo "     (This is typically bound to &bootloader)"
    echo "  3. The keyboard half will disconnect and remount as ${BOLD}${device}${NC}"
    echo ""

    if [[ "$side" == "LEFT" ]]; then
        print_warning "Make sure the ${BOLD}LEFT${NC} half is connected via USB"
    else
        print_warning "Disconnect the LEFT half"
        print_warning "Connect the ${BOLD}RIGHT${NC} half via USB"
    fi

    echo ""
    read -p "Press ENTER when ready to flash ${side} half..."

    if ! wait_for_device "$device"; then
        print_error "Timeout waiting for $device"
        print_warning "Make sure you entered bootloader mode correctly"
        return 1
    fi

    print_success "Found $device at $MOUNT_BASE/$device"
    print_step "Copying firmware..."

    cp "$firmware" "$MOUNT_BASE/$device/"
    sync

    print_success "${side} half flashed successfully!"
    echo ""
    print_step "Keyboard will reboot automatically..."
    sleep 3
}

# Main
main() {
    print_header "GLOVE80 FIRMWARE FLASH"

    # Find firmware
    local firmware
    firmware=$(find_firmware "${1:-}")

    if [[ -z "$firmware" ]]; then
        print_error "No firmware file found!"
        echo ""
        echo "Please either:"
        echo "  1. Place .uf2 file in: $FIRMWARE_DIR/"
        echo "  2. Download from https://my.glove80.com to ~/Downloads/"
        echo "  3. Provide path as argument: $0 /path/to/firmware.uf2"
        exit 1
    fi

    print_success "Using firmware: $(basename "$firmware")"
    echo "  Path: $firmware"
    echo ""
    read -p "Press ENTER to continue or Ctrl+C to abort..."

    # Flash left half first
    flash_half "LEFT" "GLV80LHBOOT" "$firmware"

    # Flash right half
    flash_half "RIGHT" "GLV80RHBOOT" "$firmware"

    # Factory reset instructions
    print_header "FACTORY RESET (Optional)"

    echo -e "${BOLD}If you experience issues, perform a factory reset:${NC}"
    echo ""
    echo "  1. Unplug the keyboard"
    echo "  2. Hold the ${BOLD}MAGIC${NC} key (bottom left corner)"
    echo "  3. While holding MAGIC, plug in the USB cable"
    echo "  4. Continue holding MAGIC for 5 seconds"
    echo "  5. Release MAGIC - the keyboard will reset to factory defaults"
    echo ""
    echo "  Note: This clears pairing info and settings, but keeps the firmware."
    echo ""

    print_header "FLASHING COMPLETE"
    print_success "Both halves have been flashed!"
    echo ""
    echo "Reconnect your keyboard normally to use the new firmware."
}

main "$@"
