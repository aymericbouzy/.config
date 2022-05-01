if which nodenv >>/dev/null; then
  eval "$(nodenv init - --no-rehash)"
fi

function defnode {
  local VERSION="$1"
  echo "$VERSION" > .nvmrc
  yarn
}

# install node dependencies
function install-deps {
  if [ -f yarn.lock ]; then
    yarn
  fi
}


function has-dep {
  [ $(jq ".dependencies | has(\"$1\")" < package.json) = "true" ]
  return $?
}

alias n=nodenv
