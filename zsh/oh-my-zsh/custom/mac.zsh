# Things only used on my mac
if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
  export PATH=$HOME/go/bin:$PATH
  export PATH=$HOME/.local/bin:$PATH
fi
