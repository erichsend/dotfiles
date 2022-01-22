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

## aws setup -- move to kong.sh?
export SAML2AWS_IDP_PROVIDER=Okta
export SAML2AWS_MFA=OKTA
export SAML2AWS_PROFILE=saml
export SAML2AWS_SESSION_DURATION=43200 # 12 hours
export SAML2AWS_URL="https://konghq.okta.com/home/amazon_aws/0oa648904kKStWghq357/272"
export SAML2AWS_USERNAME="david.erichsen@konghq.com"


alias k="kubectl"
alias tf="terraform"
alias local-k8s="ktx docker-desktop && kns default"
alias dev-k8s="ktx kong-cloud-01-dev-us-east-2 && kns konnect"
alias stage-k8s="ktx kong-cloud-01-stage-us-west-2 && kns konnect"
alias prod-k8s="ktx kong-cloud-01-prod-us-east-2 && kns konnect"

function k8s() {
	saml2aws login -p kong-cloud-01-dev --role arn:aws:iam::727954360595:role/konnect-developer --skip-prompt --force
	saml2aws login -p kong-cloud-01-stage --role arn:aws:iam::041587422721:role/poweruser --skip-prompt --force
	saml2aws login -p kong-cloud-01-prod --role arn:aws:iam::043537634012:role/poweruser --skip-prompt --force

	# K8s Contexts
	aws --profile kong-cloud-01-dev eks update-kubeconfig --region us-east-2 --name eks-01 --alias kong-cloud-01-dev-us-east-2
	aws --profile kong-cloud-01-stage eks update-kubeconfig --region us-west-2 --name eks-01 --alias kong-cloud-01-stage-us-west-2
	aws --profile kong-cloud-01-prod eks update-kubeconfig --region us-east-2 --name eks-01 --alias kong-cloud-01-prod-us-east-2

	# Always default to local k8s context
	local-k8s
}
