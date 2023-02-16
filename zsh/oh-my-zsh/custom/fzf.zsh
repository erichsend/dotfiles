# Set mode to vim prior to running fzf
bindkey -v

# Mac
if [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" 2> /dev/null
fi

# Ubuntu
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    . /usr/share/doc/fzf/examples/completion.zsh 2> /dev/null
    . /usr/share/doc/fzf/examples/key-bindings.zsh 2> /dev/null
fi

