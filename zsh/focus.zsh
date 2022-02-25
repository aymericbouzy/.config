function focus {
  local focus="$(echo "$@")"
  local focus_file="$HOME/.focus"

  if [ -z "$focus" ]; then
    cat "$focus_file" > /dev/stderr
  else
    echo "$focus" > "$focus_file"
  fi
}
