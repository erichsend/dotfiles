export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/go

export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin

# On M-Series, ensure OS is specified
export GOOS=darwin
export GOARCH=arm64
