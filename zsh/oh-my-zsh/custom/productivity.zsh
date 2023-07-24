# Scratchpads
alias todo='$EDITOR ~/.todo'
alias cc='$EDITOR ~/.cheatsheet'

# Config
alias dot="$EDITOR ~/repo/dotfiles --cmd 'cd ~/repo/dotfiles'"

# Navigation
alias vd='cd ~/.vim'
alias zd='cd ~/.oh-my-zsh/custom'
alias td='cd ~/.tmux'
alias dd='cd ~/repo/dotfiles/'

# alias to send output to vim
alias v='nvim -'

# quick gpt
function gpt() { echo "$@" | openai complete - --token $OPENAI_API_KEY }

# Tools Environment
alias tools="tmuxp load ~/.config/tmuxp/tools.yaml -d"

# Dotfiles Environment
alias dotfiles="tmuxp load ~/.config/tmuxp/dotfiles.yaml -d"

# Dev Environment
function dev () { REPO="$@" && tmuxp load ~/.config/tmuxp/dev.yaml -d }
