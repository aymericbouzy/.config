# n (Node.js version manager)
export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

function defnode {
  local VERSION="$1"
  n "$VERSION"
  echo "$VERSION" > .nvmrc
  yarn
}

# auto detect node version
function ensure-node-version {
  if [ -f .nvmrc ] && ! semver -r "$(cat .nvmrc)" "$(node --version)" > /dev/null; then
    n auto
    if [ -f yarn.lock ]; then
      yarn
    fi
  fi
}

cd() {
  builtin cd "$@"
  ensure-node-version
}

function has-dep {
  [ $(jq ".dependencies | has(\"$1\")" < package.json) = "true" ]
  return $?
}
