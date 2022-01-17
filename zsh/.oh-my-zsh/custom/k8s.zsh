####### Kubernetes Helpers

## aliases and functions
alias kfull='kubectl config get-contexts'
alias ktx='kubectx'
function kc() { kubectl "$@"; }
function kns() { kubectl config set-context --current --namespace="$1"; }

## kubeps1
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
KUBE_PS1_SYMBOL_ENABLE=false
alias kon='kubeon'
alias koff='kubeoff'
