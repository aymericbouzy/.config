export CAROTTE_HOST=rabbitmq-amqp.staging.playship.co
export CAROTTE_CLI_USER=aymeric_bouzy
export CAROTTE_DEBUG_TOKEN=aymericb

function migrationsDir {
  if [ -d migrations/prod ]
  then
    echo migrations/prod
  else
    echo migrations
  fi
}

function krot {
  # usage: krot migration add-deliveries
  function migration {
    local name="$(echo "$@" | tr ' ' '-')"
    local version="${VERSION:-$(date +%s)}"
    local filename="$version-$name.sql"

    cat << EOF > "$(migrationsDir)/$filename"
-- Migration: $name
-- Version: $version
-- Created at: $(date '+%F %H:%M:%S')

-- ====  UP  ====

-- ==== DOWN ====
EOF

    if [ -d "migrations/test" ]
    then
      (
        cd migrations/test;
        ln -s ../prod/$filename;
      )
    fi
    echo "Successfully created migration $name: ./$(migrationsDir)/$filename"

    code "./$(migrationsDir)/$filename"
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

      if [[ "$CAROTTE_DEBUG_TOKEN" != "" ]]; then
        echo 'running with debug token "'"$CAROTTE_DEBUG_TOKEN"'"'
      fi

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

  function percona {
    if [ "$1" = staging ]; then
      gcloud compute ssh --project=staging2-284609 housekeeping-devops --zone=europe-west1-d
    elif [ "$1" = production ]; then
      gcloud compute ssh --project=infra-195110 devops-housekeeping --zone=europe-west3-c
    else
      local migration="${1:-"$(ls "$(migrationsDir)" | sort -V | tail -n 1)"}"
      local version=$(echo "$migration" | sed -E 's/^([0-9]+).*/\1/')
      local database=$(run 'echo ${DB_DATABASE:-$MYSQL_DATABASE}')
      local table=$(
        cat "$(migrationsDir)/$migration" | \
          tr '\n' ' ' | \
          sed -E 's/.*alter table `?([^` ]+)`?.*/\1/'
      )
      local query=$(
        cat "$(migrationsDir)/$migration" | \
          # put everything on a single line
          tr '\n' ' ' | \
          # extract what comes after "alter table $table"
          sed -E 's/.*-- ====  UP  ====.*alter table [-`._a-zA-Z]+ *(.*)-- ==== DOWN ====.*/\1/' | \
          # remove trailing whitespace
          sed -E 's/ *$//' | \
          # escape single quotes
          sed -E "s/(')/\\\\'/g"
      )

      cat << EOF > migration.md
# Migration

\`\`\`sh
screen -S $version
\`\`\`

\`\`\`sh
pt-online-schema-change \\
  --statistics \\
  --recursion-method dsn=t=tools.dsns \\
  --user root \\
  --ask-pass \\
  --host database-main-master.private-staging.playship.co \\
  --max-lag=60 \\
  --max-load Threads_running=100 \\
  --critical-load Threads_running=200 \\
  --alter-foreign-keys-method=auto \\
  --alter \$'$query' D=$database,t=$table \\
  --progress time,10 \\
  --dry-run
\`\`\`

\`\`\`sql
insert into \`$database\`.migrations (\`version\`, \`migrated_at\`)
values ($version, now());
\`\`\`
EOF

      code migration.md
    fi
  }

  "$@"
}
