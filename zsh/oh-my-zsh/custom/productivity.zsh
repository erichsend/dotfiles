# alias to send output to vim
alias v='nvim -'

# Tools Environment
alias tools="tmuxp load ~/.config/tmuxp/tools.yaml -d"

# Dotfiles Environment
alias dotfiles="tmuxp load ~/.config/tmuxp/dotfiles.yaml -d"

# Dev Environment
function dev { REPO=$1 tmuxp load dev }
