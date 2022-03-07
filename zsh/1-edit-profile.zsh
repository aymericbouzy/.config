export EDITOR="code --wait"
export PROFILE="$HOME/.zshrc"

# Edit profile
function config {
  code -n ~/.config
  read confirmation
  echo "Reloading 🕐"
  reload $confirmation
  echo "Reloaded ✅"
}

# Reload profile
function reload {
  if [ ! -z "$1" ]; then
    source "$HOME/.config/zsh/$1.zsh"
  else
    source "$PROFILE"
  fi
}
