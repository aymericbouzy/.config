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
cd() {
  builtin cd "$@"
  if [ -f .nvmrc ] && ! semver -r "$(cat .nvmrc)" "$(node --version)" > /dev/null; then
    n auto
  fi
}
