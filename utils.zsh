# Take input via VS Code
function input {
  local FILE=$(mktemp)
  code --wait $FILE
  cat $FILE
}

function whoisusingport {
  PORT="$1"
  lsof -nP -i4TCP:$PORT | grep LISTEN
}

alias clipboard="pbcopy"
