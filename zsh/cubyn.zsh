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
  if has-dep pg; then
    if run $'PGPASSWORD=$POSTGRESQL_PASSWORD psql -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -tc "SELECT 1 FROM pg_database WHERE datname = \'$POSTGRESQL_DATABASE\'"' | grep -q 1; then
    else
      run $'PGPASSWORD=$POSTGRESQL_PASSWORD psql -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -c "CREATE DATABASE \'$POSTGRESQL_DATABASE\'"' >> /dev/stderr
    fi
    run 'PGPASSWORD=$POSTGRESQL_PASSWORD psql -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -c "'$SCRIPT'"'
  else
    local SCRIPT="$1"
    local USE_DATABASE='CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; USE \`${DB_DATABASE:-$MYSQL_DATABASE}\`'
    run 'MYSQL_PWD=${DB_PASS:-$MYSQL_PASSWORD} mysql -h ${DB_HOST:-$MYSQL_HOST} --port ${DB_PORT:-${MYSQL_PORT:-3306}} -u ${DB_USER:-$MYSQL_USER} -e "'"$USE_DATABASE; $SCRIPT"'"'
  fi
}

function testdb {
  echo "Recreating test database \`$(ENV=test run 'echo "${DB_DATABASE:-$MYSQL_DATABASE}"')\`"
  ENV=test sql 'DROP DATABASE IF EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; CREATE DATABASE \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
  if make help | grep test-init >>/dev/null; then
    make test-init
  else
    make init-test
  fi
}

function initdb {
  sql 'CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
}

function tw {
  testdb
  yarn test:watch
}

# available: rabbitmq sftp mongodb elasticsearch product-elasticsearch mysql
alias devenv="cd $HOME/Dev/cubyn/infra-docker-compose; docker-compose -f datasources.yml up"

# helm
export CUBYN_HELM_PATH="$HOME/Dev/cubyn/helm"

# ./shmig -t postgresql -l $$POSTGRESQL_USER -p $$POSTGRESQL_PASSWORD -d $$POSTGRESQL_DATABASE -H $${POSTGRESQL_HOST:-localhost} -P $${POSTGRESQL_PORT:-5432} -s migrations up

function shmig {
  if has-dep pg; then
    local engine=postgresql
  else
    local engine=mysql
  fi
  if [ -d migrations/prod ]; then
    local MIGRATIONS_DIRECTORY="migrations/prod"
  else
    local MIGRATIONS_DIRECTORY="migrations"
  fi
  run './shmig -t '$engine' -l ${DB_USER:-${MYSQL_USER:-$POSTGRESQL_USER}} -p ${DB_PASS:-${MYSQL_PASSWORD:-$POSTGRESQL_PASSWORD}} -d ${DB_DATABASE:-${MYSQL_DATABASE:-$POSTGRESQL_DATABASE}} -H ${DB_HOST:-${MYSQL_HOST:-${POSTGRESQL_HOST:-localhost}}} -P ${DB_PORT:-${MYSQL_PORT:-${POSTGRESQL_PORT:-3306}}} -m '"$MIGRATIONS_DIRECTORY"' -s migrations '"$@"
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
