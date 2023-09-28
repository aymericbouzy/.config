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

  if [[ $env == staging ]]; then
    export CAROTTE_HOST=rabbitmq-amqp.staging.playship.co
  elif [[ $env == production ]]; then
    export CAROTTE_HOST=rabbitmq-amqp.production.playship.co
  else
    export CAROTTE_HOST=
  fi
}
