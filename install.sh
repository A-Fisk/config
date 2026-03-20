#!/usr/bin/env bash
# install.sh - Create symlinks from system config locations to this repo.
# Run this once on a new machine after cloning.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1"
  local dest="$2"
  local dest_dir="$(dirname "$dest")"

  mkdir -p "$dest_dir"

  if [ -L "$dest" ]; then
    echo "Relinking: $dest"
    rm "$dest"
  elif [ -f "$dest" ]; then
    echo "Backing up existing file: $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -s "$src" "$dest"
  echo "Linked: $dest -> $src"
}

# Zsh
link "$REPO_DIR/zshrc" "$HOME/.zshrc"

# Vim
link "$REPO_DIR/vim/vimrc" "$HOME/.vimrc"

# Kitty
link "$REPO_DIR/kitty/kitty.conf"    "$HOME/.config/kitty/kitty.conf"
link "$REPO_DIR/kitty/theme.conf"    "$HOME/.config/kitty/theme.conf"
link "$REPO_DIR/kitty/get_layout.py" "$HOME/.config/kitty/get_layout.py"
link "$REPO_DIR/kitty/pass_keys.py"  "$HOME/.config/kitty/pass_keys.py"

# Tmux
link "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"

# Ranger
link "$REPO_DIR/ranger/rifle.conf" "$HOME/.config/ranger/rifle.conf"

echo ""
echo "Done. All configs symlinked."
