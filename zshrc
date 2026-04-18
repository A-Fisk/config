
# =============================================================================
# INPUT
# =============================================================================

bindkey -v


# =============================================================================
# PATH
# =============================================================================

export PATH="$HOME/.cargo/bin:$PATH"                        # rustup over homebrew rust
export PATH="$(brew --prefix cyrus-sasl)/sbin:$PATH"
export PATH="$(brew --prefix curl)/bin:$PATH"
export PATH="$(brew --prefix pandoc)/bin:$PATH"
export PATH="$(brew --prefix vim)/bin:$PATH"
export PATH="$(brew --prefix python@3.13)/bin:$PATH"
export PATH="$(brew --prefix node)/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"                        # uv, aider
export PATH="$PATH:$HOME/.lmstudio/bin"                     # LM Studio CLI


# =============================================================================
# ENVIRONMENT
# =============================================================================

# XDG base dirs (used by oauth2ms with mbsync)
export XDG_CONFIG_HOME="$HOME/.config"

# GPG
export GPG_TTY=$(tty)

# cyrus-sasl (for mbsync)
export LDFLAGS="-L$(brew --prefix cyrus-sasl)/lib"
export CPPFLAGS="-I$(brew --prefix cyrus-sasl)/include"
export SASL_PATH="$(brew --prefix cyrus-sasl)/lib/sasl2"

# Ollama
export OLLAMA_API_BASE=http://127.0.0.1:11434


# =============================================================================
# API KEYS
# =============================================================================

export ANTHROPIC_API_KEY=$(pass apis/anthropic)
export GEMINI_API_KEY=$(pass apis/gemini)
export OPENAI_API_KEY=$(pass apis/openai)
export JIRA_API_TOKEN=$(pass apis/jira)
export EVENTBRITE_TOKEN=$(pass apis/eventbrite)


# =============================================================================
# SSH
# =============================================================================

ssh-add --apple-use-keychain ~/.ssh/id_ed25519


# =============================================================================
# ALIASES
# =============================================================================

alias restart="source ~/.zshrc"
alias pwcopy='pwd | pbcopy'
alias gdrive="cd $HOME/Documents/Google_drive"
alias idea="vim $HOME/Documents/github_repos/GTD/idea_capture.md"
alias gtd="uv run python $HOME/Documents/github_repos/GTD/gtd_viewer.py -f $HOME/Documents/github_repos/GTD/idea_capture.md"


# =============================================================================
# PROMPT
# =============================================================================

# Current git branch
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

# Current git user email
function git_current_user_email() {
    command git config user.email 2>/dev/null
}

COLOR_DEF=$'%f'
COLOR_USR=$'%F{243}'
COLOR_DIR=$'%F{197}'
COLOR_GIT=$'%F{39}'
setopt PROMPT_SUBST
export PROMPT='${COLOR_USR}$(git_current_user_email) ${COLOR_DIR}/%1d ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF} $ '

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/angusfisk/.lmstudio/bin"
# End of LM Studio CLI section

