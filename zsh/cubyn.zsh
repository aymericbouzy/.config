function run {
  local COMMAND="$1"
  if has-dep dotenv; then
    if [ ! -z "$DEBUG" ]; then
      dotenv -e .env${ENV:+.$ENV} -- bash -c 'echo '"$COMMAND"
    fi
    dotenv -e .env${ENV:+.$ENV} -- bash -c "$COMMAND"
  elif has-dep dotenv-flow; then
    NODE_ENV=${NODE_ENV:-$ENV} dotenv-flow -- bash -c "$COMMAND"
  else
    echo "You must be using dotenv or dotenv flow in the repo" >>/dev/stderr
    return 1
  fi
}

function sql {
  local SCRIPT="$1"
  if has-dep pg; then
    run 'PGPASSWORD=$POSTGRESQL_PASSWORD psql -d $POSTGRESQL_DATABASE -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -c "'"$SCRIPT"'"'
  else
    local USE_DATABASE='USE \`${DB_DATABASE:-$MYSQL_DATABASE}\`'
    run 'MYSQL_PWD=${DB_PASS:-$MYSQL_PASSWORD} mysql -h ${DB_HOST:-$MYSQL_HOST} --port ${DB_PORT:-${MYSQL_PORT:-3306}} -u ${DB_USER:-$MYSQL_USER} -e "'"$USE_DATABASE; $SCRIPT"'"'
  fi
}

function testdb {
  if has-dep pg; then
    echo "Recreating test schema"
    ENV=test initdb
    ENV=test sql 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
  else
    echo "Recreating test database \`$(ENV=test run 'echo "${DB_DATABASE:-$MYSQL_DATABASE}"')\`"
    ENV=test sql 'DROP DATABASE IF EXISTS \`$DATABASE\`; CREATE DATABASE \`$DATABASE\`;'
  fi
  if make help | grep test-init >>/dev/null; then
    make test-init
  else
    make init-test
  fi
}

function initdb {
  if has-dep pg; then
    if sql $'SELECT FROM pg_database WHERE datname = \'$POSTGRESQL_DATABASE\'' | grep "1 row" >>/dev/null; then
    else
      local SCRIPT='CREATE DATABASE $POSTGRESQL_DATABASE'
      run $'PGPASSWORD=$POSTGRESQL_PASSWORD psql -d postgres -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -c "'"$SCRIPT"'"'
    fi
  else
    sql 'CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
  fi
}

function tw {
  testdb
  yarn test:watch
}

# available: rabbitmq sftp mongodb elasticsearch product-elasticsearch mysql
alias devenv="cd $HOME/Dev/cubyn/infra-docker-compose; docker-compose -f datasources.yml up"

# helm
export CUBYN_HELM_PATH="$HOME/Dev/cubyn/helm"

function shmig {
  if [ -d migrations/prod ]; then
    local MIGRATIONS_DIRECTORY="migrations/prod"
  else
    local MIGRATIONS_DIRECTORY="migrations"
  fi
  run './shmig -t mysql -l ${DB_USER:-$MYSQL_USER} -p ${DB_PASS:-$MYSQL_PASSWORD} -d ${DB_DATABASE:-$MYSQL_DATABASE} -H ${DB_HOST:-${MYSQL_HOST:-localhost}} -P ${DB_PORT:-${MYSQL_PORT:-3306}} -m '"$MIGRATIONS_DIRECTORY"' -s migrations '"$@"
}

# usage: s3 /kyivl54o000a30ebe94xncgd.xlsx
function s3 {
  if [[ $1 == *"vault/"* ]]; then
    aws s3 cp s3://cubyn.prod.vault${1//vault\/} ${2:-"~/Downloads"}
  else
    aws s3 cp s3://cubyn.prd$1 ${2:-"~/Downloads"}
  fi
}
# usage: s3-staging /kyivl54o000a30ebe94xncgd.xlsx
function s3-staging {
  if [[ $1 == *"vault/"* ]]; then
    aws s3 cp s3://cubyn.staging.vault${1//vault\/} ${2:-"~/Downloads"}
  else
    aws s3 cp s3://cubyn.ppd$1 ${2:-"~/Downloads"}
  fi
}

function trx {
  open "https://app.datadoghq.com/logs?cols=service%2C%40custom.errorString.type&from_ts=1606136683000&index=&live=true&messageDisplay=inline&query=%40context.transactionId%3A$1&stream_sort=desc&to_ts=1607346283000"
}
