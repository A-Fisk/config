# uv
export PATH="/Users/afis0660/.local/bin:$PATH"

# Homebrew (moved here from .zprofile: tmux windows are non-login shells, so
# .zprofile never runs for new tmux panes, leaving PATH/FPATH stale and
# breaking compinit/completion. .zshenv runs for every shell regardless.)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
