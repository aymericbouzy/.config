function staging {
  kubectx staging
  kubens staging
}

function production {
  kubectx production
  kubens production
}
alias prod=production

function sandbox {
  kubectx production
  kubens sandbox
}

function precmd {
  local env="$(kubectl config view -o jsonpath='{.current-context}')"
  local vhost="$(kubens -c)"
  local user="$vhost"

  if [[ $env == $vhost ]]; then
    local vhost=""
    local user="guest"
  fi

  local password="$(rabbitmq_password $env $user)"

  if [[ $env == staging ]]; then
    export CAROTTE_HOST="amqp://$user:$password@rabbitmq-amqp.staging.playship.co/$vhost"
  elif [[ $env == production ]]; then
    export CAROTTE_HOST="amqp://$user:$password@rabbitmq-amqp.production.playship.co/$vhost"
  else
    export CAROTTE_HOST=
  fi
}

function rabbitmq_password {
  if [[ $1 == production ]]; then
    if [[ $2 == guest ]]; then
      echo $CUBYN_RABBITMQ_GUEST_PASSWORD
    elif [[ $2 == herblay ]]; then
      echo $CUBYN_RABBITMQ_HERBLAY_PASSWORD
    elif [[ $2 == herblay-p2 ]]; then
      echo $CUBYN_RABBITMQ_HERBLAY_P2_PASSWORD
    fi
  elif [[ $1 == staging ]]; then
    if [[ $2 == guest ]]; then
      echo $CUBYN_RABBITMQ_GUEST_PASSWORD
    fi
  fi
}
