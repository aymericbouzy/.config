function focus {
  local NEW_FOCUS="$(echo "$@")"

  if [ -z "$NEW_FOCUS" ]; then
    echo "$FOCUS" > /dev/stderr
  else
    export FOCUS="$NEW_FOCUS"
  fi
}
