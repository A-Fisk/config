#!/usr/bin/env bash
# bootstrap.sh - Install packages from Brewfile/apt/packages.txt and npm/globals.txt.
# Run once on a new machine after cloning, then re-run whenever the lists change.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── OS packages ───────────────────────────────────────────────────────────────

case "$(uname -s)" in
  Darwin)
    if ! command -v brew &>/dev/null; then
      echo "Homebrew not found. Install it from https://brew.sh then re-run this script."
      exit 1
    fi

    echo "==> Installing Homebrew packages from Brewfile..."
    brew bundle --file="$REPO_DIR/Brewfile"
    ;;
  Linux)
    if ! command -v apt-get &>/dev/null; then
      echo "apt-get not found — skipping OS package install. Install packages from apt/packages.txt manually."
    else
      echo "==> Installing apt packages from apt/packages.txt..."
      PACKAGES_FILE="$REPO_DIR/apt/packages.txt"
      packages=$(grep -v '^#' "$PACKAGES_FILE" | grep -v '^$')

      if [ -n "$packages" ]; then
        sudo apt-get update
        echo "$packages" | xargs sudo apt-get install -y
      fi
    fi
    ;;
  *)
    echo "Unrecognized OS ($(uname -s)) — skipping OS package install."
    ;;
esac

# ── uv tools (Linux only — macOS gets these via the Brewfile's `uv "..."` entries) ─

if [ "$(uname -s)" = "Linux" ]; then
  if ! command -v uv &>/dev/null; then
    echo "uv not found — skipping uv tool installs. Install it (e.g. 'pip3 install --user uv') then re-run this script."
  else
    TOOLS_FILE="$REPO_DIR/uv/tools.txt"
    tools=$(grep -v '^#' "$TOOLS_FILE" | grep -v '^$')

    if [ -n "$tools" ]; then
      echo "==> Installing uv tools from uv/tools.txt..."
      echo "$tools" | xargs -n1 uv tool install
    fi
  fi
fi

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
