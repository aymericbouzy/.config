export CAROTTE_HOST=rabbit.private-staging.playship.co
export AMQP_HOST="$CAROTTE_HOST"
export CAROTTE_CLI_USER=aymeric_bouzy
export CAROTTE_DEBUG_TOKEN=aymericb

###-begin-carotte-completions-###
#
# yargs command completion script
#
# Installation: /usr/local/bin/carotte completion >> ~/.bashrc
#    or /usr/local/bin/carotte completion >> ~/.bash_profile on OSX.
#
_yargs_completions()
{
    local cur_word args type_list

    cur_word="${COMP_WORDS[COMP_CWORD]}"
    args=("${COMP_WORDS[@]}")

    # ask yargs to generate completions.
    type_list=$(/usr/local/bin/carotte --get-yargs-completions "${args[@]}")

    COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )

    # if no match was found, fall back to filename completion
    if [ ${#COMPREPLY[@]} -eq 0 ]; then
      COMPREPLY=( $(compgen -f -- "${cur_word}" ) )
    fi

    return 0
}
complete -F _yargs_completions carotte
###-end-carotte-completions-###

function krot {
  # usage: krot migration add-deliveries
  function migration {
    local name="$(echo "$@" | tr ' ' '-')"
    local version="$(date +%s)"
    filename="$version-$name.sql"
    migrationPath='migrations'

    if [ -d "migrations/prod" ]
    then
      migrationPath='migrations/prod'
    fi

    touch $migrationPath/$filename;
    echo "-- Migration: $name\n-- Version: $version\n-- Created at: `date '+%F %H:%M:%S'`\n\n-- ====  UP  ====\n\n-- ==== DOWN ====" > $migrationPath/$filename;

    if [ -d "migrations/test" ]
    then
      cd migrations/test;
      ln -s ../prod/$filename;
      cd ../..
    fi
    echo "Successfully created migration $name: ./$migrationPath/$filename"
  }

  function create {
    local FOLDER="$1"s
    local QUALIFIER="$2"
    local QUALIFIER_PATH="./src/$FOLDER/$QUALIFIER"
    mkdir $QUALIFIER_PATH
    if [ -f "./src/index.js" ]; then
      touch $QUALIFIER_PATH/{index,index.spec}.js
    else
      touch $QUALIFIER_PATH/{handler,handler.spec,meta}.ts
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
    install-deps
    if jq -e '.scripts | has("serve:watch")' package.json >>/dev/null; then
      NODE_ENV=${NODE_ENV:-staging} make init
      NODE_ENV=${NODE_ENV:-staging} yarn serve:watch
    else
      NODE_ENV=${NODE_ENV:-staging} make run-watch
    fi
  }

  "$@"
}
