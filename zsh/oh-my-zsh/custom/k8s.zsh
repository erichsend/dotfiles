####### Kubernetes Helpers

## aliases and functions
alias kfull='kubectl config get-contexts'
alias ktx='kubectx'
alias kns='kubens'
function k() { kubectl "$@"; }
