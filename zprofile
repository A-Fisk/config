# Intentionally minimal — brew shellenv and OrbStack init live in zshenv
# instead, since .zprofile doesn't run for non-login shells (e.g. new tmux
# panes), which left PATH/FPATH stale there. See zshenv.
