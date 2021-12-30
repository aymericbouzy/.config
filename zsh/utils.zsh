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

# CSV to SQL list
function csv-to-sql {
  echo "$1" | awk 1 ORS=',' | sed -e 's/.$//' -e 's/^/("/' -e 's/$/")\n/' -e 's/,/","/g' | clipboard
}
