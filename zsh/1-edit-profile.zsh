export EDITOR="code --wait"
export PROFILE="$HOME/.zshrc"

# Edit profile
function config {
  code -n ~/.config
  read confirmation
  echo "Reloading 🕐"
  reload
  echo "Reloaded ✅"
}

# Reload profile
function reload {
  source "$PROFILE"
}
