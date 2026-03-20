
bindkey -v
# export PATH="/usr/local/bin:$PATH"
# export PATH="/usr/bin:$PATH"
# export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH" # uses rustup preferentially over homebrew rust
export PATH="/opt/homebrew/opt/cyrus-sasl/sbin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="/opt/homebrew/opt/pandoc/bin:$PATH" # uses brew pandoc 
export PATH="/opt/homebrew/opt/vim/bin:$PATH" # uses brew vim 
export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH" # uses homebrew python 
export PATH="/opt/homebrew/Cellar/node/23.11.0/bin:$PATH" # uses homebrew node 
export PATH="/Users/angusfisk/.local/bin:$PATH" # for aider
export SASL_PATH="/opt/homebrew/Cellar/cyrus-sasl/2.1.28_2/lib/sasl2:$PATH" #for sasl for mbsync

# setup xdg for oauth2ms with mbsync
export XDG_CONFIG_HOME="$HOME/.config"
export GPG_TTY=$(tty)
export LDFLAGS="-L/opt/homebrew/opt/cyrus-sasl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/cyrus-sasl/include"
export SASL_PATH="/opt/homebrew/opt/cyrus-sasl/lib/sasl2"

# set up ollama 
export OLLAMA_API_BASE=http://127.0.0.1:11434

# API keys
export ANTHROPIC_API_KEY=$(pass apis/anthropic)
export GEMINI_API_KEY=$(pass apis/gemini)
export OPENAI_API_KEY=$(pass apis/openai)

## SSH
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

alias restart="source ~/.zshrc"
alias gdrive="cd /Users/angusfisk/Documents/Google_drive"
alias idea="vim /Users/angusfisk/Documents/github_repos/GTD/idea_capture.md"
alias pwcopy='pwd | pbcopy'
alias gtd="uv run python /Users/angusfisk/Documents/github_repos/GTD/gtd_viewer.py -f /Users/angusfisk/Documents/github_repos/GTD/idea_capture.md"


# set git branch and user in prompt
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}
# Outputs the email of the current user
# Usage example: $(git_current_user_email)
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

