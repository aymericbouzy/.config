source <(kubectl completion zsh)

alias k="kubectl"
compdef k=kubectl

function kube-current-context {
  kubectl config view -o jsonpath='{.current-context}'
}

alias kn=kubens
alias kx=kubectx
compdef kn=kubens kx=kubectx

function get-pod {
  SERVICE="$1"
  kubectl get pods | grep "$SERVICE" | head -1 | sed -E "s/^($SERVICE-[0-9a-z]{9,10}-[0-9a-z]{5}).*$/\1/"
}

function pod {
  POD=$(get-pod $1)
  echo "Connecting to: $POD ($(kube-current-context))"
  kubectl exec -ti "$POD" -- bash
}

# https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# usage: kapply service-parcel
function kapply {
  (
    cd k8s-configuration
    local ENV=$(kube-current-context)
    local SERVICE=$1
    ./independant_apply.sh $ENV "1-$ENV/$SERVICE.yml"
    "$ENV"
  )
}
