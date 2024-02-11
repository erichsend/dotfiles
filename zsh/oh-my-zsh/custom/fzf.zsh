# Set mode to vim prior to running fzf
bindkey -v

# Mac
if [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" 2> /dev/null
fi

# Git Installation with keybindings and completion
if [ -f ~/.fzf.zsh ] 
  PATH="${PATH}:~/.fzf/bin""
  source ~/.fzf.zsh
fi

