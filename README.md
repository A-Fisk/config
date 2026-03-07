# config

Dotfiles for kitty and vim, synced across machines via git.

## Setup on a new machine

```bash
git clone <repo-url> ~/Documents/github_repos/config
cd ~/Documents/github_repos/config
chmod +x install.sh
./install.sh
```

`install.sh` creates symlinks from the standard config locations to the files in
this repo. Any edits you make to `~/.vimrc`, `~/.config/kitty/kitty.conf`, etc.
are immediately reflected in the repo — just `git add` and `git commit`.

## Syncing changes to another machine

```bash
git pull
```

The post-merge and post-checkout hooks automatically re-run `install.sh` so
symlinks are always up to date.

## Files tracked

| Repo path              | System path                        |
|------------------------|------------------------------------|
| vim/vimrc              | ~/.vimrc                           |
| kitty/kitty.conf       | ~/.config/kitty/kitty.conf         |
| kitty/get_layout.py    | ~/.config/kitty/get_layout.py      |
| kitty/pass_keys.py     | ~/.config/kitty/pass_keys.py       |

## zshrc (future)

To safely track `.zshrc`:
1. Add `source ~/.zshrc.local` at the bottom of your `.zshrc`
2. Keep API keys and machine-specific secrets in `~/.zshrc.local` (gitignored)
3. Commit `.zshrc` to this repo — secrets never leave the machine
