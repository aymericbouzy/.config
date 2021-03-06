# Take input via VS Code
function input {
  local FILE=$(mktemp)
  code --wait $FILE
  cat $FILE
}

# usage: edit "console.log(new Date());" .js
function edit {
  local VALUE="$1"
  local FILE=$(gmktemp --suffix=${2:-.txt})
  echo "$VALUE" > $FILE
  code --wait $FILE
  cat $FILE
}

function whoisusingport {
  PORT="$1"
  lsof -nP -i4TCP:$PORT | grep LISTEN
}

function clipboard {
  pbcopy < /dev/stdin
}

# CSV to SQL list
function csv-to-sql {
  echo "$1" | awk 1 ORS=',' | sed -e 's/.$//' -e 's/^/("/' -e 's/$/")\n/' -e 's/,/","/g' | clipboard
}

# Displays the number of ms since Unix Epoch
function ms {
  gdate +%s%3N
}

# Displays the number of ms since Unix Epoch
function now {
  gdate -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
}

# prefix to any command to know how much time it lasted
function chrono {
  local START=$(ms)
  "$@"
  echo "Done in $(($(ms) - $START))ms"
  return $?
}
