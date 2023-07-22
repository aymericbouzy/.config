for file in $(find "$HOME/.config/zsh/completions" -type f -name "*.zsh" | sort); do
  source "$file"
done
