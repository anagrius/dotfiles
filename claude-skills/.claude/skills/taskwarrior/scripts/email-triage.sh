#!/bin/bash
# Email triage for day planning — fetches recent actionable emails via gog CLI.
# Skips if already run today (tracks via timestamp file).
#
# Usage: bash email-triage.sh [--force]
#   --force  Run even if already checked today

STAMP_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/taskwarrior-email-triage-stamp"
mkdir -p "$(dirname "$STAMP_FILE")"

# Check if already run today (unless --force)
if [[ "$1" != "--force" ]] && [[ -f "$STAMP_FILE" ]]; then
    last_check=$(cat "$STAMP_FILE")
    today=$(date +%Y-%m-%d)
    if [[ "$last_check" == "$today" ]]; then
        echo "SKIP: Email triage already done today ($today). Use --force to re-run."
        exit 0
    fi
fi

# Check gog is available
if ! command -v gog &>/dev/null; then
    echo "ERROR: gog CLI not found. Install it or run 'gog login' to authenticate."
    exit 1
fi

echo "=== Email Triage $(date +%Y-%m-%d) ==="
echo ""

# Fetch unread emails from last 3 days, excluding noise
echo "--- Unread emails (excluding promotions/social) ---"
gog gmail messages search "is:unread newer_than:3d -category:promotions -category:social" --max=15 --plain 2>&1

echo ""
echo "--- Starred/important threads from last 7 days ---"
gog gmail search "is:starred newer_than:7d" --max=5 --plain 2>&1

# Record today's date
date +%Y-%m-%d > "$STAMP_FILE"
echo ""
echo "DONE: Triage complete. Timestamp saved."
