function set-carotte-host {
  local env="$(kubens -c)"

  case $env in
  staging)
    export CAROTTE_HOST=rabbitmq-amqp.staging.playship.co
  ;;
  production)
    export CAROTTE_HOST=rabbitmq-amqp.production.playship.co
  ;;
  sandbox)
    export CAROTTE_HOST=
  ;;
  *)
    export CAROTTE_HOST=
  ;;
  esac
}


function staging {
  kubectx staging
  kubens staging
  set-carotte-host
}

function production {
  kubectx production
  kubens production
  set-carotte-host
}
alias prod=production

function sandbox {
  kubectx production
  kubens sandbox
  set-carotte-host
}

set-carotte-host
