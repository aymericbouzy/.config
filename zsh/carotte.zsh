export CAROTTE_HOST="rabbitmq:5675"
export AMQP_HOST="$CAROTTE_HOST"
export CAROTTE_CLI_USER="aymeric_bouzy"
export CAROTTE_DEBUG_TOKEN="aymeric"

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

function migration {
  filename=`date +%s`-$1.sql;
  migrationPath='migrations'

  if [ -d "migrations/prod" ]
  then
    migrationPath='migrations/prod'
  fi

  touch $migrationPath/$filename;
  echo "-- Migration: $1\n-- Created at: `date '+%F %H:%M:%S'`\n\n-- ====  UP  ====\n\n-- ==== DOWN ====" > $migrationPath/$filename;

  if [ -d "migrations/test" ]
  then
    cd migrations/test;
    ln -s ../prod/$filename;
    cd ../..
  fi
  echo "Successfully created $1 migration : ./$migrationPath/$filename"
}

# usage: carotte-create lambda parcel.read:v1
function carotte-create {
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
