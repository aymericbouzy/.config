function git-branch-exists {
  local BRANCH="$1"
  git rev-parse --verify "refs/heads/$BRANCH" > /dev/null 2> /dev/null
  return $?
}

# sync master and develop with origin
function git-sync {
  if git-branch-exists master; then
    git switch master
    git pull
  fi
  if git-branch-exists develop; then
    git switch develop
    git pull
  fi
}
alias gs="git-sync"

# usage: git-global-cherry-pick service-parcel 5ab7a68
function git-global-cherry-pick {
  git --git-dir=../$1/.git format-patch -k -1 --stdout $2 | git apply --reject --whitespace=fix
}

# usage: pr-cherry-pick 24
function pr-cherry-pick {
  PR="$1"
  COMMIT="$(git log develop --grep "pull request #$PR from" -n 1 --merges --format=%H)"
  git cherry-pick "$COMMIT^..$COMMIT^2"
}

# usage: mr-cherry-pick feature/OR-74-add-osv2-warehouse
function mr-cherry-pick {
  local BRANCH="$1"
  COMMIT="$(git log develop --grep "Merge branch '$BRANCH' into" -n 1 --merges --format=%H)"
  git cherry-pick "$COMMIT^..$COMMIT^2"
}

function auto-review {
  git rebase -i develop --autosquash --exec 'git reset HEAD^ && yarn test -o && yarn lint && git reset HEAD@{1}'
}
function auto-review-retry {
  yarn test -o && yarn lint
}

# git alias
alias gri="git rebase -i develop --autosquash"
alias grc="git rebase --continue"
alias review="gh pr checkout"
alias commit='git commit -m "$(input)"'
