export CAROTTE_HOST=rabbitmq-amqp.staging.playship.co
export CAROTTE_CLI_USER=aymeric_bouzy
export CAROTTE_DEBUG_TOKEN=aymericb

function krot {
  # usage: krot migration add-deliveries
  function migration {
    local name="$(echo "$@" | tr ' ' '-')"
    local version="${VERSION:-$(date +%s)}"
    filename="$version-$name.sql"
    migrationPath='migrations'

    if [ -d "migrations/prod" ]
    then
      migrationPath='migrations/prod'
    fi

    touch $migrationPath/$filename;
    echo "-- Migration: $name\n-- Version: $version\n-- Created at: $(date '+%F %H:%M:%S')\n\n-- ====  UP  ====\n\n-- ==== DOWN ====" > $migrationPath/$filename;

    if [ -d "migrations/test" ]
    then
      (
        cd migrations/test;
        ln -s ../prod/$filename;
      )
    fi
    echo "Successfully created migration $name: ./$migrationPath/$filename"

    code "./$migrationPath/$filename"
  }

  function create {
    local FOLDER="$1"s
    local QUALIFIER="$2"
    local QUALIFIER_PATH="./src/$FOLDER/$QUALIFIER"
    mkdir $QUALIFIER_PATH
    if [ -f "tsconfig.json" ]; then
      touch $QUALIFIER_PATH/{handler,handler.spec,meta}.ts
    else
      touch $QUALIFIER_PATH/{index,index.spec}.js
    fi
  }

  # usage: krot controller parcels.create:v1
  function controller {
    create controller "$1"
  }

  # usage: krot lambda parcel.create:v1
  function lambda {
    create lambda "$1"
  }

  # usage: krot listener parcel.created:v1
  function listener {
    create listener "$1"
  }

  function start {
    (
      set -e
      install-deps
      initdb || echo "initdb failed, ignoring"
      if jq -e '.scripts | has("serve:watch")' package.json >>/dev/null; then
        NODE_ENV=${NODE_ENV:-staging} make init
        NODE_ENV=${NODE_ENV:-staging} yarn serve:watch
      else
        NODE_ENV=${NODE_ENV:-staging} make run-watch
      fi
    )
  }

  # useful to monitor rollout of deployment
  # usage: krot pods
  function pods {
    kubectl get pods -l=app=$(cat package.json | jq '.name' -r) --watch --sort-by=.status.startTime
  }

  function file {
    (
      set -e
      local key="$1"
      local download_path="$HOME/Downloads$key"

      CAROTTE_HOST="rabbitmq-amqp.$(kube-current-context).playship.co" carotte invoke file.read:v1 -t '{
        key: "$0"
      }' --bulk -p "$key" --json | jq '.url' -r | xargs curl --output "$download_path"

      open "$download_path"
    )
  }

  function debug {
    if [ "$1" = off ]; then
      export CAROTTE_DEBUG_TOKEN=
      echo "carotte debug token off"
    else
      export CAROTTE_DEBUG_TOKEN=aymericb
      echo "carotte debug token: aymericb"
    fi
  }

  "$@"
}
