#!/bin/bash
# Systemd sleep hook for Framework Laptop 16
# Turn off keyboard/numpad LEDs before sleep, restore after wake

STATE_FILE="/tmp/.kbd_rgb_state"

case "$1" in
    pre)
        # Save current RGB state
        brightness=$(/usr/bin/qmk_hid via --rgb-brightness 2>/dev/null | grep -oP '\d+')
        effect=$(/usr/bin/qmk_hid via --rgb-effect 2>/dev/null | grep -oP '\d+')
        echo "${brightness:-100} ${effect:-1}" > "$STATE_FILE"
        # Kill LEDs
        /usr/bin/qmk_hid via --rgb-effect 0 2>/dev/null
        /usr/bin/qmk_hid via --rgb-brightness 0 2>/dev/null
        # Also try numpad if present
        /usr/bin/qmk_hid --pid 0014 via --rgb-effect 0 2>/dev/null
        /usr/bin/qmk_hid --pid 0014 via --rgb-brightness 0 2>/dev/null
        ;;
    post)
        # Restore RGB state in background — retry until keyboard is ready
        (
            read brightness effect < "$STATE_FILE" 2>/dev/null
            for _ in 1 2 3 4 5; do
                /usr/bin/qmk_hid via --rgb-brightness "${brightness:-100}" 2>/dev/null &&
                /usr/bin/qmk_hid via --rgb-effect "${effect:-1}" 2>/dev/null && break
                sleep 0.2
            done
            /usr/bin/qmk_hid --pid 0014 via --rgb-brightness "${brightness:-100}" 2>/dev/null
            /usr/bin/qmk_hid --pid 0014 via --rgb-effect "${effect:-1}" 2>/dev/null
        ) &
        ;;
esac
