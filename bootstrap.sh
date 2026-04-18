#!/usr/bin/env bash
# bootstrap.sh - Install packages from Brewfile and npm/globals.txt.
# Run once on a new machine after cloning, then re-run whenever the lists change.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Homebrew ──────────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Install it from https://brew.sh then re-run this script."
  exit 1
fi

echo "==> Installing Homebrew packages from Brewfile..."
brew bundle --file="$REPO_DIR/Brewfile"

# ── npm globals ───────────────────────────────────────────────────────────────

if ! command -v npm &>/dev/null; then
  echo "npm not found — skipping global packages."
else
  GLOBALS_FILE="$REPO_DIR/npm/globals.txt"
  packages=$(grep -v '^#' "$GLOBALS_FILE" | grep -v '^$')

  if [ -n "$packages" ]; then
    echo "==> Installing npm global packages..."
    echo "$packages" | xargs npm install -g
  fi
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────

echo "==> Creating config symlinks..."
"$REPO_DIR/install.sh"

echo ""
echo "Bootstrap complete."
