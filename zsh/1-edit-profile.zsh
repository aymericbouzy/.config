export EDITOR="code --wait"
export PROFILE="$HOME/.zshrc"

# Edit profile
function config {
  code --wait ~/.config/zsh
  source $PROFILE
}
alias reload="source $PROFILE"
