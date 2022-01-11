export EDITOR="code --wait"
export PROFILE="$HOME/.zshrc"

# Edit profile
function config {
  code -n --wait ~/.config/zsh
  source $PROFILE
}
alias reload="source $PROFILE"
