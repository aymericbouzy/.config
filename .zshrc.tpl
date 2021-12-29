for file in $(find "$HOME/.config/zsh" -type f -name "*.zsh" | sort); do
  source "$file"
done
