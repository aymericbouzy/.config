function run {
  local COMMAND="$1"
  if cat package.json | grep '"dotenv":' >>/dev/null; then
    dotenv -e .env${ENV:+.$ENV} -- bash -c "$COMMAND"
  elif cat package.json | grep '"dotenv-flow":' >>/dev/null; then
    NODE_ENV=${NODE_ENV:-$ENV} dotenv-flow -- bash -c "$COMMAND"
  else
    echo "You must be using dotenv or dotenv flow in the repo" >>/dev/stderr
    return 1
  fi
}

function sql {
  local SCRIPT="$1"
  local USE_DATABASE='CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; USE \`${DB_DATABASE:-$MYSQL_DATABASE}\`'
  run 'MYSQL_PWD=${DB_PASS:-$MYSQL_PASSWORD} mysql -h ${DB_HOST:-$MYSQL_HOST} -u ${DB_USER:-$MYSQL_USER} -e "'"$USE_DATABASE; $SCRIPT"'"'
}

function testdb {
  echo "Recreating test database"
  ENV=test sql 'DROP DATABASE IF EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; CREATE DATABASE \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
}

function initdb {
  sql 'CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
}

function testdb-flow {
  local SQL='DROP DATABASE IF EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; CREATE DATABASE \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
  local COMMAND='MYSQL_PWD=${DB_PASS:-$MYSQL_PASSWORD} mysql -h ${DB_HOST:-$MYSQL_HOST} -u ${DB_USER:-$MYSQL_USER} -e "'$SQL'"'
  NODE_ENV=test dotenv-flow -- bash -c $COMMAND
}

function tw {
  testdb
  if make help | grep test-init >>/dev/null; then
    make test-init
  else
    make init-test
  fi
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
