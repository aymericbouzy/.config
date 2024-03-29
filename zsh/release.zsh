# usage: release major|minor|patch|1.20.1 "release message"
function release {
  local BUMP="$1"
  local MESSAGE="$2"
  local PACKAGE_JSON_PATH="$PWD/package.json"

  git wip
  local didstash="$?"
  git-sync

  local CURRENT=$(cat "$PACKAGE_JSON_PATH" | jq '.version' -r)
  local NAME=$(cat "$PACKAGE_JSON_PATH" | jq '.name' -r)
  if echo major minor patch | grep -w -q $BUMP; then
    local NEW=$(semver "$CURRENT" -i "$BUMP")
  else
    local NEW=$BUMP
  fi
  git flow init -d
  git start "release/v$NEW"
  npm version "$NEW" -m "release: bump to v$NEW"'

'"$MESSAGE"
  git flow release finish "v$NEW"

  if [ "$didstash" -eq 0 ]; then
    git resume
  fi

  echo "Release *$NAME v$NEW*\n* $MESSAGE\n" | clipboard

  echo
  echo "Ready to deploy 🕐 Review the diff before pushing your code 🚨"
  echo
  echo "  git diff $(git-main-branch)@{u}..$(git-main-branch)"
  echo "  git log $(git-main-branch)@{u}...$(git-main-branch) --oneline"
  echo
  echo "Once you've confirmed all the code was correctly reviewed, run:"
  echo
  echo "  deploy"
}

function cancel-release {
  local PACKAGE_JSON_PATH="$PWD/package.json"
  local VERSION=$(cat "$PACKAGE_JSON_PATH" | jq '.version' -r)
  git tag --delete "v$VERSION"
  git switch "$(git-main-branch)"
  git reset --hard "$(git-main-branch)@{u}"
  git switch develop
  git reset --hard develop@{u}
  # sometimes we accidentally delete the tag of the latest version: fetch it again
  git pull
}

# usage: hotfix major|minor|patch "release message"
function hotfix {
  BUMP="$1"
  MESSAGE="$2"
  PACKAGE_JSON_PATH="$PWD/package.json"

  git wip
  local didstash="$?"
  git-sync

  CURRENT=$(cat "$PACKAGE_JSON_PATH" | jq '.version' -r)
  if echo major minor patch | grep -w -q $BUMP; then
    local NEW=$(semver "$CURRENT" -i "$BUMP")
  else
    local NEW=$BUMP
  fi
  git flow init -d
  m
  git start "hotfix/v$NEW"
  echo "You can now cherry pick some commits to the hotfix branch. Press Enter when done."
  read confirmation
  npm version "$NEW" -m "release: bump to v$NEW"'

'"$MESSAGE"
  git flow hotfix finish "v$NEW"

  if [ "$didstash" -eq 0 ]; then
    git resume
  fi

  echo "Release *${PWD##*/} v$NEW*\n* $MESSAGE\n" | clipboard
}

# usage: restore v1.3.2
function restore {
  local TAG="$1"
  local PACKAGE_JSON_PATH="$PWD/package.json"

  git wip
  local didstash="$?"
  git-sync

  local CURRENT=$(cat "$PACKAGE_JSON_PATH" | jq '.version' -r)
  local NEW=$(semver "$CURRENT" -i patch)
  git flow init -d
  git flow hotfix start "v$NEW"
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git checkout $TAG
  git reset --soft $BRANCH
  git checkout $BRANCH
  git commit -am "revert: restore $TAG"
  npm version "$NEW" -m "release: restore $TAG"
  git flow hotfix finish "v$NEW"

  if [ "$didstash" -eq 0 ]; then
    git resume
  fi

  echo "Release *${PWD##*/} v$NEW*\n* revert $TAG\n" | clipboard
}

function deploy {
  git switch develop
  git push
  git switch "$(git-main-branch)"
  git push
  open "https://app.circleci.com/pipelines/github/cubyn?filter=mine" &
  local SERVICE="${PWD##*/}"
  open "https://app.datadoghq.com/logs?query=%40env%3Aproduction%20service%3A$SERVICE%20-status%3Ainfo&agg_m=count&agg_q=status%2C%40custom.errorString.type&agg_t=count&index=&integration_id=&integration_short_name=&saved_view=68807&sort_m=%2C&sort_t=%2C&step=604800000&top_n=10%2C10&top_o=top%2Ctop&viz=timeseries&from_ts=1630337303060&to_ts=1630340903060&live=true" &
}
