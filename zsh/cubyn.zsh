function testdb {
  local SQL='DROP DATABASE IF EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; CREATE DATABASE \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
  local COMMAND='MYSQL_PWD=${DB_PASS:-$MYSQL_PASSWORD} mysql -h ${DB_HOST:-$MYSQL_HOST} -u ${DB_USER:-$MYSQL_USER} -e "'$SQL'"'
  dotenv -e .env.test -- bash -c "$COMMAND"
}

function testdb-flow {
  local SQL='DROP DATABASE IF EXISTS \`${DB_DATABASE:-$MYSQL_DATABASE}\`; CREATE DATABASE \`${DB_DATABASE:-$MYSQL_DATABASE}\`;'
  local COMMAND='MYSQL_PWD=${DB_PASS:-$MYSQL_PASSWORD} mysql -h ${DB_HOST:-$MYSQL_HOST} -u ${DB_USER:-$MYSQL_USER} -e "'$SQL'"'
  NODE_ENV=test dotenv-flow -- bash -c $COMMAND
}

alias tw="testdb && (make init-test || make test-init) && yarn test:watch"

# available: rabbitmq sftp mongodb elasticsearch product-elasticsearch mysql
alias devenv="cd $HOME/Dev/cubyn/infra-docker-compose; docker-compose -f datasources.yml up"

# helm
export CUBYN_HELM_PATH="$HOME/Dev/cubyn/helm"

# FIXME: make it work with TS template conventions
function shmig-rollback {
  local COMMAND='./shmig -t mysql -l $DB_USER -p $DB_PASS -d $DB_DATABASE -H ${DB_HOST:-localhost} -P ${DB_PORT:-3306} -m migrations/prod -s migrations rollback 1'
  dotenv -e .env -- bash -c "$COMMAND"
}
