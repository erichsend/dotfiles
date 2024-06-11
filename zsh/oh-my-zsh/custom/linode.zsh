function add-lke-conf() { 
  if [ -z "$1" ]; then
      echo "Please provide a linode kubernetes cluster id"
      exit 1
  fi

  linode-cli lke kubeconfig-view $1 --json | jq -r '.[].kubeconfig' | base64 -d >> lkeconf.tmp
  export KUBECONFIG=$HOME/.kube/config:$(pwd)/lkeconf.tmp
  kubectl config view --flatten > $HOME/.kube/config
  rm lkeconf.tmp
}

function rem-lke-conf() {
  
  for context in $(kubectl config get-contexts -o name | grep '^lke'); do
    kubectl config delete-context $context
  done
  
  for cluster in $(kubectl config get-clusters | grep '^lke'); do
    kubectl config delete-cluster $cluster
  done
  
  for user in $(kubectl config view -o=jsonpath='{.users[*].name}' | tr -s ' ' '\n' | grep '^lke'); do
    kubectl config delete-user $user
  done
  
}
