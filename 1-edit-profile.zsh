export EDITOR="code --wait"
export PROFILE="$HOME/.zshrc"

# Edit profile
function config {
  code --wait ~/.zshrc
  source ~/.zshrc
}
alias reload="source $PROFILE"
