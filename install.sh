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
link "$REPO_DIR/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
link "$REPO_DIR/ranger/commands.py" "$HOME/.config/ranger/commands.py"
link "$REPO_DIR/ranger/scope.sh" "$HOME/.config/ranger/scope.sh"

# Scripts
link "$REPO_DIR/bin/pandocx" "$HOME/.local/bin/pandocx"

# Claude global settings and hooks
link "$REPO_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$REPO_DIR/claude/hooks/gsd-check-update.js" "$HOME/.claude/hooks/gsd-check-update.js"
link "$REPO_DIR/claude/hooks/gsd-context-monitor.js" "$HOME/.claude/hooks/gsd-context-monitor.js"
link "$REPO_DIR/claude/hooks/gsd-prompt-guard.js" "$HOME/.claude/hooks/gsd-prompt-guard.js"
link "$REPO_DIR/claude/hooks/gsd-statusline.js" "$HOME/.claude/hooks/gsd-statusline.js"
link "$REPO_DIR/claude/hooks/gsd-workflow-guard.js" "$HOME/.claude/hooks/gsd-workflow-guard.js"

# Git global configs
link "$REPO_DIR/gitignore" "$HOME/.gitignore"
link "$REPO_DIR/git/ignore" "$HOME/.config/git/ignore"

echo ""
echo "Done. All configs symlinked."
