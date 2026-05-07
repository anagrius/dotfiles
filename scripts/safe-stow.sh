#!/usr/bin/env bash
# Stow with automatic backup of conflicting files.
#
# Detects conflicts via `stow -n` and moves each offending file to
# <path>.bak.<timestamp> before invoking stow for real. This keeps a
# fresh-machine `make stow` from aborting on Omarchy's default configs.
#
# Usage: safe-stow.sh <package> [<package>...]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STOW_FLAGS=(--dotfiles -v -d "$REPO_DIR" -t "$HOME")

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <package> [<package>...]" >&2
    exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
    echo "ERROR: stow is not installed. Run ./install.sh first." >&2
    exit 1
fi

# stow's conflict messages mention "existing target <path>" (with the path
# relative to the target dir, $HOME). Match both wordings stow has used:
#   "* cannot stow X over existing target <path> since ..."
#   "* existing target is <reason>: <path>"
mapfile -t conflicts < <(
    stow -n "${STOW_FLAGS[@]}" "$@" 2>&1 \
        | sed -nE 's/.*existing target[: ]+([^[:space:]]+).*/\1/p' \
        | sort -u
)

if (( ${#conflicts[@]} > 0 )); then
    timestamp=$(date +%Y%m%d-%H%M%S)
    echo "Backing up ${#conflicts[@]} conflicting path(s) to .bak.$timestamp:"
    for path in "${conflicts[@]}"; do
        full="$HOME/$path"
        backup="$full.bak.$timestamp"
        if [[ -e "$full" || -L "$full" ]]; then
            echo "  $full -> $backup"
            mv "$full" "$backup"
        fi
    done
fi

stow "${STOW_FLAGS[@]}" "$@"
