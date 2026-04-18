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

| Repo path                          | System path                        |
|------------------------------------|------------------------------------|
| vim/vimrc                          | ~/.vimrc                           |
| kitty/kitty.conf                   | ~/.config/kitty/kitty.conf         |
| kitty/get_layout.py                | ~/.config/kitty/get_layout.py      |
| kitty/pass_keys.py                 | ~/.config/kitty/pass_keys.py       |
| kitty/theme.conf                   | ~/.config/kitty/theme.conf         |
| tmux.conf                          | ~/.tmux.conf                       |
| zshrc                              | ~/.zshrc                           |
| ranger/rifle.conf                  | ~/.config/ranger/rifle.conf        |
| ranger/rc.conf                     | ~/.config/ranger/rc.conf           |
| ranger/commands.py                 | ~/.config/ranger/commands.py       |
| ranger/scope.sh                    | ~/.config/ranger/scope.sh          |
| gitignore                          | ~/.gitignore                       |
| git/ignore                         | ~/.config/git/ignore               |
| claude/settings.json               | ~/.claude/settings.json            |
| claude/hooks/*.js                  | ~/.claude/hooks/*.js               |

## Claude Code Setup

This repo includes Claude Code **global** settings and GSD (Get Stuff Done) hooks for a consistent development environment across machines.

### Directory structure:
- **`claude/`**: Global Claude settings that get symlinked to `~/.claude/`
- **`.claude/`**: Project-local Claude settings (gitignored, specific to this repo)

### Global settings (`claude/` → `~/.claude/`):
- **settings.json**: Core Claude settings including permissions, sandbox config, and hooks
- **hooks/*.js**: GSD JavaScript hook files that provide enhanced workflow features:
  - `gsd-check-update.js`: Checks for GSD updates on session start
  - `gsd-context-monitor.js`: Monitors context and state changes
  - `gsd-prompt-guard.js`: Guards against problematic prompts
  - `gsd-statusline.js`: Provides status line information
  - `gsd-workflow-guard.js`: Workflow protection features

### Plugin dependencies:
The hooks require GSD to be installed in your Claude environment. The GSD system should be installed at `~/.claude/get-shit-done/`. The settings include `enabledPlugins` configuration for additional plugins like `planning-with-files`.

### How it works:
1. Global settings in `claude/` are symlinked to `~/.claude/` by `install.sh`
2. Project-local settings in `.claude/` (like the existing `settings.local.json`) remain local
3. Claude merges global + local settings when running in this project
4. Changes to `claude/settings.json` in this repo affect Claude globally
5. Changes to `.claude/settings.local.json` only affect Claude when in this project

## SSH

Two SSH keys are configured, one per GitHub account:

| Key | Host | Account |
|-----|------|---------|
| `~/.ssh/id_ed25519` | github.com | angus_fisk@hotmail.com (personal) |
| `~/.ssh/id_ed25519_usyd` | github.sydney.edu.au | afis0660 (University of Sydney) |

`~/.ssh/config` maps each host to its key so the correct one is picked automatically on push/pull. Both keys are added to the macOS Keychain via `zshrc`, so passphrases only need to be entered once (after which they persist across reboots).

On a new machine, generate or copy the keys into `~/.ssh/`, then run:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_usyd
```

Add the public keys (`~/.ssh/id_ed25519.pub`, `~/.ssh/id_ed25519_usyd.pub`) to each GitHub account under Settings > SSH keys. The `~/.ssh/config` file is not tracked in this repo — create it manually:

```
Host github.sydney.edu.au
    IdentityFile ~/.ssh/id_ed25519_usyd
    AddKeysToAgent yes
    UseKeychain yes

Host github.com
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes
```

## GPG

GPG is used for commit signing. To cache passphrases for 24 hours (so you're not prompted on every new tmux pane), create `~/.gnupg/gpg-agent.conf`:

```
default-cache-ttl 86400
max-cache-ttl 86400
```

Then reload the agent:

```bash
gpgconf --kill gpg-agent
```

The agent restarts automatically on next use and passphrases will persist for 24 hours.

## zshrc (future)

To safely track `.zshrc`:
1. Add `source ~/.zshrc.local` at the bottom of your `.zshrc`
2. Keep API keys and machine-specific secrets in `~/.zshrc.local` (gitignored)
3. Commit `.zshrc` to this repo — secrets never leave the machine
