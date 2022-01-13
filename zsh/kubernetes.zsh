# kubernetes
function kube-staging {
  gcloud container clusters get-credentials staging --zone europe-west1-b --project staging2-284609
  export KUBE_NAMESPACE=staging
}
alias ks="kube-staging"

function kube-qa {
  gcloud container clusters get-credentials qa --region=europe-west1-b --project=quality-and-assurance
  export KUBE_NAMESPACE=qa
}
alias kq="kube-qa"

function kube-demo {
  gcloud container clusters get-credentials non-critical --zone europe-west3-c --project infra-195110
  export KUBE_NAMESPACE=sandbox
}
alias kd="kube-demo"

function kube-production {
  gcloud container clusters get-credentials production --region europe-west3 --project infra-195110
  export KUBE_NAMESPACE=production
}
alias kp="kube-production"

function get-pod {
  SERVICE="$1"
  kubectl -n "$KUBE_NAMESPACE" get pods | grep "$SERVICE" | head -1 | sed -E "s/^($SERVICE-[0-9a-z]{9,10}-[0-9a-z]{5}).*$/\1/"
}
function pod {
  POD=$(get-pod $1)
  echo "Connecting to: $POD ($KUBE_NAMESPACE)"
  kubectl -n "$KUBE_NAMESPACE" exec -ti "$POD" -- bash
}
