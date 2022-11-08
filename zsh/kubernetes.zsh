source <(kubectl completion zsh)

alias k="kubectl"

function kube-staging {
  kubectx staging
  kubens staging
}
alias ks="kube-staging"

function kube-qa {
  kubectx qa
  kubens qa
}
alias kq="kube-qa"

function kube-demo {
  kubectx production
  kubens sandbox
}
alias kd="kube-demo"

function kube-production {
  kubectx production
  kubens production
}
alias kp="kube-production"

function kube-current-context {
  kubens -c
}

alias kn=kubens
alias kx=kubectx

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
    if [ $ENV = sandbox ]; then
      kubectx production
    else
      kubectx $ENV
    fi
    kubens $ENV
  )
}
