function git-branch-exists {
  local BRANCH="$1"
  git rev-parse --verify "refs/heads/$BRANCH" > /dev/null 2> /dev/null \
    || git rev-parse --verify "refs/remotes/origin/$BRANCH" > /dev/null 2> /dev/null
  return $?
}

function git-main-branch {
  if git-branch-exists master; then
    echo master
  fi
  if git-branch-exists main; then
    echo main
  fi
}

# sync master and develop with origin
function git-sync {
  if git-branch-exists master; then
    git switch master
    git pull
  fi
  if git-branch-exists main; then
    git switch main
    git pull
  fi
  if git-branch-exists develop; then
    git switch develop
    git pull
  fi
  install-deps
}
alias gs="git-sync"

# TODO: use remote instead
# usage: git-global-cherry-pick ~/Dev/cubyn/service-parcel 5ab7a68
function git-global-cherry-pick {
  git --git-dir=$1/.git format-patch -k -1 --stdout $2 | git am --reject --whitespace=fix -C1
}

function pr-range {
  PR="$1"
  COMMIT="$(git log develop --grep "pull request #$PR from" -n 1 --merges --format=%H)"
  echo "$COMMIT^..$COMMIT^2"
}

# usage: pr-cherry-pick 24
function pr-cherry-pick {
  git cherry-pick "$(pr-range "$1")"
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
alias gri="git rb develop@{u}"
alias grc="git rebase --continue"
alias gg="git graph"

function git-switch-pull {
  local branch="$1"

  git wip
  local didstash="$?"

  git switch "$branch"
  git pull

  if [ "$didstash" -eq 0 ]; then
    git resume
  fi
}

alias m='git-switch-pull $(git-main-branch)'
alias d='git-switch-pull develop'

function blame-ignore {
  local COMMIT="$1"
  echo "# Prettier"                                >> .git-blame-ignore-revs
  echo "$COMMIT"                                   >> .git-blame-ignore-revs

  echo "[blame]"                                   >> .gitconfig
  echo "  ignoreRevsFile = .git-blame-ignore-revs" >> .gitconfig

  git config include.path ../.gitconfig
}

function pending-release {
  git fetch
  git l "$(git-main-branch)@{u}..develop@{u}" "$@"
}

# from https://polothy.github.io/post/2019-08-19-fzf-git-checkout/
function fzf-git-branch {
  git rev-parse HEAD > /dev/null 2>&1 || return

  git branch --color=always --all --sort=-committerdate |
    grep -v HEAD |
    fzf --height 50% --ansi --no-multi --preview-window right:65% \
      --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
    sed "s/.* //"
}

function switch {
  git rev-parse HEAD > /dev/null 2>&1 || return

  local branch

  branch=$(fzf-git-branch)
  if [[ "$branch" = "" ]]; then
    return
  fi

  # If branch name starts with 'remotes/' then it is a remote branch. By
  # using --track and a remote branch name, it is the same as:
  # git checkout -b branchName --track origin/branchName
  if [[ "$branch" = 'remotes/'* ]]; then
    git switch --track $branch
  else
    git switch $branch
  fi
}

alias sw=switch

export PATH=$PATH:$HOME/.config/git/commands
