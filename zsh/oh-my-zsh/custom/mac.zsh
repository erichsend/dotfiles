# Things only used on my mac
if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
  export PATH=$HOME/go/bin:$PATH
  export PATH=$HOME/.local/bin:$PATH

  # Installed volta via homebrew, and had to add this per https://docs.volta.sh/guide/getting-started
  VOLTA_HOME=/Users/davide/.volta
  PATH=$VOLTA_HOME/bin:$PATH
fi
